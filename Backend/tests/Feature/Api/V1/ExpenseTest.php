<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1;

use App\Models\Role;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class ExpenseTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    public function test_admin_can_create_an_expense(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);

        $response = $this->actingAs($admin, 'sanctum')->postJson('/api/v1/expenses', [
            'category' => 'rent',
            'amount' => 45000,
            'expense_date' => now()->toDateString(),
            'description' => 'Monthly rent',
        ]);

        $response->assertCreated();
        $this->assertDatabaseHas('expenses', ['category' => 'rent', 'amount' => 45000]);
    }

    public function test_receptionist_cannot_create_an_expense(): void
    {
        $gym = $this->createGym();
        $receptionist = $this->createUser($gym, Role::RECEPTIONIST);

        $response = $this->actingAs($receptionist, 'sanctum')->postJson('/api/v1/expenses', [
            'category' => 'rent',
            'amount' => 45000,
            'expense_date' => now()->toDateString(),
        ]);

        $response->assertForbidden();
    }

    public function test_dashboard_computes_net_profit_from_revenue_minus_expenses(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);

        \App\Models\Expense::query()->create([
            'gym_id' => $gym->id,
            'category' => 'rent',
            'amount' => 1000,
            'expense_date' => now(),
            'recorded_by' => $admin->id,
        ]);

        $member = \App\Models\Member::query()->create([
            'gym_id' => $gym->id,
            'member_code' => 'MEM-1',
            'full_name' => 'Payer',
            'mobile' => '9333300001',
            'joining_date' => now(),
            'status' => 'active',
        ]);

        \App\Models\Payment::query()->create([
            'gym_id' => $gym->id,
            'member_id' => $member->id,
            'receipt_number' => 'RCPT-1',
            'amount' => 3000,
            'method' => 'cash',
            'status' => 'completed',
            'paid_at' => now(),
            'collected_by' => $admin->id,
        ]);

        $response = $this->actingAs($admin, 'sanctum')->getJson('/api/v1/dashboard');

        $response->assertOk();
        $this->assertEquals(1000, $response->json('data.summary.monthly_expenses'));
        $this->assertEquals(2000, $response->json('data.summary.monthly_net_profit'));
    }
}
