<?php

declare(strict_types=1);

namespace App\Services\Suggestions\Rules;

use App\Models\MembershipRenewal;
use App\Services\Suggestions\Suggestion;
use App\Services\Suggestions\SuggestionRule;

class PendingPaymentsRule implements SuggestionRule
{
    public function generate(): array
    {
        $totalDue = (float) MembershipRenewal::query()->sum('amount_due');

        if ($totalDue <= 0) {
            return [];
        }

        return [
            new Suggestion(
                category: 'payments',
                message: sprintf('₹%s is pending from members.', number_format($totalDue, 2)),
                actionLabel: 'Collect Payment',
                actionRoute: '/payments',
                severity: 'warning',
            ),
        ];
    }
}
