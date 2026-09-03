<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1;

use App\Models\Enquiry;
use App\Models\Member;
use App\Models\Membership;
use App\Models\MembershipPlan;
use App\Models\MembershipRenewal;
use App\Models\Role;
use App\Models\Trial;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class AiSuggestionTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    public function test_suggests_expiring_memberships(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        $plan = MembershipPlan::query()->create([
            'gym_id' => $gym->id, 'name' => 'Monthly', 'duration_days' => 30, 'price' => 1000, 'total_amount' => 1000,
        ]);
        $member = Member::query()->create([
            'gym_id' => $gym->id, 'member_code' => 'MEM-1', 'full_name' => 'Expiring Member',
            'mobile' => '9777700001', 'joining_date' => now(), 'status' => 'active',
        ]);
        Membership::query()->create([
            'gym_id' => $gym->id, 'member_id' => $member->id, 'membership_plan_id' => $plan->id,
            'start_date' => now()->subDays(28), 'end_date' => now()->addDays(2), 'status' => 'active',
        ]);

        $response = $this->actingAs($admin, 'sanctum')->getJson('/api/v1/ai/suggestions');

        $response->assertOk();
        $categories = collect($response->json('data'))->pluck('category');
        $this->assertTrue($categories->contains('memberships'));
    }

    public function test_no_suggestions_when_nothing_notable(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);

        $response = $this->actingAs($admin, 'sanctum')->getJson('/api/v1/ai/suggestions');

        $response->assertOk()->assertJsonCount(0, 'data');
    }

    public function test_suggests_pending_payments_when_amount_due_exists(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        $plan = MembershipPlan::query()->create([
            'gym_id' => $gym->id, 'name' => 'Monthly', 'duration_days' => 30, 'price' => 1000, 'total_amount' => 1000,
        ]);
        $member = Member::query()->create([
            'gym_id' => $gym->id, 'member_code' => 'MEM-1', 'full_name' => 'Partial Payer',
            'mobile' => '9777700002', 'joining_date' => now(), 'status' => 'active',
        ]);
        $membership = Membership::query()->create([
            'gym_id' => $gym->id, 'member_id' => $member->id, 'membership_plan_id' => $plan->id,
            'start_date' => now(), 'end_date' => now()->addDays(30), 'status' => 'active',
        ]);
        MembershipRenewal::query()->create([
            'gym_id' => $gym->id, 'membership_id' => $membership->id, 'membership_plan_id' => $plan->id,
            'previous_expiry' => now(), 'new_expiry' => now()->addDays(30),
            'amount_paid' => 500, 'amount_due' => 500, 'payment_method' => 'cash', 'renewed_by' => $admin->id,
        ]);

        $response = $this->actingAs($admin, 'sanctum')->getJson('/api/v1/ai/suggestions');

        $categories = collect($response->json('data'))->pluck('category');
        $this->assertTrue($categories->contains('payments'));
    }

    public function test_suggests_uncontacted_leads_older_than_3_days(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);

        $enquiry = Enquiry::query()->create([
            'gym_id' => $gym->id, 'name' => 'Stale Lead', 'mobile' => '9777700003', 'status' => Enquiry::STATUS_NEW,
        ]);
        $enquiry->forceFill(['created_at' => now()->subDays(5)])->save();

        $response = $this->actingAs($admin, 'sanctum')->getJson('/api/v1/ai/suggestions');

        $categories = collect($response->json('data'))->pluck('category');
        $this->assertTrue($categories->contains('sales'));
    }

    public function test_does_not_suggest_recently_created_leads(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);

        Enquiry::query()->create([
            'gym_id' => $gym->id, 'name' => 'Fresh Lead', 'mobile' => '9777700004', 'status' => Enquiry::STATUS_NEW,
        ]);

        $response = $this->actingAs($admin, 'sanctum')->getJson('/api/v1/ai/suggestions');

        $categories = collect($response->json('data'))->pluck('category');
        $this->assertFalse($categories->contains('sales'));
    }

    public function test_suggests_trials_expiring_soon(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);

        Trial::query()->create([
            'gym_id' => $gym->id, 'name' => 'Trial User', 'mobile' => '9777700005',
            'trial_start' => now()->subDay(), 'trial_end' => now()->addDay(), 'status' => Trial::STATUS_ACTIVE,
        ]);

        $response = $this->actingAs($admin, 'sanctum')->getJson('/api/v1/ai/suggestions');

        $messages = collect($response->json('data'))->pluck('message')->implode(' ');
        $this->assertStringContainsString('trial member(s) should be contacted', $messages);
    }

    public function test_trainer_cannot_access_ai_suggestions(): void
    {
        $gym = $this->createGym();
        $trainer = $this->createUser($gym, Role::TRAINER);

        $response = $this->actingAs($trainer, 'sanctum')->getJson('/api/v1/ai/suggestions');

        $response->assertForbidden();
    }
}
