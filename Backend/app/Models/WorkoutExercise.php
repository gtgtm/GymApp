<?php

declare(strict_types=1);

namespace App\Models;

use App\Models\Traits\BelongsToGym;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WorkoutExercise extends Model
{
    use BelongsToGym;

    protected $fillable = [
        'gym_id',
        'workout_plan_id',
        'day_number',
        'day_label',
        'exercise_name',
        'muscle_group',
        'sets',
        'reps',
        'weight_kg',
        'rest_seconds',
        'instructions',
        'video_url',
        'trainer_notes',
        'sort_order',
    ];

    protected $casts = [
        'weight_kg' => 'decimal:2',
    ];

    public function workoutPlan(): BelongsTo
    {
        return $this->belongsTo(WorkoutPlan::class);
    }
}
