<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\UserGymMembership;

/**
 * Holds which gym THIS request is scoped to, for every role. Populated
 * exclusively by ResolveActingGym middleware:
 *   - super_admin: X-Gym-Id header, no membership row required
 *     (isPlatformImpersonation() is true in this case).
 *   - everyone else: X-Gym-Id header validated against an active
 *     UserGymMembership, OR auto-resolved when the caller has exactly one.
 */
class ActingGymContext
{
    private ?int $gymId = null;

    private ?UserGymMembership $membership = null;

    private bool $isPlatformImpersonation = false;

    public function set(int $gymId): void
    {
        $this->gymId = $gymId;
    }

    public function setMembership(UserGymMembership $membership): void
    {
        $this->gymId = $membership->gym_id;
        $this->membership = $membership;
    }

    public function markPlatformImpersonation(): void
    {
        $this->isPlatformImpersonation = true;
    }

    public function gymId(): ?int
    {
        return $this->gymId;
    }

    public function membership(): ?UserGymMembership
    {
        return $this->membership;
    }

    public function roleName(): ?string
    {
        return $this->membership?->role?->name;
    }

    public function isPlatformImpersonation(): bool
    {
        return $this->isPlatformImpersonation;
    }
}
