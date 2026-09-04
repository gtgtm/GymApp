<?php

declare(strict_types=1);

namespace App\Rules;

use Illuminate\Contracts\Validation\ValidationRule;

/**
 * Like the built-in `exists:table,column` rule, but scopes the lookup to the
 * current authenticated user's gym so it can't validate a foreign ID that
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
 * - Models without that trait but that still carry a `gym_id` column directly
 *   (e.g. User) — pass the column name explicitly.
 */
class ExistsInCurrentGym implements ValidationRule
{
    /**
     * @param  class-string<\Illuminate\Database\Eloquent\Model>  $modelClass
     * @param  string|null  $gymIdColumn  Pass when the model has no GymScope of its own.
     */
    public function __construct(
        private readonly string $modelClass,
        private readonly ?string $gymIdColumn = null,
    ) {}

    public function validate(string $attribute, mixed $value, \Closure $fail): void
    {
        $query = $this->modelClass::query()->whereKey($value);

        if ($this->gymIdColumn !== null) {
            $query->where($this->gymIdColumn, auth()->user()?->gym_id);
        }

        if (! $query->exists()) {
            $fail("The selected {$attribute} is invalid.");
        }
    }
}
