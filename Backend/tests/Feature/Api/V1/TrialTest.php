<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1;

use App\Models\Role;
use App\Models\Trial;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class TrialTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    public function test_receptionist_can_create_a_trial(): void
    {
        $gym = $this->createGym();
        $receptionist = $this->createUser($gym, Role::RECEPTIONIST);

        $response = $this->actingAs($receptionist, 'sanctum')->postJson('/api/v1/trials', [
            'name' => 'Trial Person',
            'mobile' => '9222200001',
            'trial_start' => now()->toDateString(),
            'trial_end' => now()->addDays(3)->toDateString(),
        ]);

        $response->assertCreated()->assertJsonPath('data.status', 'active');
    }

    public function test_trial_end_must_be_after_or_equal_start(): void
    {
        $gym = $this->createGym();
        $receptionist = $this->createUser($gym, Role::RECEPTIONIST);

        $response = $this->actingAs($receptionist, 'sanctum')->postJson('/api/v1/trials', [
            'name' => 'Trial Person',
            'mobile' => '9222200002',
            'trial_start' => now()->toDateString(),
            'trial_end' => now()->subDay()->toDateString(),
        ]);

        $response->assertUnprocessable()->assertJsonValidationErrors(['trial_end']);
    }

    public function test_expiring_soon_only_returns_active_trials_ending_within_3_days(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);

        Trial::query()->create([
            'gym_id' => $gym->id,
            'name' => 'Expiring Soon',
            'mobile' => '9222200003',
            'trial_start' => now()->subDays(2),
            'trial_end' => now()->addDay(),
            'status' => Trial::STATUS_ACTIVE,
        ]);

        Trial::query()->create([
            'gym_id' => $gym->id,
            'name' => 'Not Expiring Soon',
            'mobile' => '9222200004',
            'trial_start' => now(),
            'trial_end' => now()->addDays(10),
            'status' => Trial::STATUS_ACTIVE,
        ]);

        Trial::query()->create([
            'gym_id' => $gym->id,
            'name' => 'Already Converted',
            'mobile' => '9222200005',
            'trial_start' => now()->subDays(2),
            'trial_end' => now()->addDay(),
            'status' => Trial::STATUS_CONVERTED,
        ]);

        $response = $this->actingAs($admin, 'sanctum')->getJson('/api/v1/trials-expiring-soon');

        $response->assertOk()->assertJsonCount(1, 'data');
        $this->assertSame('Expiring Soon', $response->json('data.0.name'));
    }
}
