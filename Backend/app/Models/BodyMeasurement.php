<?php

declare(strict_types=1);

namespace App\Models;

use App\Models\Traits\BelongsToGym;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BodyMeasurement extends Model
{
    use BelongsToGym;

    protected $fillable = [
        'gym_id',
        'member_id',
        'recorded_date',
        'weight_kg',
        'height_cm',
        'bmi',
        'body_fat_percent',
        'chest_cm',
        'waist_cm',
        'arms_cm',
        'thigh_cm',
        'hips_cm',
        'recorded_by',
    ];

    protected $casts = [
        'recorded_date' => 'date',
        'weight_kg' => 'decimal:2',
        'height_cm' => 'decimal:2',
        'bmi' => 'decimal:2',
        'body_fat_percent' => 'decimal:2',
        'chest_cm' => 'decimal:2',
        'waist_cm' => 'decimal:2',
        'arms_cm' => 'decimal:2',
        'thigh_cm' => 'decimal:2',
        'hips_cm' => 'decimal:2',
    ];

    public function member(): BelongsTo
    {
        return $this->belongsTo(Member::class);
    }

    public function recordedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'recorded_by');
    }
}
