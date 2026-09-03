<?php

declare(strict_types=1);

namespace App\Models;

use App\Models\Traits\BelongsToGym;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class DietPlan extends Model
{
    use BelongsToGym, HasFactory, SoftDeletes;

    protected $fillable = [
        'gym_id',
        'member_id',
        'trainer_id',
        'name',
        'notes',
        'status',
    ];

    public function member(): BelongsTo
    {
        return $this->belongsTo(Member::class);
    }

    public function trainer(): BelongsTo
    {
        return $this->belongsTo(Trainer::class);
    }

    public function meals(): HasMany
    {
        return $this->hasMany(DietMeal::class)->orderBy('sort_order');
    }

    public function dailySummary(): array
    {
        return [
            'calories' => (float) $this->meals->sum('calories'),
            'protein_g' => (float) $this->meals->sum('protein_g'),
            'carbs_g' => (float) $this->meals->sum('carbs_g'),
            'fat_g' => (float) $this->meals->sum('fat_g'),
        ];
    }
}
