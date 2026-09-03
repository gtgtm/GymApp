<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Attendance;
use App\Models\Member;
use App\Models\Membership;
use App\Models\MembershipRenewal;
use App\Models\Payment;
use Illuminate\Support\Carbon;

class DashboardService
{
    public function summary(): array
    {
        $today = Carbon::today();
        $monthStart = $today->copy()->startOfMonth();

        return [
            'total_members' => Member::query()->count(),
            'active_members' => Member::query()->where('status', 'active')->count(),
            'expired_memberships' => Membership::query()->where('end_date', '<', $today)->count(),
            'expiring_soon' => Membership::query()
                ->whereBetween('end_date', [$today, $today->copy()->addDays(15)])
                ->count(),
            'todays_attendance' => Attendance::query()->whereDate('date', $today)->count(),
            'todays_new_members' => Member::query()->whereDate('created_at', $today)->count(),
            'todays_revenue' => (float) Payment::query()->whereDate('paid_at', $today)->sum('amount'),
            'monthly_revenue' => (float) Payment::query()->where('paid_at', '>=', $monthStart)->sum('amount'),
            'pending_payments' => (float) MembershipRenewal::query()->sum('amount_due'),
        ];
    }

    public function expiryBuckets(): array
    {
        $today = Carbon::today();

        $memberships = Membership::query()
            ->with('member:id,full_name,mobile,member_code')
            ->where('status', 'active')
            ->get()
            ->groupBy(function (Membership $membership) use ($today) {
                $daysRemaining = $today->diffInDays($membership->end_date, false);

                return match (true) {
                    $daysRemaining < 0 => 'red',
                    $daysRemaining <= 6 => 'orange',
                    $daysRemaining <= 15 => 'yellow',
                    default => 'green',
                };
            });

        return [
            'green' => $memberships->get('green', collect())->values(),
            'yellow' => $memberships->get('yellow', collect())->values(),
            'orange' => $memberships->get('orange', collect())->values(),
            'red' => $memberships->get('red', collect())->values(),
        ];
    }
}
