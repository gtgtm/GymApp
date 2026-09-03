<?php

declare(strict_types=1);

namespace App\Services\Suggestions\Rules;

use App\Models\Membership;
use App\Services\Suggestions\Suggestion;
use App\Services\Suggestions\SuggestionRule;

class PopularPlanRule implements SuggestionRule
{
    private const MIN_SAMPLE_SIZE = 3;

    public function generate(): array
    {
        $topPlan = Membership::query()
            ->where('memberships.status', 'active')
            ->join('membership_plans', 'memberships.membership_plan_id', '=', 'membership_plans.id')
            ->selectRaw('membership_plans.name as plan_name, count(*) as count')
            ->groupBy('membership_plans.name')
            ->orderByDesc('count')
            ->first();

        if (! $topPlan || $topPlan->count < self::MIN_SAMPLE_SIZE) {
            return [];
        }

        return [
            new Suggestion(
                category: 'business',
                message: "Most members prefer the {$topPlan->plan_name} plan.",
                actionLabel: 'View Plans',
                actionRoute: '/plans',
                severity: 'info',
            ),
        ];
    }
}
