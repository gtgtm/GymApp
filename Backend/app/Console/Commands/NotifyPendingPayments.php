<?php

declare(strict_types=1);

namespace App\Console\Commands;

use App\Models\Gym;
use App\Models\MembershipRenewal;
use App\Models\Role;
use App\Models\User;
use App\Notifications\NotificationMessage;
use App\Services\NotificationService;
use Illuminate\Console\Command;

class NotifyPendingPayments extends Command
{
    protected $signature = 'gym:notify-pending-payments';

    protected $description = 'Notify gym admins about total pending payments';

    public function handle(NotificationService $notificationService): int
    {
        Gym::query()->each(function (Gym $gym) use ($notificationService) {
            $pendingAmount = MembershipRenewal::query()
                ->where('gym_id', $gym->id)
                ->sum('amount_due');

            if ($pendingAmount <= 0) {
                return;
            }

            $admins = User::staffAtGymWithRole($gym->id, [Role::ADMIN]);

            $message = new NotificationMessage(
                type: \App\Models\GymNotification::TYPE_PENDING_PAYMENT,
                title: 'Pending payments outstanding',
                body: sprintf('₹%s is pending from members across renewals.', number_format((float) $pendingAmount, 2)),
                data: ['amount_due' => (float) $pendingAmount],
            );

            foreach ($admins as $admin) {
                $notificationService->notify($admin, $message, gymId: $gym->id);
            }
        });

        $this->info('Pending payment notifications dispatched.');

        return self::SUCCESS;
    }
}
