<?php

declare(strict_types=1);

namespace App\Services\Suggestions\Rules;

use App\Models\Membership;
use App\Services\Suggestions\Suggestion;
use App\Services\Suggestions\SuggestionRule;
use Illuminate\Support\Carbon;

class ExpiringMembershipsRule implements SuggestionRule
{
    public function generate(): array
    {
        $count = Membership::query()
            ->where('status', 'active')
            ->whereBetween('end_date', [Carbon::today(), Carbon::today()->addDays(7)])
            ->count();

        if ($count === 0) {
            return [];
        }

        return [
            new Suggestion(
                category: 'memberships',
                message: "{$count} membership(s) will expire within 7 days.",
                actionLabel: 'View Members',
                actionRoute: '/members?status=expiring',
                severity: 'warning',
            ),
        ];
    }
}
