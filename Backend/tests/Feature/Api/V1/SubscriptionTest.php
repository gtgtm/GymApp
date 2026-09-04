<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1;

use App\Models\Member;
use App\Models\Role;
use App\Models\Subscription;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class SubscriptionTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    public function test_super_admin_can_create_a_subscription(): void
    {
        $gym = $this->createGym();
        $superAdmin = $this->createUser($gym, Role::SUPER_ADMIN);

        $response = $this->actingAs($superAdmin, 'sanctum')->postJson('/api/v1/subscriptions', [
            'gym_id' => $gym->id,
            'plan' => 'starter',
            'start_date' => now()->toDateString(),
            'expiry_date' => now()->addYear()->toDateString(),
        ]);

        $response->assertCreated()->assertJsonPath('data.member_limit', 300);
    }

    public function test_gym_admin_cannot_create_a_subscription(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);

        $response = $this->actingAs($admin, 'sanctum')->postJson('/api/v1/subscriptions', [
            'gym_id' => $gym->id,
            'plan' => 'enterprise',
            'start_date' => now()->toDateString(),
            'expiry_date' => now()->addYear()->toDateString(),
        ]);

        $response->assertForbidden();
    }

    public function test_gym_admin_can_view_their_own_subscription_only(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        Subscription::query()->create([
            'gym_id' => $gym->id,
            'plan' => Subscription::PLAN_PROFESSIONAL,
            'member_limit' => 1000,
            'start_date' => now(),
            'expiry_date' => now()->addYear(),
        ]);

        $response = $this->actingAs($admin, 'sanctum')->getJson('/api/v1/subscriptions/mine');

        $response->assertOk()->assertJsonPath('data.plan', 'professional');
    }

    public function test_member_creation_is_blocked_once_limit_reached(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        Subscription::query()->create([
            'gym_id' => $gym->id,
            'plan' => Subscription::PLAN_STARTER,
            'member_limit' => 1,
            'start_date' => now(),
            'expiry_date' => now()->addYear(),
        ]);
        Member::query()->create([
            'gym_id' => $gym->id, 'member_code' => 'MEM-1', 'full_name' => 'Existing Member',
            'mobile' => '9888800001', 'joining_date' => now(), 'status' => 'active',
        ]);

        $response = $this->actingAs($admin, 'sanctum')->postJson('/api/v1/members', [
            'full_name' => 'Overflow Member',
            'mobile' => '9888800002',
            'joining_date' => now()->toDateString(),
        ]);

        $response->assertForbidden();
    }

    public function test_member_creation_is_allowed_under_the_limit(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        Subscription::query()->create([
            'gym_id' => $gym->id,
            'plan' => Subscription::PLAN_STARTER,
            'member_limit' => 300,
            'start_date' => now(),
            'expiry_date' => now()->addYear(),
        ]);

        $response = $this->actingAs($admin, 'sanctum')->postJson('/api/v1/members', [
            'full_name' => 'New Member',
            'mobile' => '9888800003',
            'joining_date' => now()->toDateString(),
        ]);

        $response->assertCreated();
    }

    public function test_enterprise_plan_has_unlimited_members(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        Subscription::query()->create([
            'gym_id' => $gym->id,
            'plan' => Subscription::PLAN_ENTERPRISE,
            'member_limit' => null,
            'start_date' => now(),
            'expiry_date' => now()->addYear(),
        ]);

        for ($i = 0; $i < 3; $i++) {
            Member::query()->create([
                'gym_id' => $gym->id, 'member_code' => "MEM-{$i}", 'full_name' => "Member {$i}",
                'mobile' => "988880001{$i}", 'joining_date' => now(), 'status' => 'active',
            ]);
        }

        $response = $this->actingAs($admin, 'sanctum')->postJson('/api/v1/members', [
            'full_name' => 'One More Member',
            'mobile' => '9888800020',
            'joining_date' => now()->toDateString(),
        ]);

        $response->assertCreated();
    }

    public function test_no_subscription_means_no_limit_enforced(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);

        $response = $this->actingAs($admin, 'sanctum')->postJson('/api/v1/members', [
            'full_name' => 'Member Without Subscription',
            'mobile' => '9888800030',
            'joining_date' => now()->toDateString(),
        ]);

        $response->assertCreated();
    }
}
