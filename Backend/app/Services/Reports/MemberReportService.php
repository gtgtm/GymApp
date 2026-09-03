<?php

declare(strict_types=1);

namespace App\Services\Reports;

use App\Models\Member;
use App\Models\Membership;
use App\Models\MembershipRenewal;
use Illuminate\Support\Carbon;

class MemberReportService
{
    public function summary(Carbon $from, Carbon $to): array
    {
        $newMembers = Member::query()->whereBetween('created_at', [$from->startOfDay(), $to->endOfDay()])->count();
        $activeMembers = Member::query()->where('status', 'active')->count();
        $expiredMembers = Membership::query()->where('end_date', '<', Carbon::today())->distinct('member_id')->count('member_id');
        $renewals = MembershipRenewal::query()->whereBetween('created_at', [$from->startOfDay(), $to->endOfDay()])->count();

        $totalMembersBeforePeriod = Member::query()->where('created_at', '<', $from->startOfDay())->count();
        $churnRate = $totalMembersBeforePeriod > 0
            ? round(($expiredMembers / $totalMembersBeforePeriod) * 100, 1)
            : 0;

        return [
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
            'new_members' => $newMembers,
            'active_members' => $activeMembers,
            'expired_members' => $expiredMembers,
            'renewals' => $renewals,
            'churn_rate' => $churnRate,
        ];
    }

    public function planDistribution(): array
    {
        return Membership::query()
            ->where('memberships.status', 'active')
            ->join('membership_plans', 'memberships.membership_plan_id', '=', 'membership_plans.id')
            ->selectRaw('membership_plans.name as plan_name, count(*) as count')
            ->groupBy('membership_plans.name')
            ->orderByDesc('count')
            ->get()
            ->map(fn ($row) => ['plan_name' => $row->plan_name, 'count' => (int) $row->count])
            ->all();
    }
}
