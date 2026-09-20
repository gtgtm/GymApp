<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Role;
use App\Models\User;
use App\Models\UserGymMembership;
use App\Services\ActingGymContext;
use App\Services\AuditLogService;
use App\Services\GymMembershipService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function __construct(
        private readonly AuditLogService $auditLog,
        private readonly GymMembershipService $gymMembershipService,
    ) {}

    public function login(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        if ($validator->fails()) {
            return $this->fail('Validation failed.', 422, $validator->errors());
        }

        $credentials = $validator->validated();

        if (! Auth::attempt($credentials)) {
            $this->logFailedAttempt($credentials['email']);

            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        /** @var User $user */
        $user = Auth::user();

        if ($user->status !== 'active') {
            Auth::logout();

            $this->logFailedAttempt($credentials['email'], $user);

            return $this->fail('This account is inactive.', 403);
        }

        $memberships = $user->hasRole(Role::SUPER_ADMIN)
            ? collect()
            : $user->gymMemberships()
                ->where('status', UserGymMembership::STATUS_ACTIVE)
                ->with(['gym', 'role'])
                ->get()
                ->filter(fn (UserGymMembership $membership) => $membership->gym?->status === 'active')
                ->values();

        // A gym-bound user (not super_admin) with zero USABLE memberships —
        // either they have none, or every gym they belong to is disabled —
        // is locked out entirely. A user with at least one active gym can
        // still log in even if another of their gyms is disabled; that gym
        // is simply excluded from `memberships` below.
        if (! $user->hasRole(Role::SUPER_ADMIN) && $memberships->isEmpty()) {
            Auth::logout();

            $this->logFailedAttempt($credentials['email'], $user);

            return $this->fail('This gym has been disabled.', 403);
        }

        $token = $user->createToken('api-token')->plainTextToken;

        $this->auditLog->log('login', $user);

        return $this->success([
            'token' => $token,
            'user' => $this->serializeUser($user, $memberships->count() === 1 ? $memberships->first() : null),
            'memberships' => $memberships->map(fn (UserGymMembership $membership) => $this->serializeMembership($membership)),
            'requires_gym_selection' => $memberships->count() > 1,
            'default_gym_id' => $memberships->count() === 1 ? $memberships->first()->gym_id : null,
        ]);
    }

    /**
     * users.gym_id was dropped (see the Phase 4 migration) — User has no
     * "home gym" relation any more. The `gym` field API clients already
     * read (e.g. the web Admin topbar) is now derived from whichever
     * membership is relevant to this response: the acting one where a
     * request has resolved one, or the caller's sole membership at login
     * time before any gym has been "entered".
     */
    private function serializeUser(User $user, ?UserGymMembership $membershipForGym): array
    {
        return [
            ...$user->load('role')->toArray(),
            'gym' => $membershipForGym?->gym,
        ];
    }

    private function serializeMembership(UserGymMembership $membership): array
    {
        return [
            'id' => $membership->id,
            'gym_id' => $membership->gym_id,
            'gym_name' => $membership->gym?->name,
            'role' => $membership->role?->name,
            'role_label' => $membership->role?->label,
            'member_id' => $membership->member_id,
        ];
    }

    private function logFailedAttempt(string $email, ?User $user = null): void
    {
        $user ??= User::query()->where('email', $email)->first();

        // A failed login has no acting gym to attribute to — the caller
        // never got far enough to pick one. If they have exactly one
        // membership, attribute it there for a slightly more useful audit
        // trail; otherwise leave it null rather than guessing.
        $activeGymIds = $user?->gymMemberships()
            ->where('status', UserGymMembership::STATUS_ACTIVE)
            ->pluck('gym_id') ?? collect();

        AuditLog::query()->create([
            'gym_id' => $activeGymIds->count() === 1 ? $activeGymIds->first() : null,
            'user_id' => $user?->id,
            'action' => 'login_failed',
            'entity_type' => User::class,
            'entity_id' => $user?->id,
            'before' => null,
            'after' => ['email' => $email],
            'ip_address' => request()->ip(),
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        $this->auditLog->log('logout', $request->user());

        return $this->success(['message' => 'Logged out successfully.']);
    }

    public function me(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        $context = app(ActingGymContext::class);

        $memberships = $user->hasRole(Role::SUPER_ADMIN)
            ? collect()
            : $user->gymMemberships()
                ->where('status', UserGymMembership::STATUS_ACTIVE)
                ->with(['gym', 'role'])
                ->get();

        $actingMembership = $context->membership();

        return $this->success([
            ...$this->serializeUser($user, $actingMembership),
            'memberships' => $memberships->map(fn (UserGymMembership $membership) => $this->serializeMembership($membership))->values(),
            'acting_gym' => $actingMembership
                ? $this->serializeMembership($actingMembership)
                : ($context->isPlatformImpersonation() ? ['gym_id' => $context->gymId()] : null),
        ]);
    }

    public function myGyms(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $memberships = $user->gymMemberships()
            ->where('status', UserGymMembership::STATUS_ACTIVE)
            ->with(['gym', 'role'])
            ->get();

        return $this->success(
            $memberships->map(fn (UserGymMembership $membership) => $this->serializeMembership($membership))->values()
        );
    }

    /**
     * Memberships another gym has added this person to by email (see
     * GymMembershipService), awaiting this person's own confirmation
     * before that gym can act on their behalf.
     */
    public function pendingGyms(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $memberships = $user->gymMemberships()
            ->where('status', UserGymMembership::STATUS_PENDING)
            ->with(['gym', 'role'])
            ->get();

        return $this->success(
            $memberships->map(fn (UserGymMembership $membership) => $this->serializeMembership($membership))->values()
        );
    }

    public function acceptGymMembership(Request $request, UserGymMembership $membership): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        // Only the person the membership belongs to can accept it — not
        // staff at the inviting gym, and not anyone else who happens to
        // guess the id.
        abort_unless($membership->user_id === $user->id, 403);

        if ($membership->status !== UserGymMembership::STATUS_PENDING) {
            return $this->fail('This membership is not pending.', 422);
        }

        $accepted = $this->gymMembershipService->acceptPendingMembership($membership);

        return $this->success($this->serializeMembership($accepted));
    }

    public function switchGym(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'gym_id' => ['required', 'integer'],
        ]);

        if ($validator->fails()) {
            return $this->fail('Validation failed.', 422, $validator->errors());
        }

        /** @var User $user */
        $user = $request->user();
        $gymId = $validator->validated('gym_id');

        $membership = $user->gymMemberships()
            ->where('gym_id', $gymId)
            ->where('status', UserGymMembership::STATUS_ACTIVE)
            ->with(['gym', 'role'])
            ->first();

        if (! $membership) {
            return $this->fail('You are not a member of this gym.', 403);
        }

        // Stateless by design: this only validates the membership and
        // records it as a login-time convenience. The client must still
        // send X-Gym-Id on every subsequent request — see
        // ResolveActingGym, which is the only place tenancy is enforced.
        $user->forceFill(['last_acting_gym_id' => $membership->gym_id])->saveQuietly();

        return $this->success($this->serializeMembership($membership));
    }
}
