<?php

declare(strict_types=1);

namespace App\Services\Reports;

use App\Models\Enquiry;
use App\Models\MembershipPlan;
use App\Models\Trial;
use Illuminate\Support\Carbon;

class SalesReportService
{
    public function summary(Carbon $from, Carbon $to): array
    {
        $leads = Enquiry::query()->whereBetween('created_at', [$from->startOfDay(), $to->endOfDay()])->count();
        $converted = Enquiry::query()
            ->where('status', Enquiry::STATUS_CONVERTED)
            ->whereBetween('created_at', [$from->startOfDay(), $to->endOfDay()])
            ->count();

        $trials = Trial::query()->whereBetween('created_at', [$from->startOfDay(), $to->endOfDay()])->count();
        $trialsConverted = Trial::query()
            ->where('status', Trial::STATUS_CONVERTED)
            ->whereBetween('created_at', [$from->startOfDay(), $to->endOfDay()])
            ->count();

        return [
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
            'leads' => $leads,
            'converted_leads' => $converted,
            'conversion_rate' => $leads > 0 ? round(($converted / $leads) * 100, 1) : 0,
            'trials' => $trials,
            'trials_converted' => $trialsConverted,
            'trial_conversion_rate' => $trials > 0 ? round(($trialsConverted / $trials) * 100, 1) : 0,
        ];
    }

    public function revenueByPlan(Carbon $from, Carbon $to): array
    {
        return MembershipPlan::query()
            ->withCount(['memberships as sold_count' => function ($query) use ($from, $to) {
                $query->whereBetween('created_at', [$from->startOfDay(), $to->endOfDay()]);
            }])
            ->get()
            ->map(fn (MembershipPlan $plan) => [
                'plan' => $plan->name,
                'sold_count' => $plan->sold_count,
                'estimated_revenue' => (float) $plan->total_amount * $plan->sold_count,
            ])
            ->sortByDesc('estimated_revenue')
            ->values()
            ->all();
    }
}
