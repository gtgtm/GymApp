<?php

declare(strict_types=1);

namespace App\Models;

use App\Models\Traits\BelongsToGym;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class MembershipPlan extends Model
{
    use BelongsToGym, HasFactory, SoftDeletes;

    protected $fillable = [
        'gym_id',
        'name',
        'duration_days',
        'price',
        'registration_fee',
        'discount',
        'tax',
        'total_amount',
        'description',
        'benefits',
        'freeze_days',
        'status',
    ];

    protected $casts = [
        'benefits' => 'array',
        'price' => 'decimal:2',
        'registration_fee' => 'decimal:2',
        'discount' => 'decimal:2',
        'tax' => 'decimal:2',
        'total_amount' => 'decimal:2',
    ];

    public function memberships(): HasMany
    {
        return $this->hasMany(Membership::class);
    }
}
