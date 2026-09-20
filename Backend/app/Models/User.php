<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use App\Services\ActingGymContext;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

#[Fillable(['last_acting_gym_id', 'role_id', 'name', 'email', 'phone', 'password', 'status'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function role(): BelongsTo
    {
        return $this->belongsTo(Role::class);
    }

    public function assignedMembers(): HasMany
    {
        return $this->hasMany(Member::class, 'trainer_id');
    }

    /**
     * All member profiles this login is linked to, one per gym it is a
     * member at (see UserGymMembership: a person can now be a member at
     * more than one gym). Prefer currentMemberProfile() when you want
     * "the one for the gym this request is acting as" — this exists for
     * anywhere that genuinely needs all of them.
     */
    public function memberProfiles(): HasMany
    {
        return $this->hasMany(Member::class, 'user_id');
    }

    /**
     * The member profile for the gym THIS request is acting as, resolved
     * via the acting membership's member_id rather than by relying on
     * Member's own GymScope as a side effect — explicit is safer here
     * since this is the entire member-portal surface's tenancy boundary.
     */
    public function currentMemberProfile(): ?Member
    {
        $membership = app(ActingGymContext::class)->membership();

        if ($membership === null || $membership->member_id === null) {
            return null;
        }

        return $this->memberProfiles()->whereKey($membership->member_id)->first();
    }

    /**
     * Every gym this user has a membership row for, regardless of status.
     */
    public function gymMemberships(): HasMany
    {
        return $this->hasMany(UserGymMembership::class);
    }

    public function gyms(): BelongsToMany
    {
        return $this->belongsToMany(Gym::class, 'user_gym_memberships')
            ->withPivot(['role_id', 'member_id', 'status', 'joined_at'])
            ->withTimestamps();
    }

    public function activeMembershipFor(int $gymId): ?UserGymMembership
    {
        return $this->gymMemberships()
            ->where('gym_id', $gymId)
            ->where('status', UserGymMembership::STATUS_ACTIVE)
            ->first();
    }

    /**
     * Everyone with an active membership at $gymId in one of $roleNames —
     * e.g. "find this gym's admins to notify". Prefer this over
     * User::where('gym_id', ...): a person's presence at a gym is defined
     * by UserGymMembership now, not by users.gym_id (which is only ever a
     * post-login UX convenience — see last_acting_gym_id).
     *
     * @param  string[]  $roleNames
     * @return \Illuminate\Support\Collection<int, self>
     */
    public static function staffAtGymWithRole(int $gymId, array $roleNames): \Illuminate\Support\Collection
    {
        return self::query()
            ->whereHas('gymMemberships', function ($query) use ($gymId, $roleNames): void {
                $query->where('gym_id', $gymId)
                    ->where('status', UserGymMembership::STATUS_ACTIVE)
                    ->whereHas('role', fn ($roleQuery) => $roleQuery->whereIn('name', $roleNames));
            })
            ->get();
    }

    public function hasRole(string ...$roles): bool
    {
        if (! $this->role) {
            return false;
        }

        // super_admin has no gym-scoped role — it is a platform-level
        // designation on users.role_id, never a UserGymMembership row (see
        // that model's docblock). Acting as a gym (X-Gym-Id, see
        // ResolveActingGym) makes it behave as that gym's admin everywhere
        // hasRole() is checked, so callers never special-case it.
        if ($this->role->name === Role::SUPER_ADMIN) {
            return in_array(Role::SUPER_ADMIN, $roles, true)
                || (in_array(Role::ADMIN, $roles, true) && app(ActingGymContext::class)->gymId() !== null);
        }

        // Everyone else's role is per-gym: the same login can be a trainer
        // at one gym and a member at another (see UserGymMembership), so
        // the authoritative answer is whichever membership ResolveActingGym
        // resolved for *this* request, not the legacy users.role_id column.
        $actingRoleName = app(ActingGymContext::class)->roleName();

        if ($actingRoleName !== null) {
            return in_array($actingRoleName, $roles, true);
        }

        // No acting gym was resolved (e.g. the caller has zero memberships,
        // or hit a route exempt from requiring one) — nothing to check
        // against, so no role can be truthfully claimed.
        return false;
    }
}
