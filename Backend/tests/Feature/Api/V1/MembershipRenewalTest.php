<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1;

use App\Models\Member;
use App\Models\MembershipPlan;
use App\Models\Role;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class MembershipRenewalTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    public function test_renewal_extends_from_today_when_no_active_membership(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
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
            'member_code' => 'MEM-1',
            'full_name' => 'New Member',
            'mobile' => '9444444444',
            'joining_date' => now(),
            'status' => 'active',
        ]);

        $today = Carbon::today();

        $response = $this->actingAs($admin, 'sanctum')->postJson("/api/v1/members/{$member->id}/renew", [
            'membership_plan_id' => $plan->id,
            'amount_paid' => 1000,
            'payment_method' => 'cash',
        ]);

        $response->assertCreated();
        $this->assertStringStartsWith($today->toDateString(), $response->json('data.previous_expiry'));
        $this->assertStringStartsWith($today->copy()->addDays(30)->toDateString(), $response->json('data.new_expiry'));
        $this->assertSame('0.00', $response->json('data.amount_due'));
    }

    public function test_renewal_extends_from_existing_expiry_when_membership_still_active(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
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
            'member_code' => 'MEM-1',
            'full_name' => 'Existing Member',
            'mobile' => '9555555555',
            'joining_date' => now()->subDays(20),
            'status' => 'active',
        ]);

        $existingEndDate = Carbon::today()->addDays(10);
        $member->memberships()->create([
            'gym_id' => $gym->id,
            'membership_plan_id' => $plan->id,
            'start_date' => now()->subDays(20),
            'end_date' => $existingEndDate,
            'status' => 'active',
        ]);

        $response = $this->actingAs($admin, 'sanctum')->postJson("/api/v1/members/{$member->id}/renew", [
            'membership_plan_id' => $plan->id,
            'amount_paid' => 1000,
            'payment_method' => 'cash',
        ]);

        $response->assertCreated();
        $this->assertStringStartsWith($existingEndDate->toDateString(), $response->json('data.previous_expiry'));
        $this->assertStringStartsWith($existingEndDate->copy()->addDays(30)->toDateString(), $response->json('data.new_expiry'));
    }

    public function test_renewal_calculates_amount_due_when_underpaid(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
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
            'member_code' => 'MEM-1',
            'full_name' => 'Partial Payer',
            'mobile' => '9666666666',
            'joining_date' => now(),
            'status' => 'active',
        ]);

        $response = $this->actingAs($admin, 'sanctum')->postJson("/api/v1/members/{$member->id}/renew", [
            'membership_plan_id' => $plan->id,
            'amount_paid' => 600,
            'payment_method' => 'cash',
        ]);

        $response->assertCreated();
        $this->assertSame('400.00', $response->json('data.amount_due'));

        $this->assertDatabaseHas('payments', [
            'member_id' => $member->id,
            'amount' => 600,
        ]);
    }

    public function test_receptionist_can_also_renew_membership(): void
    {
        $gym = $this->createGym();
        $receptionist = $this->createUser($gym, Role::RECEPTIONIST);
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
            'member_code' => 'MEM-1',
            'full_name' => 'Member',
            'mobile' => '9777777777',
            'joining_date' => now(),
            'status' => 'active',
        ]);

        $response = $this->actingAs($receptionist, 'sanctum')->postJson("/api/v1/members/{$member->id}/renew", [
            'membership_plan_id' => $plan->id,
            'amount_paid' => 1000,
            'payment_method' => 'upi',
        ]);

        $response->assertCreated();
    }
}
