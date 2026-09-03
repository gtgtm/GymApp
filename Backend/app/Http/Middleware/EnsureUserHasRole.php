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
