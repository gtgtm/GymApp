<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Gym;
use App\Models\Member;
use Illuminate\Http\JsonResponse;

/**
 * Cross-tenant views for super_admin only (see role:super_admin routes).
 * Every query here intentionally spans gyms — do not add BelongsToGym to
 * anything queried in this controller.
 */
class PlatformController extends Controller
{
    public function gyms(): JsonResponse
    {
        $gyms = Gym::query()
            ->withCount(['members' => fn ($query) => $query->withoutGlobalScopes()])
            ->with('currentSubscription')
            ->orderBy('name')
            ->get()
            ->map(fn (Gym $gym) => [
                'id' => $gym->id,
                'name' => $gym->name,
                'slug' => $gym->slug,
                'status' => $gym->status,
                'members_count' => $gym->members_count,
                'subscription' => $gym->currentSubscription,
            ]);

        return $this->success($gyms);
    }

    public function gym(Gym $gym): JsonResponse
    {
        $gym->loadCount(['members' => fn ($query) => $query->withoutGlobalScopes()])
            ->load('currentSubscription');

        $activeMembers = Member::query()
            ->withoutGlobalScopes()
            ->where('gym_id', $gym->id)
            ->where('status', 'active')
            ->count();

        return $this->success([
            'id' => $gym->id,
            'name' => $gym->name,
            'slug' => $gym->slug,
            'email' => $gym->email,
            'phone' => $gym->phone,
            'address' => $gym->address,
            'status' => $gym->status,
            'members_count' => $gym->members_count,
            'active_members_count' => $activeMembers,
            'subscription' => $gym->currentSubscription,
        ]);
    }
}
