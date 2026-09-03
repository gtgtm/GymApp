<?php

declare(strict_types=1);

namespace Tests\Feature\Console;

use App\Models\Equipment;
use App\Models\GymNotification;
use App\Models\Member;
use App\Models\Membership;
use App\Models\MembershipPlan;
use App\Models\Role;
use App\Models\Trial;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class NotificationCommandsTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    public function test_notify_expiring_memberships_notifies_admin_only(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        $this->createUser($gym, Role::TRAINER);

        $plan = MembershipPlan::query()->create([
            'gym_id' => $gym->id, 'name' => 'Monthly', 'duration_days' => 30, 'price' => 1000, 'total_amount' => 1000,
        ]);
        $member = Member::query()->create([
            'gym_id' => $gym->id, 'member_code' => 'MEM-1', 'full_name' => 'Expiring Soon',
            'mobile' => '9555500001', 'joining_date' => now(), 'status' => 'active',
        ]);
        Membership::query()->create([
            'gym_id' => $gym->id, 'member_id' => $member->id, 'membership_plan_id' => $plan->id,
            'start_date' => now()->subDays(25), 'end_date' => now()->addDays(3), 'status' => 'active',
        ]);

        $this->artisan('gym:notify-expiring-memberships')->assertExitCode(0);

        $this->assertDatabaseHas('notifications', [
            'user_id' => $admin->id,
            'type' => GymNotification::TYPE_MEMBERSHIP_EXPIRING,
        ]);
        $this->assertDatabaseCount('notifications', 1);
    }

    public function test_notify_expiring_memberships_skips_when_none_expiring(): void
    {
        $gym = $this->createGym();
        $this->createUser($gym, Role::ADMIN);

        $this->artisan('gym:notify-expiring-memberships')->assertExitCode(0);

        $this->assertDatabaseCount('notifications', 0);
    }

    public function test_notify_expiring_trials_notifies_admin_and_receptionist(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);
        $receptionist = $this->createUser($gym, Role::RECEPTIONIST);
        $this->createUser($gym, Role::TRAINER);

        Trial::query()->create([
            'gym_id' => $gym->id, 'name' => 'Trial Person', 'mobile' => '9555500002',
            'trial_start' => now()->subDay(), 'trial_end' => now()->addDays(2), 'status' => Trial::STATUS_ACTIVE,
        ]);

        $this->artisan('gym:notify-expiring-trials')->assertExitCode(0);

        $this->assertDatabaseHas('notifications', ['user_id' => $admin->id, 'type' => GymNotification::TYPE_TRIAL_EXPIRING]);
        $this->assertDatabaseHas('notifications', ['user_id' => $receptionist->id, 'type' => GymNotification::TYPE_TRIAL_EXPIRING]);
        $this->assertDatabaseCount('notifications', 2);
    }

    public function test_notify_equipment_maintenance_only_for_due_items(): void
    {
        $gym = $this->createGym();
        $admin = $this->createUser($gym, Role::ADMIN);

        Equipment::query()->create(['gym_id' => $gym->id, 'name' => 'Due Item', 'next_maintenance_date' => now()->addDays(2)]);
        Equipment::query()->create(['gym_id' => $gym->id, 'name' => 'Not Due', 'next_maintenance_date' => now()->addDays(60)]);

        $this->artisan('gym:notify-equipment-maintenance')->assertExitCode(0);

        $this->assertDatabaseHas('notifications', ['user_id' => $admin->id, 'type' => GymNotification::TYPE_EQUIPMENT_MAINTENANCE]);
        $this->assertDatabaseCount('notifications', 1);
    }

    public function test_notify_pending_payments_skips_when_nothing_due(): void
    {
        $gym = $this->createGym();
        $this->createUser($gym, Role::ADMIN);

        $this->artisan('gym:notify-pending-payments')->assertExitCode(0);

        $this->assertDatabaseCount('notifications', 0);
    }
}
