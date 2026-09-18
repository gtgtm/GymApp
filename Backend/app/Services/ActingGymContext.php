<?php

declare(strict_types=1);

namespace App\Services;

/**
 * Holds the gym a super_admin is currently "acting as" for the duration of
 * a request. Populated only by ResolveActingGym middleware, which verifies
 * the caller is super_admin and the target gym exists before setting this.
 * Regular staff never populate this — their tenancy comes from users.gym_id.
 */
class ActingGymContext
{
    private ?int $gymId = null;

    public function set(int $gymId): void
    {
        $this->gymId = $gymId;
    }

    public function gymId(): ?int
    {
        return $this->gymId;
    }
}
