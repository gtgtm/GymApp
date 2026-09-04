<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1;

use App\Models\Member;
use App\Models\Membership;
use App\Models\MembershipPlan;
use App\Models\Role;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class MemberPortalTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    private function memberWithAccount($gym): array
    {
        $memberUser = $this->createUser($gym, Role::MEMBER);
        $member = Member::query()->create([
            'gym_id' => $gym->id,
            'user_id' => $memberUser->id,
            'member_code' => 'MEM-1',
            'qr_token' => 'TEST-QR-TOKEN',
            'full_name' => 'Portal Member',
            'mobile' => '9111122222',
            'joining_date' => now(),
            'status' => 'active',
        ]);

        return [$memberUser, $member];
    }

    public function test_member_can_view_own_profile(): void
    {
        $gym = $this->createGym();
        [$memberUser, $member] = $this->memberWithAccount($gym);

        $response = $this->actingAs($memberUser, 'sanctum')->getJson('/api/v1/me/profile');

        $response->assertOk()->assertJsonPath('data.id', $member->id);
    }

    public function test_member_without_linked_profile_gets_404(): void
    {
        $gym = $this->createGym();
        $memberUser = $this->createUser($gym, Role::MEMBER);

        $response = $this->actingAs($memberUser, 'sanctum')->getJson('/api/v1/me/profile');

        $response->assertNotFound();
    }

    public function test_member_cannot_access_another_members_data_via_staff_endpoints(): void
    {
        $gym = $this->createGym();
        [$memberUser] = $this->memberWithAccount($gym);

        $response = $this->actingAs($memberUser, 'sanctum')->getJson('/api/v1/members');

        $response->assertForbidden();
    }

    public function test_member_sees_own_membership_and_expiry_bucket(): void
    {
        $gym = $this->createGym();
        [$memberUser, $member] = $this->memberWithAccount($gym);
        $plan = MembershipPlan::query()->create([
            'gym_id' => $gym->id, 'name' => 'Monthly', 'duration_days' => 30,
            'price' => 1000, 'total_amount' => 1000, 'status' => 'active',
        ]);
        Membership::query()->create([
            'gym_id' => $gym->id, 'member_id' => $member->id, 'membership_plan_id' => $plan->id,
            'start_date' => now(), 'end_date' => now()->addDays(20), 'status' => 'active',
        ]);

        $response = $this->actingAs($memberUser, 'sanctum')->getJson('/api/v1/me/membership');

        $response->assertOk()->assertJsonPath('data.expiry_bucket', 'green');
    }

    public function test_member_can_request_a_renewal_and_staff_get_notified(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        [$memberUser] = $this->memberWithAccount($gym);

        $response = $this->actingAs($memberUser, 'sanctum')->postJson('/api/v1/me/membership/request-renewal');

        $response->assertOk();
        $this->assertDatabaseHas('notifications', [
            'user_id' => $admin->id,
            'type' => 'renewal_requested',
        ]);
    }

    public function test_member_can_view_own_qr_code(): void
    {
        $gym = $this->createGym();
        [$memberUser] = $this->memberWithAccount($gym);

        $response = $this->actingAs($memberUser, 'sanctum')->getJson('/api/v1/me/qr-code');

        $response->assertOk()->assertJsonPath('data.qr_token', 'TEST-QR-TOKEN');
    }
}
