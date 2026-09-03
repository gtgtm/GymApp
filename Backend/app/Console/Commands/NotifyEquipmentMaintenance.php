<?php

declare(strict_types=1);

namespace App\Console\Commands;

use App\Models\Equipment;
use App\Models\Gym;
use App\Models\Role;
use App\Models\User;
use App\Notifications\NotificationMessage;
use App\Services\NotificationService;
use Illuminate\Console\Command;
use Illuminate\Support\Carbon;

class NotifyEquipmentMaintenance extends Command
{
    protected $signature = 'gym:notify-equipment-maintenance';

    protected $description = 'Notify admins about equipment due for maintenance within 7 days';

    public function handle(NotificationService $notificationService): int
    {
        Gym::query()->each(function (Gym $gym) use ($notificationService) {
            $dueEquipment = Equipment::query()
                ->where('gym_id', $gym->id)
                ->whereNotNull('next_maintenance_date')
                ->where('next_maintenance_date', '<=', Carbon::today()->addDays(7))
                ->get();

            if ($dueEquipment->isEmpty()) {
                return;
            }

            $admins = User::query()
                ->where('gym_id', $gym->id)
                ->whereHas('role', fn ($query) => $query->where('name', Role::ADMIN))
                ->get();

            $message = new NotificationMessage(
                type: \App\Models\GymNotification::TYPE_EQUIPMENT_MAINTENANCE,
                title: "{$dueEquipment->count()} equipment item(s) need maintenance",
                body: $dueEquipment->map(fn ($e) => "{$e->name} — due {$e->next_maintenance_date->toDateString()}")->implode("\n"),
                data: ['count' => $dueEquipment->count()],
            );

            foreach ($admins as $admin) {
                $notificationService->notify($admin, $message);
            }
        });

        $this->info('Equipment maintenance notifications dispatched.');

        return self::SUCCESS;
    }
}
