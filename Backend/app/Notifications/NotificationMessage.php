<?php

declare(strict_types=1);

namespace App\Notifications;

readonly class NotificationMessage
{
    public function __construct(
        public string $type,
        public string $title,
        public ?string $body = null,
        public array $data = [],
    ) {}
}
