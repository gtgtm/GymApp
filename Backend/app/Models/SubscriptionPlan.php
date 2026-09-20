<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SubscriptionPlan extends Model
{
    protected $fillable = [
        'name',
        'slug',
        'description',
        'member_limit',
        'price',
        'status',
        'sort_order',
    ];

    protected $casts = [
        'price' => 'decimal:2',
    ];
}
