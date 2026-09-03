<?php

declare(strict_types=1);

namespace App\Console\Commands;

use App\Models\Gym;
use App\Models\Membership;
use App\Models\Role;
use App\Models\User;
use App\Notifications\NotificationMessage;
use App\Services\NotificationService;
use Illuminate\Console\Command;
use Illuminate\Support\Carbon;

class NotifyExpiringMemberships extends Command
{
    protected $signature = 'gym:notify-expiring-memberships';

    protected $description = 'Notify gym admins about memberships expiring within 7 days';

    public function handle(NotificationService $notificationService): int
    {
        Gym::query()->each(function (Gym $gym) use ($notificationService) {
            $expiringMemberships = Membership::query()
                ->where('gym_id', $gym->id)
                ->where('status', 'active')
                ->whereBetween('end_date', [Carbon::today(), Carbon::today()->addDays(7)])
                ->with('member:id,full_name,member_code')
                ->get();

            if ($expiringMemberships->isEmpty()) {
                return;
            }

            $admins = User::query()
                ->where('gym_id', $gym->id)
                ->whereHas('role', fn ($query) => $query->where('name', Role::ADMIN))
                ->get();

            $message = new NotificationMessage(
                type: \App\Models\GymNotification::TYPE_MEMBERSHIP_EXPIRING,
                title: "{$expiringMemberships->count()} membership(s) expiring within 7 days",
                body: $expiringMemberships->map(fn ($m) => "{$m->member->full_name} ({$m->member->member_code}) — {$m->end_date->toDateString()}")->implode("\n"),
                data: ['count' => $expiringMemberships->count()],
            );

            foreach ($admins as $admin) {
                $notificationService->notify($admin, $message);
            }
        });

        $this->info('Expiring membership notifications dispatched.');

        return self::SUCCESS;
    }
}
