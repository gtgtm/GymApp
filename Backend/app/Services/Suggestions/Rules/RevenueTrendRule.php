<?php

declare(strict_types=1);

namespace App\Services\Suggestions\Rules;

use App\Models\Payment;
use App\Services\Suggestions\Suggestion;
use App\Services\Suggestions\SuggestionRule;
use Illuminate\Support\Carbon;

class RevenueTrendRule implements SuggestionRule
{
    public function generate(): array
    {
        $thisMonthStart = Carbon::today()->startOfMonth();
        $lastMonthStart = $thisMonthStart->copy()->subMonth();
        $lastMonthEnd = $thisMonthStart->copy()->subDay()->endOfDay();

        $thisMonthRevenue = (float) Payment::query()
            ->where('paid_at', '>=', $thisMonthStart)
            ->sum('amount');

        $lastMonthRevenue = (float) Payment::query()
            ->whereBetween('paid_at', [$lastMonthStart, $lastMonthEnd])
            ->sum('amount');

        if ($lastMonthRevenue <= 0) {
            return [];
        }

        $percentChange = round((($thisMonthRevenue - $lastMonthRevenue) / $lastMonthRevenue) * 100);

        if (abs($percentChange) < 5) {
            return [];
        }

        $direction = $percentChange > 0 ? 'increased' : 'decreased';

        return [
            new Suggestion(
                category: 'business',
                message: "Your revenue {$direction} ".abs($percentChange).'% compared with last month.',
                actionLabel: 'View Financial Report',
                actionRoute: '/reports/financial',
                severity: $percentChange > 0 ? 'success' : 'warning',
            ),
        ];
    }
}
