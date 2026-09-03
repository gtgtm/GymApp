<?php

declare(strict_types=1);

namespace App\Services\Suggestions\Rules;

use App\Models\Attendance;
use App\Models\Member;
use App\Services\Suggestions\Suggestion;
use App\Services\Suggestions\SuggestionRule;
use Illuminate\Support\Carbon;

class InactiveMembersRule implements SuggestionRule
{
    private const INACTIVITY_THRESHOLD_DAYS = 7;

    public function generate(): array
    {
        $cutoff = Carbon::today()->subDays(self::INACTIVITY_THRESHOLD_DAYS);

        $recentlyActiveMemberIds = Attendance::query()
            ->where('date', '>=', $cutoff)
            ->distinct()
            ->pluck('member_id');

        $inactiveMembers = Member::query()
            ->where('status', 'active')
            ->whereNotIn('id', $recentlyActiveMemberIds)
            ->whereHas('memberships', fn ($query) => $query->where('end_date', '>=', Carbon::today()))
            ->get(['id', 'full_name']);

        if ($inactiveMembers->isEmpty()) {
            return [];
        }

        if ($inactiveMembers->count() === 1) {
            $member = $inactiveMembers->first();

            return [
                new Suggestion(
                    category: 'engagement',
                    message: "{$member->full_name} has not visited the gym in the last ".self::INACTIVITY_THRESHOLD_DAYS.' days. Consider sending a motivation reminder.',
                    actionLabel: 'View Member',
                    actionRoute: "/members/{$member->id}",
                    severity: 'info',
                ),
            ];
        }

        return [
            new Suggestion(
                category: 'engagement',
                message: "{$inactiveMembers->count()} active members haven't visited in the last ".self::INACTIVITY_THRESHOLD_DAYS.' days.',
                actionLabel: 'View Members',
                actionRoute: '/members',
                severity: 'info',
            ),
        ];
    }
}
