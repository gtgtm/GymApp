<?php

declare(strict_types=1);

namespace App\Http\Middleware;

use App\Models\Gym;
use App\Models\Member;
use App\Services\ActingGymContext;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnforceMemberLimit
{
    public function handle(Request $request, Closure $next): Response
    {
        // Mirrors GymScope's gym resolution: a super_admin has no gym_id of
        // its own, so fall back to the gym it is currently acting as.
        $gymId = $request->user()?->gym_id ?? app(ActingGymContext::class)->gymId();
        $gym = $gymId ? Gym::query()->find($gymId) : null;
        $subscription = $gym?->currentSubscription;

        if ($subscription && ! $subscription->isUnlimited()) {
            $activeMemberCount = Member::query()->count();

            if ($activeMemberCount >= $subscription->member_limit) {
                return response()->json([
                    'success' => false,
                    'data' => null,
                    'error' => [
                        'message' => "Your gym has reached its member limit ({$subscription->member_limit}) for the {$subscription->plan} plan. Upgrade your subscription to add more members.",
                    ],
                ], 403);
            }
        }

        return $next($request);
    }
}
