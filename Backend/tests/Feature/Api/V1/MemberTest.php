<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1;

use App\Models\Member;
use App\Models\Role;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class MemberTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    public function test_admin_can_create_a_member(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);

        $response = $this->actingAs($admin, 'sanctum')->postJson('/api/v1/members', [
            'full_name' => 'John Doe',
            'mobile' => '9111111111',
            'joining_date' => now()->toDateString(),
        ]);

        $response->assertCreated()
            ->assertJsonPath('data.full_name', 'John Doe')
            ->assertJsonPath('data.expiry_bucket', 'red');

        $this->assertDatabaseHas('members', ['mobile' => '9111111111']);
    }

    public function test_member_creation_requires_full_name_and_mobile(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);

        $response = $this->actingAs($admin, 'sanctum')->postJson('/api/v1/members', [
            'joining_date' => now()->toDateString(),
        ]);

        $response->assertUnprocessable()
            ->assertJsonValidationErrors(['full_name', 'mobile']);
    }

    public function test_member_can_be_updated(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);

        $member = Member::query()->create([
            'gym_id' => $gym->id,
            'member_code' => 'MEM-1',
            'full_name' => 'Old Name',
            'mobile' => '9222222222',
            'joining_date' => now(),
            'status' => 'active',
        ]);

        $response = $this->actingAs($admin, 'sanctum')->putJson("/api/v1/members/{$member->id}", [
            'full_name' => 'New Name',
        ]);

        $response->assertOk()->assertJsonPath('data.full_name', 'New Name');
    }

    public function test_member_can_be_deleted(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);

        $member = Member::query()->create([
            'gym_id' => $gym->id,
            'member_code' => 'MEM-1',
            'full_name' => 'To Delete',
            'mobile' => '9333333333',
            'joining_date' => now(),
            'status' => 'active',
        ]);

        $response = $this->actingAs($admin, 'sanctum')->deleteJson("/api/v1/members/{$member->id}");

        $response->assertOk();
        $this->assertSoftDeleted('members', ['id' => $member->id]);
    }

    public function test_trainer_cannot_create_a_member(): void
    {
        $gym = $this->createGym();
        $trainer = $this->createUser($gym, Role::TRAINER);

        $response = $this->actingAs($trainer, 'sanctum')->postJson('/api/v1/members', [
            'full_name' => 'John Doe',
            'mobile' => '9111111111',
            'joining_date' => now()->toDateString(),
        ]);

        $response->assertForbidden();
    }
}
