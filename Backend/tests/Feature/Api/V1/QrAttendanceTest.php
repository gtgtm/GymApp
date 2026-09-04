<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1;

use App\Models\Member;
use App\Models\MembershipPlan;
use App\Models\Role;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class QrAttendanceTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    private function memberWithMembership($gym, int $endInDays): Member
    {
        $plan = MembershipPlan::query()->create([
            'gym_id' => $gym->id, 'name' => 'Monthly', 'duration_days' => 30,
            'price' => 1000, 'total_amount' => 1000, 'status' => 'active',
        ]);
        $member = Member::query()->create([
            'gym_id' => $gym->id,
            'member_code' => 'MEM-QR1',
            'qr_token' => 'QR-TOKEN-123',
            'full_name' => 'Scanned Member',
            'mobile' => '9222233333',
            'joining_date' => now()->subDays(30),
            'status' => 'active',
        ]);
        $member->memberships()->create([
            'gym_id' => $gym->id, 'membership_plan_id' => $plan->id,
            'start_date' => now()->subDays(30 - $endInDays), 'end_date' => now()->addDays($endInDays), 'status' => 'active',
        ]);

        return $member;
    }

    public function test_scanning_a_valid_qr_marks_attendance(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        $member = $this->memberWithMembership($gym, 10);

        $response = $this->actingAs($admin, 'sanctum')->postJson('/api/v1/attendance/scan-qr', [
            'qr_token' => 'QR-TOKEN-123',
        ]);

        $response->assertCreated()->assertJsonPath('data.attendance.status', 'present');
        $this->assertDatabaseHas('attendance', ['member_id' => $member->id, 'marked_via' => 'qr']);
    }

    public function test_scanning_an_unknown_qr_token_returns_404(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);

        $response = $this->actingAs($admin, 'sanctum')->postJson('/api/v1/attendance/scan-qr', [
            'qr_token' => 'DOES-NOT-EXIST',
        ]);

        $response->assertNotFound();
    }

    public function test_scanning_qr_for_expired_membership_warns_instead_of_marking(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        $member = $this->memberWithMembership($gym, -3);

        $response = $this->actingAs($admin, 'sanctum')->postJson('/api/v1/attendance/scan-qr', [
            'qr_token' => 'QR-TOKEN-123',
        ]);

        $response->assertUnprocessable();
        $this->assertDatabaseMissing('attendance', ['member_id' => $member->id]);
    }

    public function test_cannot_scan_another_gyms_member_qr_token(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $adminA = $this->createUser($gymA, Role::ADMIN);
        $this->memberWithMembership($gymB, 10);

        $response = $this->actingAs($adminA, 'sanctum')->postJson('/api/v1/attendance/scan-qr', [
            'qr_token' => 'QR-TOKEN-123',
        ]);

        $response->assertNotFound();
    }
}
