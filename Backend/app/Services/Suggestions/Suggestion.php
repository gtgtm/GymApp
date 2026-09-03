<?php

declare(strict_types=1);

namespace App\Services\Suggestions;

readonly class Suggestion
{
    public function __construct(
        public string $category,
        public string $message,
        public string $actionLabel,
        public string $actionRoute,
        public string $severity = 'info',
    ) {}

    public function toArray(): array
    {
        return [
            'category' => $this->category,
            'message' => $this->message,
            'action_label' => $this->actionLabel,
            'action_route' => $this->actionRoute,
            'severity' => $this->severity,
        ];
    }
}
