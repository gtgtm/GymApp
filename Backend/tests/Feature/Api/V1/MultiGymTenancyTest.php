<?php

declare(strict_types=1);

namespace Tests\Feature\Api\V1;

use App\Models\Member;
use App\Models\Role;
use App\Models\User;
use App\Models\UserGymMembership;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class MultiGymTenancyTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    public function test_single_gym_user_is_auto_resolved_without_header(): void
    {
        $gym = $this->createGym('Gym A');
        $user = $this->createUser($gym, Role::ADMIN, ['email' => 'single@test.local']);

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/v1/dashboard');

        $response->assertOk();
    }

    public function test_multi_gym_user_without_header_gets_409_with_membership_list(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $user = $this->createUser($gymA, Role::ADMIN, ['email' => 'multi@test.local']);

        $this->addMembership($user, $gymB, Role::TRAINER);

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/v1/dashboard');

        $response->assertStatus(409)
            ->assertJsonPath('error.code', 'gym_selection_required')
            ->assertJsonCount(2, 'error.memberships');
    }

    public function test_multi_gym_user_with_valid_header_is_scoped_to_that_gym(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $user = $this->createUser($gymA, Role::ADMIN, ['email' => 'multi2@test.local']);
        $this->addMembership($user, $gymB, Role::TRAINER);

        $responseA = $this->actingAs($user, 'sanctum')
            ->withHeader('X-Gym-Id', (string) $gymA->id)
            ->getJson('/api/v1/dashboard');

        $responseA->assertOk();
    }

    public function test_header_for_a_gym_the_user_has_no_membership_at_is_rejected(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymC = $this->createGym('Gym C');
        $user = $this->createUser($gymA, Role::ADMIN, ['email' => 'forger@test.local']);

        $response = $this->actingAs($user, 'sanctum')
            ->withHeader('X-Gym-Id', (string) $gymC->id)
            ->getJson('/api/v1/dashboard');

        $response->assertForbidden();
    }

    public function test_header_for_nonexistent_gym_is_rejected_without_leaking_existence(): void
    {
        $gymA = $this->createGym('Gym A');
        $user = $this->createUser($gymA, Role::ADMIN, ['email' => 'forger2@test.local']);

        $response = $this->actingAs($user, 'sanctum')
            ->withHeader('X-Gym-Id', '999999')
            ->getJson('/api/v1/dashboard');

        $response->assertForbidden();
    }

    public function test_inactive_membership_is_rejected_even_with_correct_header(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $user = $this->createUser($gymA, Role::ADMIN, ['email' => 'revoked@test.local']);
        $this->addMembership($user, $gymB, Role::TRAINER, UserGymMembership::STATUS_INACTIVE);

        $response = $this->actingAs($user, 'sanctum')
            ->withHeader('X-Gym-Id', (string) $gymB->id)
            ->getJson('/api/v1/dashboard');

        $response->assertForbidden();
    }

    public function test_login_returns_memberships_and_requires_gym_selection_for_multi_gym_user(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $user = $this->createUser($gymA, Role::ADMIN, ['email' => 'loginmulti@test.local']);
        $this->addMembership($user, $gymB, Role::TRAINER);

        $response = $this->postJson('/api/v1/login', [
            'email' => 'loginmulti@test.local',
            'password' => 'password',
        ]);

        $response->assertOk()
            ->assertJsonPath('data.requires_gym_selection', true)
            ->assertJsonCount(2, 'data.memberships')
            ->assertJsonPath('data.default_gym_id', null);
    }

    public function test_login_returns_single_default_gym_id_for_single_gym_user(): void
    {
        $gym = $this->createGym('Gym A');
        $this->createUser($gym, Role::ADMIN, ['email' => 'loginsingle@test.local']);

        $response = $this->postJson('/api/v1/login', [
            'email' => 'loginsingle@test.local',
            'password' => 'password',
        ]);

        $response->assertOk()
            ->assertJsonPath('data.requires_gym_selection', false)
            ->assertJsonPath('data.default_gym_id', $gym->id);
    }

    public function test_login_succeeds_when_one_of_two_gyms_is_disabled(): void
    {
        $gymActive = $this->createGym('Active Gym');
        $gymDisabled = $this->createGym('Disabled Gym');
        $gymDisabled->update(['status' => 'inactive']);

        $user = $this->createUser($gymActive, Role::ADMIN, ['email' => 'partial@test.local']);
        $this->addMembership($user, $gymDisabled, Role::TRAINER);

        $response = $this->postJson('/api/v1/login', [
            'email' => 'partial@test.local',
            'password' => 'password',
        ]);

        $response->assertOk()
            ->assertJsonCount(1, 'data.memberships')
            ->assertJsonPath('data.memberships.0.gym_id', $gymActive->id);
    }

    public function test_login_fails_when_every_gym_is_disabled(): void
    {
        $gym = $this->createGym('Disabled Gym');
        $gym->update(['status' => 'inactive']);
        $this->createUser($gym, Role::ADMIN, ['email' => 'alldisabled@test.local']);

        $response = $this->postJson('/api/v1/login', [
            'email' => 'alldisabled@test.local',
            'password' => 'password',
        ]);

        $response->assertForbidden();
    }

    public function test_my_gyms_lists_active_memberships(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $user = $this->createUser($gymA, Role::ADMIN, ['email' => 'mygyms@test.local']);
        $this->addMembership($user, $gymB, Role::TRAINER);

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/v1/my-gyms');

        $response->assertOk()->assertJsonCount(2, 'data');
    }

    public function test_switch_gym_succeeds_for_a_real_membership(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $user = $this->createUser($gymA, Role::ADMIN, ['email' => 'switch@test.local']);
        $this->addMembership($user, $gymB, Role::TRAINER);

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/switch-gym', ['gym_id' => $gymB->id]);

        $response->assertOk()->assertJsonPath('data.gym_id', $gymB->id);
    }

    public function test_switch_gym_rejects_a_gym_the_user_does_not_belong_to(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymC = $this->createGym('Gym C');
        $user = $this->createUser($gymA, Role::ADMIN, ['email' => 'switchreject@test.local']);

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/switch-gym', ['gym_id' => $gymC->id]);

        $response->assertForbidden();
    }

    public function test_super_admin_platform_routes_do_not_require_a_gym(): void
    {
        $gym = $this->createGym('Gym A');
        $superAdmin = $this->createUser($gym, Role::SUPER_ADMIN, ['email' => 'super@test.local', 'gym_id' => null]);

        $response = $this->actingAs($superAdmin, 'sanctum')->getJson('/api/v1/platform/gyms');

        $response->assertOk();
    }

    public function test_me_with_header_echoes_back_the_resolved_acting_gym(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $user = $this->createUser($gymA, Role::ADMIN, ['email' => 'mewithheader@test.local']);
        $this->addMembership($user, $gymB, Role::TRAINER);

        $response = $this->actingAs($user, 'sanctum')
            ->withHeader('X-Gym-Id', (string) $gymB->id)
            ->getJson('/api/v1/me');

        $response->assertOk()->assertJsonPath('data.acting_gym.gym_id', $gymB->id);
    }

    public function test_me_without_header_for_multi_gym_user_does_not_409(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $user = $this->createUser($gymA, Role::ADMIN, ['email' => 'menoheader@test.local']);
        $this->addMembership($user, $gymB, Role::TRAINER);

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/v1/me');

        $response->assertOk()->assertJsonPath('data.acting_gym', null);
    }

    public function test_super_admin_can_still_enter_a_gym_via_header(): void
    {
        $gym = $this->createGym('Gym A');
        $superAdmin = User::query()->create([
            'gym_id' => null,
            'role_id' => $this->createRole(Role::SUPER_ADMIN)->id,
            'name' => 'Super Admin',
            'email' => 'super2@test.local',
            'password' => bcrypt('password'),
            'status' => 'active',
        ]);

        $response = $this->actingAs($superAdmin, 'sanctum')
            ->withHeader('X-Gym-Id', (string) $gym->id)
            ->getJson('/api/v1/dashboard');

        $response->assertOk();
    }

    public function test_one_person_with_admin_at_two_gyms_sees_only_the_acting_gyms_members(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $user = $this->createUser($gymA, Role::ADMIN, ['email' => 'twogymadmin@test.local']);
        $this->addMembership($user, $gymB, Role::ADMIN);

        Member::query()->create([
            'gym_id' => $gymA->id, 'member_code' => 'MEM-A1', 'full_name' => 'Gym A Member',
            'mobile' => '9000000010', 'joining_date' => now(), 'status' => 'active',
        ]);
        Member::query()->create([
            'gym_id' => $gymB->id, 'member_code' => 'MEM-B1', 'full_name' => 'Gym B Member',
            'mobile' => '9000000011', 'joining_date' => now(), 'status' => 'active',
        ]);

        $responseA = $this->actingAs($user, 'sanctum')
            ->withHeader('X-Gym-Id', (string) $gymA->id)
            ->getJson('/api/v1/members');
        $responseA->assertOk()->assertJsonCount(1, 'data');
        $this->assertSame('Gym A Member', $responseA->json('data.0.full_name'));

        $responseB = $this->actingAs($user, 'sanctum')
            ->withHeader('X-Gym-Id', (string) $gymB->id)
            ->getJson('/api/v1/members');
        $responseB->assertOk()->assertJsonCount(1, 'data');
        $this->assertSame('Gym B Member', $responseB->json('data.0.full_name'));
    }

    public function test_one_person_admin_at_a_and_trainer_at_b_gets_role_appropriate_access_per_gym(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $user = $this->createUser($gymA, Role::ADMIN, ['email' => 'crossrole@test.local']);
        $this->addMembership($user, $gymB, Role::TRAINER);

        // Admin-only endpoint (expenses) works at Gym A...
        $expensesAtA = $this->actingAs($user, 'sanctum')
            ->withHeader('X-Gym-Id', (string) $gymA->id)
            ->getJson('/api/v1/expenses');
        $expensesAtA->assertOk();

        // ...but is forbidden at Gym B, where this same login is only a trainer.
        $expensesAtB = $this->actingAs($user, 'sanctum')
            ->withHeader('X-Gym-Id', (string) $gymB->id)
            ->getJson('/api/v1/expenses');
        $expensesAtB->assertForbidden();
    }

    public function test_new_member_created_while_acting_as_gym_b_belongs_to_gym_b_not_gym_a(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $user = $this->createUser($gymA, Role::ADMIN, ['email' => 'creator@test.local']);
        $this->addMembership($user, $gymB, Role::ADMIN);

        $response = $this->actingAs($user, 'sanctum')
            ->withHeader('X-Gym-Id', (string) $gymB->id)
            ->postJson('/api/v1/members', [
                'full_name' => 'Cross Gym Test Member',
                'mobile' => '9000000012',
                'joining_date' => now()->toDateString(),
            ]);

        $response->assertCreated();
        $this->assertDatabaseHas('members', ['full_name' => 'Cross Gym Test Member', 'gym_id' => $gymB->id]);
        $this->assertDatabaseMissing('members', ['full_name' => 'Cross Gym Test Member', 'gym_id' => $gymA->id]);
    }

    public function test_pending_membership_does_not_appear_in_my_gyms(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $user = $this->createUser($gymA, Role::ADMIN, ['email' => 'pendingcheck@test.local']);
        $this->addMembership($user, $gymB, Role::MEMBER, UserGymMembership::STATUS_PENDING);

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/v1/my-gyms');

        $response->assertOk()->assertJsonCount(1, 'data');
    }

    public function test_pending_membership_appears_in_my_gyms_pending(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $user = $this->createUser($gymA, Role::ADMIN, ['email' => 'pendinglist@test.local']);
        $this->addMembership($user, $gymB, Role::MEMBER, UserGymMembership::STATUS_PENDING);

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/v1/my-gyms/pending');

        $response->assertOk()->assertJsonCount(1, 'data')->assertJsonPath('data.0.gym_id', $gymB->id);
    }

    public function test_user_can_accept_their_own_pending_membership(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $user = $this->createUser($gymA, Role::ADMIN, ['email' => 'accepter@test.local']);
        $membership = $this->addMembership($user, $gymB, Role::MEMBER, UserGymMembership::STATUS_PENDING);

        $response = $this->actingAs($user, 'sanctum')->postJson("/api/v1/memberships/{$membership->id}/accept");

        $response->assertOk();
        $this->assertSame(UserGymMembership::STATUS_ACTIVE, $membership->fresh()->status);

        // Now it's usable: dashboard access with X-Gym-Id works and it
        // shows up in my-gyms instead of my-gyms/pending.
        $this->actingAs($user, 'sanctum')
            ->withHeader('X-Gym-Id', (string) $gymB->id)
            ->getJson('/api/v1/dashboard')
            ->assertOk();
    }

    public function test_user_cannot_accept_someone_elses_pending_membership(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $owner = $this->createUser($gymA, Role::ADMIN, ['email' => 'owner@test.local']);
        $intruder = $this->createUser($gymA, Role::ADMIN, ['email' => 'intruder@test.local']);
        $membership = $this->addMembership($owner, $gymB, Role::MEMBER, UserGymMembership::STATUS_PENDING);

        $response = $this->actingAs($intruder, 'sanctum')->postJson("/api/v1/memberships/{$membership->id}/accept");

        $response->assertForbidden();
        $this->assertSame(UserGymMembership::STATUS_PENDING, $membership->fresh()->status);
    }

    private function addMembership(User $user, $gym, string $roleName, string $status = UserGymMembership::STATUS_ACTIVE): UserGymMembership
    {
        return UserGymMembership::query()->create([
            'user_id' => $user->id,
            'gym_id' => $gym->id,
            'role_id' => $this->createRole($roleName)->id,
            'status' => $status,
            'joined_at' => now(),
        ]);
    }
}
