<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1;

use App\Models\GymNotification;
use App\Models\Role;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class NotificationTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    public function test_user_sees_only_their_own_notifications(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        $otherAdmin = $this->createUser($gym, Role::ADMIN);

        GymNotification::query()->create([
            'gym_id' => $gym->id,
            'user_id' => $admin->id,
            'type' => 'test',
            'title' => 'Mine',
        ]);
        GymNotification::query()->create([
            'gym_id' => $gym->id,
            'user_id' => $otherAdmin->id,
            'type' => 'test',
            'title' => 'Not mine',
        ]);

        $response = $this->actingAs($admin, 'sanctum')->getJson('/api/v1/notifications');

        $response->assertOk()->assertJsonCount(1, 'data');
        $this->assertSame('Mine', $response->json('data.0.title'));
    }

    public function test_unread_count_reflects_only_unread_notifications(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);

        GymNotification::query()->create([
            'gym_id' => $gym->id, 'user_id' => $admin->id, 'type' => 'test', 'title' => 'Unread',
        ]);
        GymNotification::query()->create([
            'gym_id' => $gym->id, 'user_id' => $admin->id, 'type' => 'test', 'title' => 'Read', 'read_at' => now(),
        ]);

        $response = $this->actingAs($admin, 'sanctum')->getJson('/api/v1/notifications');

        $response->assertOk()->assertJsonPath('meta.unread_count', 1);
    }

    public function test_user_cannot_mark_another_users_notification_as_read(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        $otherAdmin = $this->createUser($gym, Role::ADMIN);

        $notification = GymNotification::query()->create([
            'gym_id' => $gym->id, 'user_id' => $otherAdmin->id, 'type' => 'test', 'title' => 'Not mine',
        ]);

        $response = $this->actingAs($admin, 'sanctum')->putJson("/api/v1/notifications/{$notification->id}/read");

        $response->assertForbidden();
    }

    public function test_creating_a_payment_generates_an_in_app_notification(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        $member = \App\Models\Member::query()->create([
            'gym_id' => $gym->id,
            'member_code' => 'MEM-1',
            'full_name' => 'Payer',
            'mobile' => '9444400001',
            'joining_date' => now(),
            'status' => 'active',
        ]);

        $this->actingAs($admin, 'sanctum')->postJson('/api/v1/payments', [
            'member_id' => $member->id,
            'amount' => 500,
            'method' => 'cash',
        ])->assertCreated();

        $this->assertDatabaseHas('notifications', [
            'user_id' => $admin->id,
            'type' => GymNotification::TYPE_PAYMENT_RECEIPT,
        ]);
    }

    public function test_creating_an_enquiry_notifies_admins(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        $receptionist = $this->createUser($gym, Role::RECEPTIONIST);

        $this->actingAs($receptionist, 'sanctum')->postJson('/api/v1/enquiries', [
            'name' => 'New Lead',
            'mobile' => '9444400002',
        ])->assertCreated();

        $this->assertDatabaseHas('notifications', [
            'user_id' => $admin->id,
            'type' => GymNotification::TYPE_NEW_ENQUIRY,
        ]);
    }
}
