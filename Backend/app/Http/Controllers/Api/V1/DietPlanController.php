<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreDietPlanRequest;
use App\Models\DietPlan;
use App\Services\AuditLogService;
use App\Services\DietPlanService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DietPlanController extends Controller
{
    public function __construct(
        private readonly DietPlanService $dietPlanService,
        private readonly AuditLogService $auditLog,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $plans = DietPlan::query()
            ->with('meals', 'trainer.user:id,name')
            ->when($request->integer('member_id'), fn ($query, $memberId) => $query->where('member_id', $memberId))
            ->latest()
            ->get();

        return $this->success($plans->map(fn (DietPlan $plan) => [
            ...$plan->toArray(),
            'daily_summary' => $plan->dailySummary(),
        ]));
    }

    public function store(StoreDietPlanRequest $request): JsonResponse
    {
        $plan = $this->dietPlanService->create($request->validated());

        $this->auditLog->log('diet_plan.created', $plan, null, $plan->toArray());

        return $this->success([
            ...$plan->toArray(),
            'daily_summary' => $plan->dailySummary(),
        ], status: 201);
    }

    public function show(DietPlan $dietPlan): JsonResponse
    {
        $dietPlan->load('meals', 'trainer.user:id,name');

        return $this->success([
            ...$dietPlan->toArray(),
            'daily_summary' => $dietPlan->dailySummary(),
        ]);
    }

    public function update(StoreDietPlanRequest $request, DietPlan $dietPlan): JsonResponse
    {
        $before = $dietPlan->toArray();
        $updated = $this->dietPlanService->update($dietPlan, $request->validated());

        $this->auditLog->log('diet_plan.updated', $dietPlan, $before, $updated->toArray());

        return $this->success([
            ...$updated->toArray(),
            'daily_summary' => $updated->dailySummary(),
        ]);
    }

    public function destroy(DietPlan $dietPlan): JsonResponse
    {
        $this->auditLog->log('diet_plan.deleted', $dietPlan, $dietPlan->toArray());
        $dietPlan->delete();

        return $this->success(['message' => 'Diet plan deleted.']);
    }
}
