<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1;

use App\Models\Equipment;
use App\Models\Role;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class EquipmentTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    public function test_admin_can_create_equipment(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);

        $response = $this->actingAs($admin, 'sanctum')->postJson('/api/v1/equipment', [
            'name' => 'Treadmill #2',
            'category' => 'Cardio',
            'purchase_price' => 85000,
            'condition' => 'good',
        ]);

        $response->assertCreated();
    }

    public function test_trainer_cannot_create_equipment(): void
    {
        $gym = $this->createGym();
        $trainer = $this->createUser($gym, Role::TRAINER);

        $response = $this->actingAs($trainer, 'sanctum')->postJson('/api/v1/equipment', [
            'name' => 'Treadmill #2',
        ]);

        $response->assertForbidden();
    }

    public function test_maintenance_due_returns_only_items_due_within_7_days(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);

        Equipment::query()->create([
            'gym_id' => $gym->id,
            'name' => 'Due Soon',
            'next_maintenance_date' => now()->addDays(3),
        ]);

        Equipment::query()->create([
            'gym_id' => $gym->id,
            'name' => 'Overdue',
            'next_maintenance_date' => now()->subDays(2),
        ]);

        Equipment::query()->create([
            'gym_id' => $gym->id,
            'name' => 'Not Due Yet',
            'next_maintenance_date' => now()->addDays(30),
        ]);

        $response = $this->actingAs($admin, 'sanctum')->getJson('/api/v1/equipment-maintenance-due');

        $response->assertOk()->assertJsonCount(2, 'data');
    }
}
