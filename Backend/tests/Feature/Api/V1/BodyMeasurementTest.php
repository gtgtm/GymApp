<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1;

use App\Models\Member;
use App\Models\Role;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class BodyMeasurementTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    public function test_trainer_can_record_a_body_measurement_with_computed_bmi(): void
    {
        $gym = $this->createGym();
        $trainer = $this->createUser($gym, Role::TRAINER);
        $member = Member::query()->create([
            'gym_id' => $gym->id,
            'member_code' => 'MEM-1',
            'full_name' => 'Test Member',
            'mobile' => '9500000000',
            'joining_date' => now(),
            'status' => 'active',
        ]);

        $response = $this->actingAs($trainer, 'sanctum')->postJson('/api/v1/body-measurements', [
            'member_id' => $member->id,
            'recorded_date' => now()->toDateString(),
            'weight_kg' => 80,
            'height_cm' => 160,
        ]);

        $response->assertCreated();
        $this->assertSame('31.25', $response->json('data.bmi'));
    }

    public function test_measurement_without_height_has_null_bmi(): void
    {
        $gym = $this->createGym();
        $trainer = $this->createUser($gym, Role::TRAINER);
        $member = Member::query()->create([
            'gym_id' => $gym->id,
            'member_code' => 'MEM-1',
            'full_name' => 'Test Member',
            'mobile' => '9500000001',
            'joining_date' => now(),
            'status' => 'active',
        ]);

        $response = $this->actingAs($trainer, 'sanctum')->postJson('/api/v1/body-measurements', [
            'member_id' => $member->id,
            'recorded_date' => now()->toDateString(),
            'weight_kg' => 80,
        ]);

        $response->assertCreated();
        $this->assertNull($response->json('data.bmi'));
    }
}
