<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreMembershipPlanRequest;
use App\Http\Requests\Api\V1\UpdateMembershipPlanRequest;
use App\Models\MembershipPlan;
use App\Services\AuditLogService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MembershipPlanController extends Controller
{
    public function __construct(private readonly AuditLogService $auditLog) {}

    public function index(Request $request): JsonResponse
    {
        $plans = MembershipPlan::query()
            ->when($request->string('status')->isNotEmpty(), fn ($query) => $query->where('status', $request->string('status')->value()))
            ->orderBy('price')
            ->get();

        return $this->success($plans);
    }

    public function store(StoreMembershipPlanRequest $request): JsonResponse
    {
        $plan = MembershipPlan::query()->create([
            ...$request->validated(),
            'status' => $request->validated('status') ?? 'active',
        ]);

        $this->auditLog->log('membership_plan.created', $plan, null, $plan->toArray());

        return $this->success($plan, status: 201);
    }

    public function show(MembershipPlan $membershipPlan): JsonResponse
    {
        return $this->success($membershipPlan);
    }

    public function update(UpdateMembershipPlanRequest $request, MembershipPlan $membershipPlan): JsonResponse
    {
        $before = $membershipPlan->toArray();
        $membershipPlan->update($request->validated());

        $this->auditLog->log('membership_plan.updated', $membershipPlan, $before, $membershipPlan->toArray());

        return $this->success($membershipPlan);
    }

    public function destroy(MembershipPlan $membershipPlan): JsonResponse
    {
        $this->auditLog->log('membership_plan.deleted', $membershipPlan, $membershipPlan->toArray());
        $membershipPlan->delete();

        return $this->success(['message' => 'Membership plan deleted.']);
    }
}
