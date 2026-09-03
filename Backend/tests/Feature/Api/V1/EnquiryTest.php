<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1;

use App\Models\Enquiry;
use App\Models\Role;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class EnquiryTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    public function test_receptionist_can_create_an_enquiry(): void
    {
        $gym = $this->createGym();
        $receptionist = $this->createUser($gym, Role::RECEPTIONIST);

        $response = $this->actingAs($receptionist, 'sanctum')->postJson('/api/v1/enquiries', [
            'name' => 'Lead One',
            'mobile' => '9111100001',
            'source' => 'Walk-in',
        ]);

        $response->assertCreated()->assertJsonPath('data.status', 'new');
        $this->assertDatabaseHas('enquiries', ['mobile' => '9111100001']);
    }

    public function test_trainer_cannot_create_an_enquiry(): void
    {
        $gym = $this->createGym();
        $trainer = $this->createUser($gym, Role::TRAINER);

        $response = $this->actingAs($trainer, 'sanctum')->postJson('/api/v1/enquiries', [
            'name' => 'Lead Two',
            'mobile' => '9111100002',
        ]);

        $response->assertForbidden();
    }

    public function test_conversion_stats_computes_rate_correctly(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);

        Enquiry::query()->create(['gym_id' => $gym->id, 'name' => 'A', 'mobile' => '1', 'status' => Enquiry::STATUS_CONVERTED]);
        Enquiry::query()->create(['gym_id' => $gym->id, 'name' => 'B', 'mobile' => '2', 'status' => Enquiry::STATUS_CONVERTED]);
        Enquiry::query()->create(['gym_id' => $gym->id, 'name' => 'C', 'mobile' => '3', 'status' => Enquiry::STATUS_LOST]);
        Enquiry::query()->create(['gym_id' => $gym->id, 'name' => 'D', 'mobile' => '4', 'status' => Enquiry::STATUS_NEW]);

        $response = $this->actingAs($admin, 'sanctum')->getJson('/api/v1/enquiries-stats/conversion');

        $response->assertOk()
            ->assertJsonPath('data.total', 4)
            ->assertJsonPath('data.converted', 2);
        $this->assertEquals(50, $response->json('data.conversion_rate'));
    }

    public function test_enquiry_status_can_be_updated(): void
    {
        $gym = $this->createGym();
        $receptionist = $this->createUser($gym, Role::RECEPTIONIST);
        $enquiry = Enquiry::query()->create([
            'gym_id' => $gym->id,
            'name' => 'Lead Three',
            'mobile' => '9111100003',
            'status' => Enquiry::STATUS_NEW,
        ]);

        $response = $this->actingAs($receptionist, 'sanctum')->putJson("/api/v1/enquiries/{$enquiry->id}", [
            'status' => 'contacted',
        ]);

        $response->assertOk()->assertJsonPath('data.status', 'contacted');
    }
}
