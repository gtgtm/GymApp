<?php

declare(strict_types=1);

namespace App\Services\Suggestions\Rules;

use App\Models\Enquiry;
use App\Services\Suggestions\Suggestion;
use App\Services\Suggestions\SuggestionRule;
use Illuminate\Support\Carbon;

class UncontactedLeadsRule implements SuggestionRule
{
    private const STALE_THRESHOLD_DAYS = 3;

    public function generate(): array
    {
        $count = Enquiry::query()
            ->where('status', Enquiry::STATUS_NEW)
            ->where('created_at', '<=', Carbon::now()->subDays(self::STALE_THRESHOLD_DAYS))
            ->count();

        if ($count === 0) {
            return [];
        }

        return [
            new Suggestion(
                category: 'sales',
                message: "{$count} lead(s) have not been contacted in the last ".self::STALE_THRESHOLD_DAYS.' days.',
                actionLabel: 'Contact Lead',
                actionRoute: '/enquiries?status=new',
                severity: 'warning',
            ),
        ];
    }
}
