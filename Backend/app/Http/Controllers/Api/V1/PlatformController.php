<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreGymRequest;
use App\Http\Requests\Api\V1\UpdateGymRequest;
use App\Models\Gym;
use App\Models\Member;
use App\Services\AuditLogService;
use App\Services\GymService;
use Illuminate\Http\JsonResponse;

/**
 * Cross-tenant views for super_admin only (see role:super_admin routes).
 * Every query here intentionally spans gyms — do not add BelongsToGym to
 * anything queried in this controller.
 */
class PlatformController extends Controller
{
    public function __construct(
        private readonly GymService $gymService,
        private readonly AuditLogService $auditLog,
    ) {}

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

    public function store(StoreGymRequest $request): JsonResponse
    {
        $gym = $this->gymService->create($request->validated());

        $this->auditLog->log('gym.created', $gym, null, $gym->toArray(), gymId: $gym->id);

        return $this->success([
            'id' => $gym->id,
            'name' => $gym->name,
            'slug' => $gym->slug,
            'email' => $gym->email,
            'phone' => $gym->phone,
            'address' => $gym->address,
            'status' => $gym->status,
        ], status: 201);
    }

    public function update(UpdateGymRequest $request, Gym $gym): JsonResponse
    {
        $before = $gym->toArray();
        $updated = $this->gymService->update($gym, $request->validated());

        $this->auditLog->log('gym.updated', $gym, $before, $updated->toArray(), gymId: $gym->id);

        return $this->success([
            'id' => $updated->id,
            'name' => $updated->name,
            'slug' => $updated->slug,
            'email' => $updated->email,
            'phone' => $updated->phone,
            'address' => $updated->address,
            'status' => $updated->status,
        ]);
    }
}
