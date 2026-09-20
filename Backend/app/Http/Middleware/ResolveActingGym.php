<?php

declare(strict_types=1);

namespace App\Http\Middleware;

use App\Models\Gym;
use App\Models\Role;
use App\Models\UserGymMembership;
use App\Services\ActingGymContext;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Resolves which gym the current request is scoped to, for every role —
 * the single tenancy chokepoint that GymScope, BelongsToGym, and
 * User::hasRole() all read from (see ActingGymContext).
 *
 * Branches:
 *   A. Platform admin (super_admin): X-Gym-Id, if present, is honoured
 *      after checking the gym exists — no membership row required, since
 *      super_admin has no gym of its own.
 *   B. Everyone else, X-Gym-Id present: must have an ACTIVE membership at
 *      that gym, and that gym itself must be active, or the request is
 *      rejected. Never reveals whether a gym exists to a non-member.
 *   C. Everyone else, no X-Gym-Id: auto-resolved if there is exactly one
 *      active membership (keeps every existing single-gym client working
 *      unchanged); left unresolved if none (GymScope fails closed); a 409
 *      asking the caller to pick, if there is more than one.
 *
 * Two kinds of routes are exempt from being BLOCKED by branch B/C (a 403 or
 * 409 before the controller ever runs): auth-bootstrapping endpoints
 * (logout/me/my-gyms/switch-gym, which a multi-gym user must be able to
 * call before picking a gym) and anything gated by role:super_admin
 * (platform-level by definition). Exempt only means "don't force a
 * selection" — if X-Gym-Id IS sent on an exempt route, it is still
 * resolved into ActingGymContext (e.g. so GET /me can echo back
 * acting_gym), just without failing the request when it can't be.
 */
class ResolveActingGym
{
    private const NEVER_REQUIRE_GYM_ROUTE_NAMES = [
        'logout', 'me', 'my-gyms', 'my-gyms-pending', 'membership-accept', 'switch-gym',
    ];

    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (! $user) {
            return $next($request);
        }

        $gymId = $request->header('X-Gym-Id');
        $context = app(ActingGymContext::class);
        $mustResolve = ! $this->neverRequiresGym($request);

        if ($user->hasRole(Role::SUPER_ADMIN)) {
            return $this->resolvePlatformAdmin($request, $next, $context, $gymId);
        }

        if ($gymId !== null) {
            return $this->resolveWithHeader($request, $next, $context, $user, (int) $gymId, $mustResolve);
        }

        return $this->resolveWithoutHeader($request, $next, $context, $user, $mustResolve);
    }

    private function neverRequiresGym(Request $request): bool
    {
        $route = $request->route();

        if ($route === null) {
            return false;
        }

        if (in_array($route->getName(), self::NEVER_REQUIRE_GYM_ROUTE_NAMES, true)) {
            return true;
        }

        // The whole platform/subscriptions/subscription-plans surface is
        // gated by role:super_admin and is gym-less by definition.
        foreach ($route->gatherMiddleware() as $middleware) {
            if ($middleware === 'role:super_admin' || str_starts_with($middleware, 'role:super_admin,')) {
                return true;
            }
        }

        return false;
    }

    private function resolvePlatformAdmin(Request $request, Closure $next, ActingGymContext $context, ?string $gymId): Response
    {
        if ($gymId === null) {
            return $next($request);
        }

        if (! Gym::query()->whereKey($gymId)->exists()) {
            return $this->errorResponse('Gym not found.', 404);
        }

        $context->set((int) $gymId);
        $context->markPlatformImpersonation();

        return $next($request);
    }

    private function resolveWithHeader(Request $request, Closure $next, ActingGymContext $context, $user, int $gymId, bool $mustResolve): Response
    {
        $membership = UserGymMembership::query()
            ->where('user_id', $user->id)
            ->where('gym_id', $gymId)
            ->where('status', UserGymMembership::STATUS_ACTIVE)
            ->with('role')
            ->first();

        if (! $membership) {
            if (! $mustResolve) {
                return $next($request);
            }

            // Deliberately identical whether the gym doesn't exist or the
            // caller simply isn't a member of it — never confirms a gym id.
            return $this->errorResponse('You are not a member of this gym.', 403);
        }

        $gym = Gym::query()->find($gymId);

        if ($gym === null || $gym->status !== 'active') {
            if (! $mustResolve) {
                return $next($request);
            }

            return $this->errorResponse('This gym has been disabled.', 403);
        }

        $context->setMembership($membership);

        return $next($request);
    }

    private function resolveWithoutHeader(Request $request, Closure $next, ActingGymContext $context, $user, bool $mustResolve): Response
    {
        $activeMemberships = UserGymMembership::query()
            ->where('user_id', $user->id)
            ->where('status', UserGymMembership::STATUS_ACTIVE)
            ->with(['role', 'gym'])
            ->get();

        if ($activeMemberships->isEmpty()) {
            // No membership to resolve; let GymScope fail closed downstream
            // rather than guessing (matches today's "no gym context" path).
            return $next($request);
        }

        if ($activeMemberships->count() === 1) {
            $context->setMembership($activeMemberships->first());

            return $next($request);
        }

        if (! $mustResolve) {
            return $next($request);
        }

        return $this->errorResponse(
            'Select which gym you want to act as.',
            409,
            code: 'gym_selection_required',
            extra: [
                'memberships' => $activeMemberships->map(fn (UserGymMembership $membership) => [
                    'gym_id' => $membership->gym_id,
                    'gym_name' => $membership->gym?->name,
                    'role' => $membership->role?->name,
                ])->values(),
            ],
        );
    }

    /**
     * Matches Controller::fail()'s { message, errors } shape, extended with
     * two additive, optional fields (code, memberships) that older clients
     * simply won't read.
     */
    private function errorResponse(string $message, int $status, ?string $code = null, array $extra = []): Response
    {
        return response()->json([
            'success' => false,
            'data' => null,
            'error' => [
                'message' => $message,
                'errors' => null,
                'code' => $code,
                ...$extra,
            ],
        ], $status);
    }
}
