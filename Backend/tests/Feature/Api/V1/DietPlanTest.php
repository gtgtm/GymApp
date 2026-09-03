<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1;

use App\Models\Member;
use App\Models\Role;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class DietPlanTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    private function member($gym): Member
    {
        return Member::query()->create([
            'gym_id' => $gym->id,
            'member_code' => 'MEM-1',
            'full_name' => 'Test Member',
            'mobile' => '9600000000',
            'joining_date' => now(),
            'status' => 'active',
        ]);
    }

    public function test_trainer_can_create_a_diet_plan_with_daily_summary(): void
    {
        $gym = $this->createGym();
        $trainer = $this->createUser($gym, Role::TRAINER);
        $member = $this->member($gym);

        $response = $this->actingAs($trainer, 'sanctum')->postJson('/api/v1/diet-plans', [
            'member_id' => $member->id,
            'name' => 'Bulking Plan',
            'meals' => [
                ['meal_slot' => 'breakfast', 'food_item' => 'Eggs', 'calories' => 300, 'protein_g' => 20, 'carbs_g' => 5, 'fat_g' => 15],
                ['meal_slot' => 'lunch', 'food_item' => 'Rice & Chicken', 'calories' => 600, 'protein_g' => 40, 'carbs_g' => 70, 'fat_g' => 10],
            ],
        ]);

        $response->assertCreated();
        $this->assertEquals(900, $response->json('data.daily_summary.calories'));
        $this->assertEquals(60, $response->json('data.daily_summary.protein_g'));
    }

    public function test_diet_plan_rejects_invalid_meal_slot(): void
    {
        $gym = $this->createGym();
        $trainer = $this->createUser($gym, Role::TRAINER);
        $member = $this->member($gym);

        $response = $this->actingAs($trainer, 'sanctum')->postJson('/api/v1/diet-plans', [
            'member_id' => $member->id,
            'name' => 'Plan',
            'meals' => [
                ['meal_slot' => 'brunch', 'food_item' => 'Pancakes'],
            ],
        ]);

        $response->assertUnprocessable()->assertJsonValidationErrors(['meals.0.meal_slot']);
    }
}
