<?php

declare(strict_types=1);

namespace App\Notifications\Channels;

use App\Models\GymNotification;
use App\Models\User;
use App\Notifications\NotificationMessage;

class InAppChannel implements NotificationChannel
{
    public function send(User $user, NotificationMessage $message): void
    {
        GymNotification::query()->create([
            'gym_id' => $user->gym_id,
            'user_id' => $user->id,
            'type' => $message->type,
            'title' => $message->title,
            'body' => $message->body,
            'data' => $message->data,
            'channel' => GymNotification::CHANNEL_IN_APP,
            'sent_at' => now(),
        ]);
    }
}
