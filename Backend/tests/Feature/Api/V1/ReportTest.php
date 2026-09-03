<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1;

use App\Models\Expense;
use App\Models\Member;
use App\Models\Membership;
use App\Models\MembershipPlan;
use App\Models\Payment;
use App\Models\Role;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class ReportTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    public function test_financial_report_computes_profit_from_revenue_and_expenses(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        $member = Member::query()->create([
            'gym_id' => $gym->id, 'member_code' => 'MEM-1', 'full_name' => 'Payer',
            'mobile' => '9666600001', 'joining_date' => now(), 'status' => 'active',
        ]);

        Payment::query()->create([
            'gym_id' => $gym->id, 'member_id' => $member->id, 'receipt_number' => 'RCPT-1',
            'amount' => 5000, 'method' => 'cash', 'status' => 'completed', 'paid_at' => now(), 'collected_by' => $admin->id,
        ]);
        Expense::query()->create([
            'gym_id' => $gym->id, 'category' => 'rent', 'amount' => 2000, 'expense_date' => now(), 'recorded_by' => $admin->id,
        ]);

        $response = $this->actingAs($admin, 'sanctum')->getJson(
            '/api/v1/reports/financial?from='.now()->startOfMonth()->toDateString().'&to='.now()->toDateString(),
        );

        $response->assertOk();
        $this->assertEquals(5000, $response->json('data.summary.revenue'));
        $this->assertEquals(2000, $response->json('data.summary.expenses'));
        $this->assertEquals(3000, $response->json('data.summary.profit'));
    }

    public function test_member_report_plan_distribution_does_not_error_on_status_ambiguity(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        $plan = MembershipPlan::query()->create([
            'gym_id' => $gym->id, 'name' => 'Monthly', 'duration_days' => 30, 'price' => 1000, 'total_amount' => 1000, 'status' => 'active',
        ]);
        $member = Member::query()->create([
            'gym_id' => $gym->id, 'member_code' => 'MEM-1', 'full_name' => 'Member',
            'mobile' => '9666600002', 'joining_date' => now(), 'status' => 'active',
        ]);
        Membership::query()->create([
            'gym_id' => $gym->id, 'member_id' => $member->id, 'membership_plan_id' => $plan->id,
            'start_date' => now(), 'end_date' => now()->addDays(30), 'status' => 'active',
        ]);

        $response = $this->actingAs($admin, 'sanctum')->getJson('/api/v1/reports/members');

        $response->assertOk()->assertJsonPath('data.plan_distribution.0.plan_name', 'Monthly');
    }

    public function test_receptionist_cannot_access_reports(): void
    {
        $gym = $this->createGym();
        $receptionist = $this->createUser($gym, Role::RECEPTIONIST);

        $response = $this->actingAs($receptionist, 'sanctum')->getJson('/api/v1/reports/financial');

        $response->assertForbidden();
    }

    public function test_csv_export_returns_csv_content_type(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);

        $response = $this->actingAs($admin, 'sanctum')->get('/api/v1/reports/members/export/csv');

        $response->assertOk();
        $this->assertStringContainsString('text/csv', $response->headers->get('Content-Type'));
    }

    public function test_sales_report_computes_conversion_rates(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);

        \App\Models\Enquiry::query()->create(['gym_id' => $gym->id, 'name' => 'A', 'mobile' => '1', 'status' => 'converted']);
        \App\Models\Enquiry::query()->create(['gym_id' => $gym->id, 'name' => 'B', 'mobile' => '2', 'status' => 'new']);

        $response = $this->actingAs($admin, 'sanctum')->getJson(
            '/api/v1/reports/sales?from='.now()->startOfMonth()->toDateString().'&to='.now()->toDateString(),
        );

        $response->assertOk();
        $this->assertEquals(2, $response->json('data.summary.leads'));
        $this->assertEquals(50, $response->json('data.summary.conversion_rate'));
    }
}
