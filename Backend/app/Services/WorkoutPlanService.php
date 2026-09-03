<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\WorkoutPlan;
use Illuminate\Support\Facades\DB;

class WorkoutPlanService
{
    public function create(array $data): WorkoutPlan
    {
        return DB::transaction(function () use ($data) {
            $plan = WorkoutPlan::query()->create([
                'member_id' => $data['member_id'],
                'trainer_id' => $data['trainer_id'] ?? null,
                'name' => $data['name'],
                'notes' => $data['notes'] ?? null,
                'status' => $data['status'] ?? 'active',
            ]);

            $this->syncExercises($plan, $data['exercises']);

            return $plan->load('exercises');
        });
    }

    public function update(WorkoutPlan $plan, array $data): WorkoutPlan
    {
        return DB::transaction(function () use ($plan, $data) {
            $plan->update(array_filter([
                'trainer_id' => $data['trainer_id'] ?? null,
                'name' => $data['name'] ?? null,
                'notes' => $data['notes'] ?? null,
                'status' => $data['status'] ?? null,
            ], fn ($value) => $value !== null));

            if (isset($data['exercises'])) {
                $plan->exercises()->delete();
                $this->syncExercises($plan, $data['exercises']);
            }

            return $plan->fresh('exercises');
        });
    }

    private function syncExercises(WorkoutPlan $plan, array $exercises): void
    {
        foreach ($exercises as $index => $exercise) {
            $plan->exercises()->create([
                'gym_id' => $plan->gym_id,
                'day_number' => $exercise['day_number'],
                'day_label' => $exercise['day_label'] ?? null,
                'exercise_name' => $exercise['exercise_name'],
                'muscle_group' => $exercise['muscle_group'] ?? null,
                'sets' => $exercise['sets'] ?? null,
                'reps' => $exercise['reps'] ?? null,
                'weight_kg' => $exercise['weight_kg'] ?? null,
                'rest_seconds' => $exercise['rest_seconds'] ?? null,
                'instructions' => $exercise['instructions'] ?? null,
                'video_url' => $exercise['video_url'] ?? null,
                'trainer_notes' => $exercise['trainer_notes'] ?? null,
                'sort_order' => $index,
            ]);
        }
    }
}
