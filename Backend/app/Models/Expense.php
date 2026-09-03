<?php

declare(strict_types=1);

namespace App\Models;

use App\Models\Traits\BelongsToGym;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Expense extends Model
{
    use BelongsToGym, SoftDeletes;

    public const CATEGORY_RENT = 'rent';

    public const CATEGORY_ELECTRICITY = 'electricity';

    public const CATEGORY_EQUIPMENT = 'equipment';

    public const CATEGORY_MAINTENANCE = 'maintenance';

    public const CATEGORY_SALARY = 'salary';

    public const CATEGORY_MARKETING = 'marketing';

    public const CATEGORY_CLEANING = 'cleaning';

    public const CATEGORY_OTHER = 'other';

    protected $fillable = [
        'gym_id',
        'category',
        'amount',
        'expense_date',
        'description',
        'payment_method',
        'receipt_path',
        'recorded_by',
    ];

    protected $casts = [
        'expense_date' => 'date',
        'amount' => 'decimal:2',
    ];

    public function recordedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'recorded_by');
    }
}
