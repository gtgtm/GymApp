<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1;

use App\Models\Member;
use App\Models\Role;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class WorkoutPlanTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    private function member($gym): Member
    {
        return Member::query()->create([
            'gym_id' => $gym->id,
            'member_code' => 'MEM-1',
            'full_name' => 'Test Member',
            'mobile' => '9700000000',
            'joining_date' => now(),
            'status' => 'active',
        ]);
    }

    public function test_trainer_can_create_a_workout_plan_with_exercises(): void
    {
        $gym = $this->createGym();
        $trainer = $this->createUser($gym, Role::TRAINER);
        $member = $this->member($gym);

        $response = $this->actingAs($trainer, 'sanctum')->postJson('/api/v1/workout-plans', [
            'member_id' => $member->id,
            'name' => 'Push Pull Legs',
            'exercises' => [
                ['day_number' => 1, 'exercise_name' => 'Bench Press', 'sets' => 4, 'reps' => '8'],
                ['day_number' => 2, 'exercise_name' => 'Deadlift', 'sets' => 3, 'reps' => '5'],
            ],
        ]);

        $response->assertCreated()->assertJsonCount(2, 'data.exercises');
        $this->assertDatabaseCount('workout_exercises', 2);
    }

    public function test_workout_plan_requires_at_least_one_exercise(): void
    {
        $gym = $this->createGym();
        $trainer = $this->createUser($gym, Role::TRAINER);
        $member = $this->member($gym);

        $response = $this->actingAs($trainer, 'sanctum')->postJson('/api/v1/workout-plans', [
            'member_id' => $member->id,
            'name' => 'Empty Plan',
            'exercises' => [],
        ]);

        $response->assertUnprocessable()->assertJsonValidationErrors(['exercises']);
    }

    public function test_receptionist_cannot_create_a_workout_plan(): void
    {
        $gym = $this->createGym();
        $receptionist = $this->createUser($gym, Role::RECEPTIONIST);
        $member = $this->member($gym);

        $response = $this->actingAs($receptionist, 'sanctum')->postJson('/api/v1/workout-plans', [
            'member_id' => $member->id,
            'name' => 'Plan',
            'exercises' => [['day_number' => 1, 'exercise_name' => 'Squat']],
        ]);

        $response->assertForbidden();
    }

    public function test_updating_a_workout_plan_replaces_exercises(): void
    {
        $gym = $this->createGym();
        $trainer = $this->createUser($gym, Role::TRAINER);
        $member = $this->member($gym);

        $create = $this->actingAs($trainer, 'sanctum')->postJson('/api/v1/workout-plans', [
            'member_id' => $member->id,
            'name' => 'Plan',
            'exercises' => [
                ['day_number' => 1, 'exercise_name' => 'Bench Press'],
                ['day_number' => 1, 'exercise_name' => 'Tricep Pushdown'],
            ],
        ]);
        $planId = $create->json('data.id');

        $update = $this->actingAs($trainer, 'sanctum')->putJson("/api/v1/workout-plans/{$planId}", [
            'member_id' => $member->id,
            'name' => 'Plan',
            'exercises' => [
                ['day_number' => 1, 'exercise_name' => 'Squat'],
            ],
        ]);

        $update->assertOk()->assertJsonCount(1, 'data.exercises');
        $this->assertDatabaseCount('workout_exercises', 1);
    }
}
