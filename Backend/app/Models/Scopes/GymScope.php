<?php

declare(strict_types=1);

namespace App\Models\Scopes;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Scope;

class GymScope implements Scope
{
    public function apply(Builder $builder, Model $model): void
    {
        if ($gymId = auth()->user()?->gym_id) {
            $builder->where($model->getTable().'.gym_id', $gymId);
        }
    }
}
