<?php

declare(strict_types=1);

namespace App\Mail;

use App\Notifications\NotificationMessage;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class GymNotificationMail extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public function __construct(public readonly NotificationMessage $message) {}

    public function envelope(): Envelope
    {
        return new Envelope(subject: $this->message->title);
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.notification',
            with: ['message' => $this->message],
        );
    }
}
