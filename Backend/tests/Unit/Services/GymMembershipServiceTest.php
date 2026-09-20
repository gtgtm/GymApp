<?php

declare(strict_types=1);

namespace Tests\Unit\Services;

use App\Models\Role;
use App\Models\User;
use App\Models\UserGymMembership;
use App\Services\GymMembershipService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesGymUsers;
use Tests\TestCase;

class GymMembershipServiceTest extends TestCase
{
    use CreatesGymUsers, RefreshDatabase;

    private static int $memberCodeSequence = 0;

    private function service(): GymMembershipService
    {
        return app(GymMembershipService::class);
    }

    /**
     * GymMembershipService itself doesn't assign member_code/qr_token —
     * that's MemberService's job in production (see its
     * generateMemberCode/generateQrToken). Tests exercising the lower-level
     * service directly must supply them, same as any other required column.
     */
    private function baseMemberData(array $overrides): array
    {
        self::$memberCodeSequence++;

        return [
            'member_code' => 'TEST-MEM-'.self::$memberCodeSequence,
            'qr_token' => 'TEST-QR-'.self::$memberCodeSequence,
            ...$overrides,
        ];
    }

    public function test_joining_with_a_brand_new_email_creates_an_account_and_active_membership(): void
    {
        $gym = $this->createGym();
        $this->createRole(Role::MEMBER);

        $member = $this->service()->joinGym($this->baseMemberData([
            'full_name' => 'New Person',
            'mobile' => '9000000001',
            'email' => 'newperson@test.local',
            'joining_date' => now(),
        ]), 'password123', $gym->id);

        $user = User::query()->where('email', 'newperson@test.local')->first();
        $this->assertNotNull($user);
        $this->assertSame($member->id, $user->memberProfiles()->first()->id);

        $membership = UserGymMembership::query()->where('user_id', $user->id)->where('gym_id', $gym->id)->first();
        $this->assertNotNull($membership);
        $this->assertSame(UserGymMembership::STATUS_ACTIVE, $membership->status);
        $this->assertSame($member->id, $membership->member_id);
    }

    public function test_joining_with_no_password_creates_a_front_desk_only_member(): void
    {
        $gym = $this->createGym();
        $this->createRole(Role::MEMBER);

        $member = $this->service()->joinGym($this->baseMemberData([
            'full_name' => 'No Login Person',
            'mobile' => '9000000002',
            'joining_date' => now(),
        ]), null, $gym->id);

        $this->assertNull($member->user_id);
        $this->assertSame(0, UserGymMembership::query()->count());
    }

    public function test_joining_with_an_existing_email_attaches_a_pending_membership_not_a_new_account(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $this->createRole(Role::MEMBER);
        $existingUser = $this->createUser($gymA, Role::ADMIN, ['email' => 'shared@test.local']);
        $originalPasswordHash = $existingUser->password;

        $member = $this->service()->joinGym($this->baseMemberData([
            'full_name' => 'Shared Identity',
            'mobile' => '9000000003',
            'email' => 'shared@test.local',
            'joining_date' => now(),
        ]), 'irrelevant-password', $gymB->id);

        $this->assertSame(1, User::query()->where('email', 'shared@test.local')->count());
        $this->assertSame($existingUser->id, $member->user_id);

        $existingUser->refresh();
        $this->assertSame($originalPasswordHash, $existingUser->password);

        $membership = UserGymMembership::query()
            ->where('user_id', $existingUser->id)
            ->where('gym_id', $gymB->id)
            ->first();
        $this->assertNotNull($membership);
        $this->assertSame(UserGymMembership::STATUS_PENDING, $membership->status);
    }

    public function test_joining_a_gym_the_person_is_already_a_member_of_throws(): void
    {
        $gym = $this->createGym();
        $existingUser = $this->createUser($gym, Role::MEMBER, ['email' => 'already@test.local']);

        $this->expectException(\DomainException::class);

        $this->service()->joinGym($this->baseMemberData([
            'full_name' => 'Already A Member',
            'mobile' => '9000000004',
            'email' => 'already@test.local',
            'joining_date' => now(),
        ]), 'password123', $gym->id);
    }

    public function test_placeholder_emails_never_match_an_existing_account(): void
    {
        $gymA = $this->createGym('Gym A');
        $gymB = $this->createGym('Gym B');
        $this->createRole(Role::MEMBER);

        // Two different members with no real email, each getting their own
        // random placeholder — must never be treated as "the same person".
        $memberA = $this->service()->joinGym($this->baseMemberData([
            'full_name' => 'Placeholder A', 'mobile' => '9000000005', 'joining_date' => now(),
        ]), 'password123', $gymA->id);

        $memberB = $this->service()->joinGym($this->baseMemberData([
            'full_name' => 'Placeholder B', 'mobile' => '9000000006', 'joining_date' => now(),
        ]), 'password123', $gymB->id);

        $this->assertNotSame($memberA->user_id, $memberB->user_id);
        $this->assertSame(2, User::query()->count());
    }

    public function test_accepting_a_pending_membership_activates_it(): void
    {
        $gym = $this->createGym();
        $user = $this->createUser($gym, Role::MEMBER, ['email' => 'pending@test.local']);
        $membership = UserGymMembership::query()->where('user_id', $user->id)->firstOrFail();
        $membership->update(['status' => UserGymMembership::STATUS_PENDING]);

        $accepted = $this->service()->acceptPendingMembership($membership);

        $this->assertSame(UserGymMembership::STATUS_ACTIVE, $accepted->status);
    }
}
