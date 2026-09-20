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
            // Mirrors GymScope's gym resolution — see that class.
            $gymId = app(ActingGymContext::class)->gymId();

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
