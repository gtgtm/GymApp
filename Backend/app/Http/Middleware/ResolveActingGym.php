<?php

declare(strict_types=1);

namespace App\Http\Middleware;

use App\Models\Gym;
use App\Models\Role;
use App\Services\ActingGymContext;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Lets a super_admin scope tenant-owned queries to one gym via the
 * X-Gym-Id header, so the existing gym-admin screens/endpoints work
 * unmodified once "entered" into a gym. Ignored for every other role —
 * their tenancy is fixed to users.gym_id and cannot be overridden.
 */
class ResolveActingGym
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        $gymId = $request->header('X-Gym-Id');

        if ($user?->hasRole(Role::SUPER_ADMIN) && $gymId !== null) {
            if (! Gym::query()->whereKey($gymId)->exists()) {
                return response()->json([
                    'success' => false,
                    'data' => null,
                    'error' => ['message' => 'Gym not found.'],
                ], 404);
            }

            app(ActingGymContext::class)->set((int) $gymId);
        }

        return $next($request);
    }
}
