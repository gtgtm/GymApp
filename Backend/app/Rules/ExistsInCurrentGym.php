<?php

declare(strict_types=1);

namespace App\Rules;

use App\Models\UserGymMembership;
use App\Services\ActingGymContext;
use Illuminate\Contracts\Validation\ValidationRule;

/**
 * Like the built-in `exists:table,column` rule, but scopes the lookup to the
 * current request's acting gym so it can't validate a foreign ID that
 * belongs to a different tenant.
 *
 * The plain `exists:table,column` rule runs a raw DB query and does NOT apply
 * Eloquent global scopes, so it will happily validate a foreign ID that belongs
 * to a different gym. That ID then gets stored as-is and, wherever the owning
 * relation is eager-loaded in a response, leaks the other tenant's row.
 *
 * Works for two kinds of models:
 * - Models using the BelongsToGym trait (their own GymScope already filters
 *   `Model::query()` to the current gym, so no extra column is needed).
 * - App\Models\User specifically (staff foreign keys like trainer_id,
 *   assigned_staff_id): User has no GymScope of its own, and — since a
 *   person can now belong to several gyms via UserGymMembership — a plain
 *   `users.gym_id` comparison is no longer sufficient to prove they are
 *   staff AT THIS GYM. Pass 'gym_id' as $gymIdColumn to opt into this path.
 */
class ExistsInCurrentGym implements ValidationRule
{
    /**
     * @param  class-string<\Illuminate\Database\Eloquent\Model>  $modelClass
     * @param  string|null  $gymIdColumn  Pass 'gym_id' when validating a User id.
     */
    public function __construct(
        private readonly string $modelClass,
        private readonly ?string $gymIdColumn = null,
    ) {}

    public function validate(string $attribute, mixed $value, \Closure $fail): void
    {
        if ($this->gymIdColumn !== null) {
            $this->validateUserMembership($attribute, $value, $fail);

            return;
        }

        if (! $this->modelClass::query()->whereKey($value)->exists()) {
            $fail("The selected {$attribute} is invalid.");
        }
    }

    private function validateUserMembership(string $attribute, mixed $value, \Closure $fail): void
    {
        $gymId = app(ActingGymContext::class)->gymId();

        $hasActiveMembership = $gymId !== null && UserGymMembership::query()
            ->where('user_id', $value)
            ->where('gym_id', $gymId)
            ->where('status', UserGymMembership::STATUS_ACTIVE)
            ->exists();

        if (! $hasActiveMembership) {
            $fail("The selected {$attribute} is invalid.");
        }
    }
}
