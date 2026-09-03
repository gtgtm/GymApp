<?php

declare(strict_types=1);

namespace App\Models;

use App\Models\Traits\BelongsToGym;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DietMeal extends Model
{
    use BelongsToGym;

    public const SLOT_BREAKFAST = 'breakfast';

    public const SLOT_MID_MORNING = 'mid_morning';

    public const SLOT_LUNCH = 'lunch';

    public const SLOT_EVENING_SNACK = 'evening_snack';

    public const SLOT_DINNER = 'dinner';

    public const SLOT_BEFORE_BED = 'before_bed';

    protected $fillable = [
        'gym_id',
        'diet_plan_id',
        'meal_slot',
        'food_item',
        'quantity',
        'calories',
        'protein_g',
        'carbs_g',
        'fat_g',
        'notes',
        'sort_order',
    ];

    protected $casts = [
        'calories' => 'decimal:2',
        'protein_g' => 'decimal:2',
        'carbs_g' => 'decimal:2',
        'fat_g' => 'decimal:2',
    ];

    public function dietPlan(): BelongsTo
    {
        return $this->belongsTo(DietPlan::class);
    }
}
