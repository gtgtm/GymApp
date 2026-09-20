<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\GymNotification;
use App\Models\User;
use App\Notifications\Channels\EmailChannel;
use App\Notifications\Channels\InAppChannel;
use App\Notifications\NotificationMessage;
use Illuminate\Support\Facades\Log;

class NotificationService
{
    public function __construct(
        private readonly InAppChannel $inAppChannel,
        private readonly EmailChannel $emailChannel,
    ) {}

    /**
     * @param  string[]  $channels  Defaults to in-app only. Pass ['in_app', 'email'] to also email.
     * @param  int|null  $gymId  Which gym this notification is about. Pass it whenever the
     *                           caller has one (e.g. an entity's gym_id) — see InAppChannel.
     */
    public function notify(User $user, NotificationMessage $message, array $channels = [GymNotification::CHANNEL_IN_APP], ?int $gymId = null): void
    {
        foreach ($channels as $channel) {
            try {
                match ($channel) {
                    GymNotification::CHANNEL_IN_APP => $this->inAppChannel->send($user, $message, $gymId),
                    GymNotification::CHANNEL_EMAIL => $this->emailChannel->send($user, $message),
                    default => Log::warning("Unsupported notification channel requested: {$channel}"),
                };
            } catch (\Throwable $exception) {
                Log::error("Failed to send notification via {$channel}: {$exception->getMessage()}");
            }
        }
    }
}
