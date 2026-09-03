<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1;

use App\Models\Member;
use App\Models\Role;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class TenantIsolationTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    public function test_admin_cannot_list_another_gyms_members(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');

        $adminA = $this->createUser($gymA, Role::ADMIN);
        $adminB = $this->createUser($gymB, Role::ADMIN);

        Member::query()->create([
            'gym_id' => $gymA->id,
            'member_code' => 'MEM-A1',
            'full_name' => 'Gym A Member',
            'mobile' => '9000000001',
            'joining_date' => now(),
            'status' => 'active',
        ]);

        $response = $this->actingAs($adminB, 'sanctum')->getJson('/api/v1/members');

        $response->assertOk()->assertJsonCount(0, 'data');
    }

    public function test_admin_cannot_view_another_gyms_member_by_id(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');

        $adminB = $this->createUser($gymB, Role::ADMIN);

        $memberA = Member::query()->create([
            'gym_id' => $gymA->id,
            'member_code' => 'MEM-A1',
            'full_name' => 'Gym A Member',
            'mobile' => '9000000001',
            'joining_date' => now(),
            'status' => 'active',
        ]);

        $response = $this->actingAs($adminB, 'sanctum')->getJson("/api/v1/members/{$memberA->id}");

        $response->assertNotFound();
    }

    public function test_new_member_is_automatically_scoped_to_creators_gym(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);

        $response = $this->actingAs($admin, 'sanctum')->postJson('/api/v1/members', [
            'full_name' => 'New Member',
            'mobile' => '9000000002',
            'joining_date' => now()->toDateString(),
        ]);

        $response->assertCreated();
        $this->assertDatabaseHas('members', [
            'full_name' => 'New Member',
            'gym_id' => $gym->id,
        ]);
    }
}
