<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreSubscriptionRequest;
use App\Http\Requests\Api\V1\UpdateSubscriptionRequest;
use App\Models\Gym;
use App\Models\Subscription;
use App\Services\ActingGymContext;
use App\Services\AuditLogService;
use Illuminate\Http\JsonResponse;

class SubscriptionController extends Controller
{
    public function __construct(private readonly AuditLogService $auditLog) {}

    public function index(): JsonResponse
    {
        return $this->success(
            Subscription::query()->with('gym:id,name')->latest('expiry_date')->get()
        );
    }

    public function store(StoreSubscriptionRequest $request): JsonResponse
    {
        $subscription = Subscription::query()->create([
            ...$request->validated(),
            'payment_status' => $request->validated('payment_status') ?? Subscription::STATUS_ACTIVE,
        ]);

        $this->auditLog->log(
            'subscription.created',
            $subscription,
            null,
            $subscription->toArray(),
            gymId: $subscription->gym_id,
        );

        return $this->success($subscription, status: 201);
    }

    public function mine(): JsonResponse
    {
        $gym = Gym::query()->find(app(ActingGymContext::class)->gymId());
        $subscription = $gym?->currentSubscription;

        return $this->success($subscription);
    }

    public function update(UpdateSubscriptionRequest $request, Subscription $subscription): JsonResponse
    {
        $before = $subscription->toArray();
        $subscription->update($request->validated());

        $this->auditLog->log(
            'subscription.updated',
            $subscription,
            $before,
            $subscription->toArray(),
            gymId: $subscription->gym_id,
        );

        return $this->success($subscription->fresh('gym:id,name'));
    }
}
