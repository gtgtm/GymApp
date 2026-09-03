<?php

declare(strict_types=1);

namespace App\Notifications\Channels;

use App\Models\User;
use App\Notifications\NotificationMessage;

/**
 * WhatsApp delivery is not wired to a provider yet. Plug in a provider
 * (e.g. WhatsApp Business API, Twilio, Gupshup) here when credentials
 * are available — nothing else in the notification pipeline needs to change.
 */
class WhatsAppChannel implements NotificationChannel
{
    public function send(User $user, NotificationMessage $message): void
    {
        throw new \RuntimeException('WhatsApp channel has no provider configured yet.');
    }
}
