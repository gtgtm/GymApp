<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\GymNotification;
use App\Models\Member;
use App\Models\Membership;
use App\Models\MembershipPlan;
use App\Models\MembershipRenewal;
use App\Notifications\NotificationMessage;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class RenewalService
{
    public function __construct(
        private readonly PaymentService $paymentService,
        private readonly NotificationService $notificationService,
    ) {}

    public function renew(Member $member, MembershipPlan $plan, array $data): MembershipRenewal
    {
        return DB::transaction(function () use ($member, $plan, $data) {
            $currentMembership = $member->currentMembership();
            $previousExpiry = $currentMembership && $currentMembership->end_date->isFuture()
                ? $currentMembership->end_date
                : Carbon::today();

            $newExpiry = $previousExpiry->copy()->addDays($plan->duration_days);

            $membership = Membership::query()->create([
                'gym_id' => $member->gym_id,
                'member_id' => $member->id,
                'membership_plan_id' => $plan->id,
                'start_date' => $previousExpiry,
                'end_date' => $newExpiry,
                'status' => 'active',
            ]);

            $amountPaid = (float) $data['amount_paid'];
            $totalDue = (float) $plan->total_amount - (float) ($data['discount'] ?? 0) + (float) ($data['tax'] ?? 0);
            $amountDue = max(0, $totalDue - $amountPaid);

            $renewal = MembershipRenewal::query()->create([
                'gym_id' => $member->gym_id,
                'membership_id' => $membership->id,
                'membership_plan_id' => $plan->id,
                'previous_expiry' => $previousExpiry,
                'new_expiry' => $newExpiry,
                'discount' => $data['discount'] ?? 0,
                'tax' => $data['tax'] ?? 0,
                'amount_paid' => $amountPaid,
                'amount_due' => $amountDue,
                'payment_method' => $data['payment_method'],
                'renewed_by' => auth()->id(),
            ]);

            $this->paymentService->create([
                'gym_id' => $member->gym_id,
                'member_id' => $member->id,
                'amount' => $amountPaid,
                'discount' => $data['discount'] ?? 0,
                'tax' => $data['tax'] ?? 0,
                'method' => $data['payment_method'],
            ]);

            if (auth()->user()) {
                $this->notificationService->notify(
                    auth()->user(),
                    new NotificationMessage(
                        type: GymNotification::TYPE_RENEWAL_CONFIRMATION,
                        title: "Membership renewed for {$member->full_name}",
                        body: "New expiry: {$newExpiry->toDateString()}.",
                        data: ['member_id' => $member->id, 'renewal_id' => $renewal->id],
                    ),
                );
            }

            return $renewal;
        });
    }
}
