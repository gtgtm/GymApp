<?php

declare(strict_types=1);

namespace App\Notifications\Channels;

use App\Models\User;
use App\Notifications\NotificationMessage;

interface NotificationChannel
{
    public function send(User $user, NotificationMessage $message): void;
}
