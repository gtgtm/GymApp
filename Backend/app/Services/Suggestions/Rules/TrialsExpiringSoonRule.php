<?php

declare(strict_types=1);

namespace App\Services\Suggestions\Rules;

use App\Models\Trial;
use App\Services\Suggestions\Suggestion;
use App\Services\Suggestions\SuggestionRule;
use Illuminate\Support\Carbon;

class TrialsExpiringSoonRule implements SuggestionRule
{
    public function generate(): array
    {
        $count = Trial::query()
            ->where('status', Trial::STATUS_ACTIVE)
            ->whereBetween('trial_end', [Carbon::today(), Carbon::today()->addDays(3)])
            ->count();

        if ($count === 0) {
            return [];
        }

        return [
            new Suggestion(
                category: 'sales',
                message: "{$count} trial member(s) should be contacted today about converting to a membership.",
                actionLabel: 'View Trials',
                actionRoute: '/trials',
                severity: 'warning',
            ),
        ];
    }
}
