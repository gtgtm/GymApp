<?php

declare(strict_types=1);

namespace App\Notifications\Channels;

use App\Models\GymNotification;
use App\Models\User;
use App\Notifications\NotificationMessage;
use App\Services\ActingGymContext;

class InAppChannel implements NotificationChannel
{
    /**
     * $gymId should be passed explicitly by the caller whenever it knows
     * which gym this notification is about (the usual case — most call
     * sites are reacting to a gym-scoped entity like a Payment or
     * Enquiry). Falling back to the acting gym context only covers
     * request-time calls that genuinely have nothing more specific; it is
     * never correct to infer this from $user, since a recipient can now
     * belong to more than one gym (see UserGymMembership) and stamping
     * the wrong one would put this notification in the wrong gym's inbox.
     */
    public function send(User $user, NotificationMessage $message, ?int $gymId = null): void
    {
        GymNotification::query()->create([
            'gym_id' => $gymId ?? app(ActingGymContext::class)->gymId(),
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
