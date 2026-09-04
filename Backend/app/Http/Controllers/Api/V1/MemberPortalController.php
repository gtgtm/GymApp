<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\V1\MemberResource;
use App\Models\DietPlan;
use App\Models\GymNotification;
use App\Models\Member;
use App\Models\Role;
use App\Models\User;
use App\Models\WorkoutPlan;
use App\Notifications\NotificationMessage;
use App\Services\NotificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MemberPortalController extends Controller
{
    public function __construct(private readonly NotificationService $notificationService) {}

    private function currentMember(Request $request): Member
    {
        $member = $request->user()->memberProfile;

        abort_unless($member, 404, 'No member profile is linked to this account.');

        return $member;
    }

    public function profile(Request $request): JsonResponse
    {
        return $this->success(new MemberResource($this->currentMember($request)->load('trainer')));
    }

    public function membership(Request $request): JsonResponse
    {
        $member = $this->currentMember($request);

        return $this->success([
            'current' => $member->currentMembership(),
            'history' => $member->memberships()->with('plan')->orderByDesc('start_date')->get(),
            'expiry_bucket' => $member->expiryBucket(),
        ]);
    }

    public function payments(Request $request): JsonResponse
    {
        $member = $this->currentMember($request);

        return $this->success($member->payments()->latest('paid_at')->get());
    }

    public function attendance(Request $request): JsonResponse
    {
        $member = $this->currentMember($request);

        return $this->success(
            $member->attendance()->latest('date')->limit(90)->get()
        );
    }

    public function qrCode(Request $request): JsonResponse
    {
        $member = $this->currentMember($request);

        return $this->success([
            'qr_token' => $member->qr_token,
            'member_code' => $member->member_code,
        ]);
    }

    public function workoutPlans(Request $request): JsonResponse
    {
        $member = $this->currentMember($request);

        return $this->success(
            WorkoutPlan::query()
                ->where('member_id', $member->id)
                ->where('status', 'active')
                ->with('exercises', 'trainer.user:id,name')
                ->latest()
                ->get()
        );
    }

    public function dietPlans(Request $request): JsonResponse
    {
        $member = $this->currentMember($request);

        $plans = DietPlan::query()
            ->where('member_id', $member->id)
            ->where('status', 'active')
            ->with('meals', 'trainer.user:id,name')
            ->latest()
            ->get();

        return $this->success($plans->map(fn (DietPlan $plan) => [
            ...$plan->toArray(),
            'daily_summary' => $plan->dailySummary(),
        ]));
    }

    public function progress(Request $request): JsonResponse
    {
        $member = $this->currentMember($request);

        return $this->success([
            'measurements' => $member->bodyMeasurements,
            'photos' => $member->progressPhotos,
        ]);
    }

    public function requestRenewal(Request $request): JsonResponse
    {
        $member = $this->currentMember($request);

        $staff = User::query()
            ->where('gym_id', $member->gym_id)
            ->whereHas('role', fn ($query) => $query->whereIn('name', [Role::ADMIN, Role::RECEPTIONIST]))
            ->get();

        $message = new NotificationMessage(
            type: GymNotification::TYPE_RENEWAL_REQUESTED,
            title: "{$member->full_name} requested a membership renewal",
            body: "Member code: {$member->member_code}. Contact them to process the renewal.",
            data: ['member_id' => $member->id],
        );

        foreach ($staff as $staffMember) {
            $this->notificationService->notify($staffMember, $message);
        }

        return $this->success(['message' => 'Renewal request sent. Gym staff will contact you shortly.']);
    }

    public function notifications(Request $request): JsonResponse
    {
        $notifications = GymNotification::query()
            ->where('user_id', $request->user()->id)
            ->latest()
            ->limit(50)
            ->get();

        return $this->success($notifications, [
            'unread_count' => GymNotification::query()
                ->where('user_id', $request->user()->id)
                ->whereNull('read_at')
                ->count(),
        ]);
    }
}
