<?php

declare(strict_types=1);

namespace App\Models;

use App\Models\Traits\BelongsToGym;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Equipment extends Model
{
    use BelongsToGym, SoftDeletes;

    protected $table = 'equipment';

    public const CONDITION_GOOD = 'good';

    public const CONDITION_FAIR = 'fair';

    public const CONDITION_NEEDS_REPAIR = 'needs_repair';

    public const CONDITION_OUT_OF_SERVICE = 'out_of_service';

    protected $fillable = [
        'gym_id',
        'name',
        'category',
        'purchase_date',
        'purchase_price',
        'warranty_expiry',
        'condition',
        'last_maintenance_date',
        'next_maintenance_date',
    ];

    protected $casts = [
        'purchase_date' => 'date',
        'warranty_expiry' => 'date',
        'last_maintenance_date' => 'date',
        'next_maintenance_date' => 'date',
        'purchase_price' => 'decimal:2',
    ];
}
