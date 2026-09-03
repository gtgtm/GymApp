<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\DietPlan;
use Illuminate\Support\Facades\DB;

class DietPlanService
{
    public function create(array $data): DietPlan
    {
        return DB::transaction(function () use ($data) {
            $plan = DietPlan::query()->create([
                'member_id' => $data['member_id'],
                'trainer_id' => $data['trainer_id'] ?? null,
                'name' => $data['name'],
                'notes' => $data['notes'] ?? null,
                'status' => $data['status'] ?? 'active',
            ]);

            $this->syncMeals($plan, $data['meals']);

            return $plan->load('meals');
        });
    }

    public function update(DietPlan $plan, array $data): DietPlan
    {
        return DB::transaction(function () use ($plan, $data) {
            $plan->update(array_filter([
                'trainer_id' => $data['trainer_id'] ?? null,
                'name' => $data['name'] ?? null,
                'notes' => $data['notes'] ?? null,
                'status' => $data['status'] ?? null,
            ], fn ($value) => $value !== null));

            if (isset($data['meals'])) {
                $plan->meals()->delete();
                $this->syncMeals($plan, $data['meals']);
            }

            return $plan->fresh('meals');
        });
    }

    private function syncMeals(DietPlan $plan, array $meals): void
    {
        foreach ($meals as $index => $meal) {
            $plan->meals()->create([
                'gym_id' => $plan->gym_id,
                'meal_slot' => $meal['meal_slot'],
                'food_item' => $meal['food_item'],
                'quantity' => $meal['quantity'] ?? null,
                'calories' => $meal['calories'] ?? null,
                'protein_g' => $meal['protein_g'] ?? null,
                'carbs_g' => $meal['carbs_g'] ?? null,
                'fat_g' => $meal['fat_g'] ?? null,
                'notes' => $meal['notes'] ?? null,
                'sort_order' => $index,
            ]);
        }
    }
}
