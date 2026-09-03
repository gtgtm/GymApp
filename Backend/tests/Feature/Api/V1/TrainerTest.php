<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1;

use App\Models\Role;
use App\Models\Trainer;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class TrainerTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    public function test_admin_can_create_a_trainer(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        $this->createRole(Role::TRAINER);

        $response = $this->actingAs($admin, 'sanctum')->postJson('/api/v1/trainers', [
            'name' => 'New Trainer',
            'email' => 'newtrainer@test.local',
            'password' => 'password123',
            'specialization' => 'Yoga',
        ]);

        $response->assertCreated()
            ->assertJsonPath('data.specialization', 'Yoga')
            ->assertJsonPath('data.user.name', 'New Trainer');

        $this->assertDatabaseHas('users', ['email' => 'newtrainer@test.local']);
        $this->assertDatabaseHas('trainers', ['specialization' => 'Yoga']);
    }

    public function test_trainer_creation_requires_unique_email(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN, ['email' => 'taken@test.local']);
        $this->createRole(Role::TRAINER);

        $response = $this->actingAs($admin, 'sanctum')->postJson('/api/v1/trainers', [
            'name' => 'Dup Trainer',
            'email' => 'taken@test.local',
            'password' => 'password123',
        ]);

        $response->assertUnprocessable()->assertJsonValidationErrors(['email']);
    }

    public function test_non_admin_cannot_create_a_trainer(): void
    {
        $gym = $this->createGym();
        $receptionist = $this->createUser($gym, Role::RECEPTIONIST);
        $this->createRole(Role::TRAINER);

        $response = $this->actingAs($receptionist, 'sanctum')->postJson('/api/v1/trainers', [
            'name' => 'New Trainer',
            'email' => 'newtrainer2@test.local',
            'password' => 'password123',
        ]);

        $response->assertForbidden();
    }

    public function test_trainer_index_reports_assigned_member_count(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        $trainerUser = $this->createUser($gym, Role::TRAINER);
        $trainer = Trainer::query()->create([
            'gym_id' => $gym->id,
            'user_id' => $trainerUser->id,
            'status' => 'active',
        ]);

        \App\Models\Member::query()->create([
            'gym_id' => $gym->id,
            'member_code' => 'MEM-1',
            'full_name' => 'Assigned Member',
            'mobile' => '9888888888',
            'joining_date' => now(),
            'trainer_id' => $trainerUser->id,
            'status' => 'active',
        ]);

        $response = $this->actingAs($admin, 'sanctum')->getJson('/api/v1/trainers');

        $response->assertOk();
        $this->assertSame(1, $response->json('data.0.assigned_members_count'));
    }
}
