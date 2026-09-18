<?php

declare(strict_types=1);

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserHasRole
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        // User::hasRole() already treats a super_admin acting as a gym (see
        // ResolveActingGym) as that gym's admin, so no special-casing needed
        // here.
        if (! $request->user()?->hasRole(...$roles)) {
            return response()->json([
                'success' => false,
                'data' => null,
                'error' => ['message' => 'You do not have permission to perform this action.'],
            ], 403);
        }

        return $next($request);
    }
}
