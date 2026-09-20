<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreSubscriptionPlanRequest;
use App\Http\Requests\Api\V1\UpdateSubscriptionPlanRequest;
use App\Models\SubscriptionPlan;
use App\Services\AuditLogService;
use Illuminate\Http\JsonResponse;

/**
 * Platform-level catalog of SaaS billing tiers (super_admin only). Distinct
 * from MembershipPlanController, which manages a gym's own member pricing.
 */
class SubscriptionPlanController extends Controller
{
    public function __construct(private readonly AuditLogService $auditLog) {}

    public function index(): JsonResponse
    {
        return $this->success(
            SubscriptionPlan::query()->orderBy('sort_order')->orderBy('name')->get()
        );
    }

    public function store(StoreSubscriptionPlanRequest $request): JsonResponse
    {
        $plan = SubscriptionPlan::query()->create([
            ...$request->validated(),
            'status' => $request->validated('status') ?? 'active',
        ]);

        $this->auditLog->log('subscription_plan.created', $plan, null, $plan->toArray());

        return $this->success($plan, status: 201);
    }

    public function update(UpdateSubscriptionPlanRequest $request, SubscriptionPlan $subscriptionPlan): JsonResponse
    {
        $before = $subscriptionPlan->toArray();
        $subscriptionPlan->update($request->validated());

        $this->auditLog->log(
            'subscription_plan.updated',
            $subscriptionPlan,
            $before,
            $subscriptionPlan->toArray(),
        );

        return $this->success($subscriptionPlan->fresh());
    }

    public function destroy(SubscriptionPlan $subscriptionPlan): JsonResponse
    {
        $this->auditLog->log('subscription_plan.deleted', $subscriptionPlan, $subscriptionPlan->toArray());
        $subscriptionPlan->delete();

        return $this->success(['message' => 'Plan deleted.']);
    }
}
