<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1;

use App\Models\Role;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class RoleAccessTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    public function test_member_role_cannot_list_membership_plans(): void
    {
        $gym = $this->createGym();
        $member = $this->createUser($gym, Role::MEMBER);

        $response = $this->actingAs($member, 'sanctum')->getJson('/api/v1/membership-plans');

        $response->assertForbidden();
    }

    public function test_member_role_cannot_list_trainers(): void
    {
        $gym = $this->createGym();
        $member = $this->createUser($gym, Role::MEMBER);

        $response = $this->actingAs($member, 'sanctum')->getJson('/api/v1/trainers');

        $response->assertForbidden();
    }

    public function test_receptionist_cannot_create_a_membership_plan(): void
    {
        $gym = $this->createGym();
        $receptionist = $this->createUser($gym, Role::RECEPTIONIST);

        $response = $this->actingAs($receptionist, 'sanctum')->postJson('/api/v1/membership-plans', [
            'name' => 'New Plan',
            'duration_days' => 30,
            'price' => 1000,
            'total_amount' => 1000,
        ]);

        $response->assertForbidden();
    }

    public function test_trainer_cannot_delete_a_trainer(): void
    {
        $gym = $this->createGym();
        $trainerUser = $this->createUser($gym, Role::TRAINER);
        $otherTrainerUser = $this->createUser($gym, Role::TRAINER);
        $trainer = \App\Models\Trainer::query()->create([
            'gym_id' => $gym->id,
            'user_id' => $otherTrainerUser->id,
            'status' => 'active',
        ]);

        $response = $this->actingAs($trainerUser, 'sanctum')->deleteJson("/api/v1/trainers/{$trainer->id}");

        $response->assertForbidden();
    }

    public function test_member_role_cannot_list_members(): void
    {
        $gym = $this->createGym();
        $member = $this->createUser($gym, Role::MEMBER);

        $response = $this->actingAs($member, 'sanctum')->getJson('/api/v1/members');

        $response->assertForbidden();
    }

    public function test_trainer_cannot_renew_a_membership(): void
    {
        $gym = $this->createGym();
        $trainer = $this->createUser($gym, Role::TRAINER);
        $member = \App\Models\Member::query()->create([
            'gym_id' => $gym->id,
            'member_code' => 'MEM-1',
            'full_name' => 'Renew Me',
            'mobile' => '9444444444',
            'joining_date' => now(),
            'status' => 'active',
        ]);

        $response = $this->actingAs($trainer, 'sanctum')->postJson("/api/v1/members/{$member->id}/renew", []);

        $response->assertForbidden();
    }
}
