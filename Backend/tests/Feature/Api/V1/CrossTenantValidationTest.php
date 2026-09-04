<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1;

use App\Models\Member;
use App\Models\MembershipPlan;
use App\Models\Role;
use App\Models\Trainer;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

/**
 * Laravel's `exists:table,column` validation rule does not respect Eloquent
 * global scopes, so it will validate a foreign ID belonging to a DIFFERENT
 * gym. These tests lock in the fix (App\Rules\ExistsInCurrentGym): every
 * cross-referenced foreign key must be rejected when it points at another
 * tenant's row, even though the row genuinely exists in the table.
 */
class CrossTenantValidationTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    public function test_cannot_record_a_payment_against_another_gyms_member(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $adminA = $this->createUser($gymA, Role::ADMIN);
        $memberB = Member::query()->create([
            'gym_id' => $gymB->id, 'member_code' => 'MEM-B1', 'full_name' => 'Gym B Member',
            'mobile' => '9700000001', 'joining_date' => now(), 'status' => 'active',
        ]);

        $response = $this->actingAs($adminA, 'sanctum')->postJson('/api/v1/payments', [
            'member_id' => $memberB->id,
            'amount' => 500,
            'method' => 'cash',
        ]);

        $response->assertUnprocessable()->assertJsonValidationErrors(['member_id']);
    }

    public function test_cannot_assign_a_member_to_another_gyms_trainer(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $adminA = $this->createUser($gymA, Role::ADMIN);
        $trainerUserB = $this->createUser($gymB, Role::TRAINER);

        $response = $this->actingAs($adminA, 'sanctum')->postJson('/api/v1/members', [
            'full_name' => 'New Member',
            'mobile' => '9700000002',
            'joining_date' => now()->toDateString(),
            'trainer_id' => $trainerUserB->id,
        ]);

        $response->assertUnprocessable()->assertJsonValidationErrors(['trainer_id']);
    }

    public function test_cannot_create_a_workout_plan_with_another_gyms_trainer(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $adminA = $this->createUser($gymA, Role::ADMIN);
        $memberA = Member::query()->create([
            'gym_id' => $gymA->id, 'member_code' => 'MEM-A1', 'full_name' => 'Gym A Member',
            'mobile' => '9700000003', 'joining_date' => now(), 'status' => 'active',
        ]);
        $trainerUserB = $this->createUser($gymB, Role::TRAINER);
        $trainerB = Trainer::query()->create(['gym_id' => $gymB->id, 'user_id' => $trainerUserB->id, 'status' => 'active']);

        $response = $this->actingAs($adminA, 'sanctum')->postJson('/api/v1/workout-plans', [
            'member_id' => $memberA->id,
            'trainer_id' => $trainerB->id,
            'name' => 'Plan',
            'exercises' => [['day_number' => 1, 'exercise_name' => 'Squat']],
        ]);

        $response->assertUnprocessable()->assertJsonValidationErrors(['trainer_id']);
    }

    public function test_cannot_create_an_enquiry_with_another_gyms_membership_plan(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $adminA = $this->createUser($gymA, Role::ADMIN);
        $planB = MembershipPlan::query()->create([
            'gym_id' => $gymB->id, 'name' => 'Monthly', 'duration_days' => 30,
            'price' => 1000, 'total_amount' => 1000, 'status' => 'active',
        ]);

        $response = $this->actingAs($adminA, 'sanctum')->postJson('/api/v1/enquiries', [
            'name' => 'Lead',
            'mobile' => '9700000004',
            'interested_plan_id' => $planB->id,
        ]);

        $response->assertUnprocessable()->assertJsonValidationErrors(['interested_plan_id']);
    }

    public function test_cannot_assign_another_gyms_staff_member_to_an_enquiry(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $adminA = $this->createUser($gymA, Role::ADMIN);
        $staffB = $this->createUser($gymB, Role::RECEPTIONIST);

        $response = $this->actingAs($adminA, 'sanctum')->postJson('/api/v1/enquiries', [
            'name' => 'Lead',
            'mobile' => '9700000005',
            'assigned_staff_id' => $staffB->id,
        ]);

        $response->assertUnprocessable()->assertJsonValidationErrors(['assigned_staff_id']);
    }

    public function test_can_still_assign_own_gyms_trainer_normally(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        $trainerUser = $this->createUser($gym, Role::TRAINER);

        $response = $this->actingAs($admin, 'sanctum')->postJson('/api/v1/members', [
            'full_name' => 'New Member',
            'mobile' => '9700000006',
            'joining_date' => now()->toDateString(),
            'trainer_id' => $trainerUser->id,
        ]);

        $response->assertCreated();
    }
}
