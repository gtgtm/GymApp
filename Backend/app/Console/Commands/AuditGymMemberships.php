<?php

declare(strict_types=1);

namespace App\Console\Commands;

use App\Models\UserGymMembership;
use Illuminate\Console\Command;

/**
 * Post-Phase-4 sanity check: finds membership rows that reference a user
 * (or gym) that no longer exists. The original version of this command
 * (Phase 1) compared users.gym_id against user_gym_memberships while both
 * were dual-read; that column was dropped in Phase 4, so that half of the
 * check no longer applies — this is what's left of it.
 */
class AuditGymMemberships extends Command
{
    protected $signature = 'gym:audit-memberships';

    protected $description = 'Report membership rows that reference a missing user or gym';

    public function handle(): int
    {
        $orphanMemberships = UserGymMembership::query()
            ->whereDoesntHave('user')
            ->orWhereDoesntHave('gym')
            ->get(['id', 'user_id', 'gym_id']);

        if ($orphanMemberships->isEmpty()) {
            $this->info('No orphaned membership rows.');

            return self::SUCCESS;
        }

        $this->error("{$orphanMemberships->count()} membership row(s) reference a missing user or gym:");
        foreach ($orphanMemberships as $membership) {
            $this->line("  - membership #{$membership->id} user_id={$membership->user_id} gym_id={$membership->gym_id}");
        }

        return self::FAILURE;
    }
}
