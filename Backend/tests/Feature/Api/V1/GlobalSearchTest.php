<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1;

use App\Models\Enquiry;
use App\Models\Member;
use App\Models\Payment;
use App\Models\Role;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class GlobalSearchTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    public function test_search_finds_member_by_name(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        Member::query()->create([
            'gym_id' => $gym->id, 'member_code' => 'MEM-1', 'full_name' => 'Zebediah Fox',
            'mobile' => '9123400001', 'joining_date' => now(), 'status' => 'active',
        ]);

        $response = $this->actingAs($admin, 'sanctum')->getJson('/api/v1/search?q=Zebediah');

        $response->assertOk()->assertJsonCount(1, 'data.members');
    }

    public function test_search_finds_member_by_mobile(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        Member::query()->create([
            'gym_id' => $gym->id, 'member_code' => 'MEM-1', 'full_name' => 'Someone',
            'mobile' => '9123400002', 'joining_date' => now(), 'status' => 'active',
        ]);

        $response = $this->actingAs($admin, 'sanctum')->getJson('/api/v1/search?q=9123400002');

        $response->assertOk()->assertJsonCount(1, 'data.members');
    }

    public function test_search_finds_payment_by_receipt_number(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        $member = Member::query()->create([
            'gym_id' => $gym->id, 'member_code' => 'MEM-1', 'full_name' => 'Payer',
            'mobile' => '9123400003', 'joining_date' => now(), 'status' => 'active',
        ]);
        Payment::query()->create([
            'gym_id' => $gym->id, 'member_id' => $member->id, 'receipt_number' => 'RCPT-UNIQUE123',
            'amount' => 500, 'method' => 'cash', 'status' => 'completed', 'paid_at' => now(), 'collected_by' => $admin->id,
        ]);

        $response = $this->actingAs($admin, 'sanctum')->getJson('/api/v1/search?q=UNIQUE123');

        $response->assertOk()->assertJsonCount(1, 'data.payments');
    }

    public function test_search_scoped_to_gym_does_not_leak_other_gyms_data(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $adminA = $this->createUser($gymA, Role::ADMIN);

        Member::query()->create([
            'gym_id' => $gymB->id, 'member_code' => 'MEM-1', 'full_name' => 'Gym B Member',
            'mobile' => '9123400004', 'joining_date' => now(), 'status' => 'active',
        ]);

        $response = $this->actingAs($adminA, 'sanctum')->getJson('/api/v1/search?q=Gym B Member');

        $response->assertOk()->assertJsonCount(0, 'data.members');
    }

    public function test_empty_query_returns_empty_results(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);

        $response = $this->actingAs($admin, 'sanctum')->getJson('/api/v1/search?q=');

        $response->assertOk()->assertJsonCount(0, 'data.members');
    }

    public function test_search_finds_enquiry_by_name(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        Enquiry::query()->create([
            'gym_id' => $gym->id, 'name' => 'Unique Lead Name', 'mobile' => '9123400005', 'status' => 'new',
        ]);

        $response = $this->actingAs($admin, 'sanctum')->getJson('/api/v1/search?q=Unique Lead');

        $response->assertOk()->assertJsonCount(1, 'data.enquiries');
    }
}
