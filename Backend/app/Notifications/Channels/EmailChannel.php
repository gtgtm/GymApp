<?php

declare(strict_types=1);

namespace App\Notifications\Channels;

use App\Mail\GymNotificationMail;
use App\Models\User;
use App\Notifications\NotificationMessage;
use Illuminate\Support\Facades\Mail;

class EmailChannel implements NotificationChannel
{
    public function send(User $user, NotificationMessage $message): void
    {
        if (! $user->email) {
            return;
        }

        Mail::to($user->email)->queue(new GymNotificationMail($message));
    }
}
