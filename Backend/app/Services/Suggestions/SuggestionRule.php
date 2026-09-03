<?php

declare(strict_types=1);

namespace App\Services\Suggestions;

interface SuggestionRule
{
    /**
     * @return Suggestion[]
     */
    public function generate(): array;
}
