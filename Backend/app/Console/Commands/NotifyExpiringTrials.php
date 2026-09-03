<?php

declare(strict_types=1);

namespace App\Console\Commands;

use App\Models\Gym;
use App\Models\Role;
use App\Models\Trial;
use App\Models\User;
use App\Notifications\NotificationMessage;
use App\Services\NotificationService;
use Illuminate\Console\Command;
use Illuminate\Support\Carbon;

class NotifyExpiringTrials extends Command
{
    protected $signature = 'gym:notify-expiring-trials';

    protected $description = 'Notify staff about trials expiring within 3 days';

    public function handle(NotificationService $notificationService): int
    {
        Gym::query()->each(function (Gym $gym) use ($notificationService) {
            $expiringTrials = Trial::query()
                ->where('gym_id', $gym->id)
                ->where('status', Trial::STATUS_ACTIVE)
                ->whereBetween('trial_end', [Carbon::today(), Carbon::today()->addDays(3)])
                ->get();

            if ($expiringTrials->isEmpty()) {
                return;
            }

            $staff = User::query()
                ->where('gym_id', $gym->id)
                ->whereHas('role', fn ($query) => $query->whereIn('name', [Role::ADMIN, Role::RECEPTIONIST]))
                ->get();

            $message = new NotificationMessage(
                type: \App\Models\GymNotification::TYPE_TRIAL_EXPIRING,
                title: "{$expiringTrials->count()} trial(s) expiring within 3 days",
                body: $expiringTrials->map(fn ($t) => "{$t->name} ({$t->mobile}) — ends {$t->trial_end->toDateString()}")->implode("\n"),
                data: ['count' => $expiringTrials->count()],
            );

            foreach ($staff as $member) {
                $notificationService->notify($member, $message);
            }
        });

        $this->info('Expiring trial notifications dispatched.');

        return self::SUCCESS;
    }
}
