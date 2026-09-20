<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Member;
use App\Models\Role;
use App\Models\User;
use App\Models\UserGymMembership;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * The single path for "a person becomes a member at a gym", whether that
 * person is brand new to the platform or already has a login at a
 * different gym. MemberService::create() delegates here so there is
 * exactly one place that decides what happens to an existing account.
 *
 * Joining a SECOND gym never creates a duplicate users row (email is
 * globally unique) and never touches the existing account's password,
 * name, phone, or status — Gym B must not be able to take over Gym A's
 * credentials for a shared identity. The new membership starts pending:
 * the person must confirm it themselves (see acceptPendingMembership())
 * before Gym B can act on their behalf. This is deliberately NOT
 * auto-accepted — letting any gym attach a real person's account to
 * itself just by knowing their email, with no confirmation, is a privacy
 * leak (a gym could probe whether an email exists on the platform, or
 * silently gain access to someone's history).
 */
class GymMembershipService
{
    /**
     * A never-matchable placeholder domain used for members with no real
     * email — these must never be treated as "the same person" across
     * gyms.
     */
    private const PLACEHOLDER_EMAIL_DOMAIN = '@members.local';

    public function joinGym(array $memberData, ?string $password, int $gymId): Member
    {
        return DB::transaction(function () use ($memberData, $password, $gymId) {
            // Explicit rather than relying on BelongsToGym's creating hook
            // (which reads ActingGymContext) — this service is also called
            // directly by tests/console tooling with no HTTP request in
            // flight to have resolved one.
            $memberData['gym_id'] = $gymId;

            $email = $memberData['email'] ?? null;
            $existingUser = $this->findJoinableUser($email);

            if ($existingUser) {
                return $this->attachExistingUserAsPendingMember($existingUser, $memberData, $gymId);
            }

            return $this->createMemberWithNewAccount($memberData, $password, $gymId);
        });
    }

    /**
     * Confirms a pending membership. Only the member themselves (or staff
     * acting on their behalf with the member's consent, at the UI layer)
     * should call this — enforced by the controller's authorization, not
     * here.
     */
    public function acceptPendingMembership(UserGymMembership $membership): UserGymMembership
    {
        $membership->update(['status' => UserGymMembership::STATUS_ACTIVE]);

        return $membership->fresh();
    }

    private function findJoinableUser(?string $email): ?User
    {
        if ($email === null || str_ends_with($email, self::PLACEHOLDER_EMAIL_DOMAIN)) {
            return null;
        }

        return User::query()->where('email', $email)->first();
    }

    private function attachExistingUserAsPendingMember(User $existingUser, array $memberData, int $gymId): Member
    {
        $alreadyMember = UserGymMembership::query()
            ->where('user_id', $existingUser->id)
            ->where('gym_id', $gymId)
            ->exists();

        if ($alreadyMember) {
            throw new \DomainException('This person already has a membership at this gym.');
        }

        $memberRoleId = Role::query()->where('name', Role::MEMBER)->value('id');
        $memberData['user_id'] = $existingUser->id;
        $member = Member::query()->create($memberData);

        UserGymMembership::query()->create([
            'user_id' => $existingUser->id,
            'gym_id' => $gymId,
            'role_id' => $memberRoleId,
            'member_id' => $member->id,
            'status' => UserGymMembership::STATUS_PENDING,
            'joined_at' => $member->joining_date ?? now(),
        ]);

        return $member;
    }

    private function createMemberWithNewAccount(array $memberData, ?string $password, int $gymId): Member
    {
        $memberUser = $password ? $this->createNewUser($memberData, $password) : null;
        $memberData['user_id'] = $memberUser?->id;

        $member = Member::query()->create($memberData);

        if ($memberUser) {
            $memberRoleId = Role::query()->where('name', Role::MEMBER)->value('id');

            UserGymMembership::query()->create([
                'user_id' => $memberUser->id,
                'gym_id' => $gymId,
                'role_id' => $memberRoleId,
                'member_id' => $member->id,
                'status' => UserGymMembership::STATUS_ACTIVE,
                'joined_at' => $member->joining_date ?? now(),
            ]);
        }

        return $member;
    }

    private function createNewUser(array $memberData, string $password): User
    {
        $memberRoleId = Role::query()->where('name', Role::MEMBER)->value('id');

        return User::query()->create([
            'role_id' => $memberRoleId,
            'name' => $memberData['full_name'],
            'email' => $memberData['email'] ?? $this->placeholderEmail(),
            'phone' => $memberData['mobile'] ?? null,
            'password' => Hash::make($password),
            'status' => 'active',
        ]);
    }

    private function placeholderEmail(): string
    {
        return 'member-'.Str::random(10).self::PLACEHOLDER_EMAIL_DOMAIN;
    }
}
