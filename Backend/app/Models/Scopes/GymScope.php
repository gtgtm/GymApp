<?php

declare(strict_types=1);

namespace App\Models\Scopes;

use App\Services\ActingGymContext;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Scope;

class GymScope implements Scope
{
    public function apply(Builder $builder, Model $model): void
    {
        $gymId = auth()->user()?->gym_id
            // super_admin has no gym_id of its own; ResolveActingGym middleware
            // populates this from the X-Gym-Id header once it has verified the
            // caller is super_admin, so this is never attacker-controlled input.
            ?? app(ActingGymContext::class)->gymId();

        if ($gymId) {
            $builder->where($model->getTable().'.gym_id', $gymId);

            return;
        }

        // No gym context to scope to. Console commands intentionally run
        // unauthenticated and filter by gym_id explicitly per iteration
        // (see app/Console/Commands/*), so let those through unscoped.
        // Anything reached over HTTP without a resolvable gym (e.g. a
        // super_admin token with no X-Gym-Id set, or a data bug that nulled
        // a staff user's gym_id) must fail closed rather than silently
        // return every tenant's rows.
        if (app()->runningInConsole()) {
            return;
        }

        $builder->whereRaw('1 = 0');
    }
}
