<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreWorkoutPlanRequest;
use App\Models\WorkoutPlan;
use App\Services\AuditLogService;
use App\Services\WorkoutPlanService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WorkoutPlanController extends Controller
{
    public function __construct(
        private readonly WorkoutPlanService $workoutPlanService,
        private readonly AuditLogService $auditLog,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $plans = WorkoutPlan::query()
            ->with('exercises', 'trainer.user:id,name')
            ->when($request->integer('member_id'), fn ($query, $memberId) => $query->where('member_id', $memberId))
            ->latest()
            ->get();

        return $this->success($plans);
    }

    public function store(StoreWorkoutPlanRequest $request): JsonResponse
    {
        $plan = $this->workoutPlanService->create($request->validated());

        $this->auditLog->log('workout_plan.created', $plan, null, $plan->toArray());

        return $this->success($plan, status: 201);
    }

    public function show(WorkoutPlan $workoutPlan): JsonResponse
    {
        return $this->success($workoutPlan->load('exercises', 'trainer.user:id,name'));
    }

    public function update(StoreWorkoutPlanRequest $request, WorkoutPlan $workoutPlan): JsonResponse
    {
        $before = $workoutPlan->toArray();
        $updated = $this->workoutPlanService->update($workoutPlan, $request->validated());

        $this->auditLog->log('workout_plan.updated', $workoutPlan, $before, $updated->toArray());

        return $this->success($updated);
    }

    public function destroy(WorkoutPlan $workoutPlan): JsonResponse
    {
        $this->auditLog->log('workout_plan.deleted', $workoutPlan, $workoutPlan->toArray());
        $workoutPlan->delete();

        return $this->success(['message' => 'Workout plan deleted.']);
    }
}
