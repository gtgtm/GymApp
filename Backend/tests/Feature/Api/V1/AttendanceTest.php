<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1;

use App\Models\Member;
use App\Models\MembershipPlan;
use App\Models\Role;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class AttendanceTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    private function memberWithMembership(mixed $gym, int $endInDays): Member
    {
        $plan = MembershipPlan::query()->create([
            'gym_id' => $gym->id,
            'name' => 'Monthly',
            'duration_days' => 30,
            'price' => 1000,
            'total_amount' => 1000,
            'status' => 'active',
        ]);

        $member = Member::query()->create([
            'gym_id' => $gym->id,
            'member_code' => 'MEM-'.uniqid(),
            'full_name' => 'Attendee',
            'mobile' => '9'.random_int(100000000, 999999999),
            'joining_date' => now()->subDays(30),
            'status' => 'active',
        ]);

        $member->memberships()->create([
            'gym_id' => $gym->id,
            'membership_plan_id' => $plan->id,
            'start_date' => now()->subDays(30 - $endInDays),
            'end_date' => now()->addDays($endInDays),
            'status' => 'active',
        ]);

        return $member;
    }

    public function test_attendance_is_marked_for_active_member(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        $member = $this->memberWithMembership($gym, 10);

        $response = $this->actingAs($admin, 'sanctum')->postJson('/api/v1/attendance', [
            'member_id' => $member->id,
        ]);

        $response->assertCreated()->assertJsonPath('data.attendance.status', 'present');
        $this->assertDatabaseHas('attendance', ['member_id' => $member->id, 'status' => 'present']);
    }

    public function test_attendance_is_rejected_for_expired_membership(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        $member = $this->memberWithMembership($gym, -5);

        $response = $this->actingAs($admin, 'sanctum')->postJson('/api/v1/attendance', [
            'member_id' => $member->id,
        ]);

        $response->assertUnprocessable()
            ->assertJsonPath('error.message', "This member's membership has expired. Please renew before marking attendance.");

        $this->assertDatabaseMissing('attendance', ['member_id' => $member->id]);
    }

    public function test_attendance_is_idempotent_per_day(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        $member = $this->memberWithMembership($gym, 10);

        $this->actingAs($admin, 'sanctum')->postJson('/api/v1/attendance', ['member_id' => $member->id]);
        $this->actingAs($admin, 'sanctum')->postJson('/api/v1/attendance', ['member_id' => $member->id]);

        $this->assertDatabaseCount('attendance', 1);
    }
}
