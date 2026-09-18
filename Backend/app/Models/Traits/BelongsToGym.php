<?php

declare(strict_types=1);

namespace App\Models\Traits;

use App\Models\Gym;
use App\Models\Scopes\GymScope;
use App\Services\ActingGymContext;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

trait BelongsToGym
{
    public static function bootBelongsToGym(): void
    {
        static::addGlobalScope(new GymScope);

        static::creating(function ($model): void {
            // Mirrors GymScope's gym resolution: super_admin has no gym_id
            // of its own, so new rows it creates belong to the gym it is
            // currently acting as (see ResolveActingGym middleware).
            $gymId = auth()->user()?->gym_id ?? app(ActingGymContext::class)->gymId();

            if (! $model->gym_id && $gymId) {
                $model->gym_id = $gymId;
            }
        });
    }

    public function gym(): BelongsTo
    {
        return $this->belongsTo(Gym::class);
    }
}
