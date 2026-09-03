<?php

declare(strict_types=1);

namespace App\Models;

use App\Models\Traits\BelongsToGym;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MembershipRenewal extends Model
{
    use BelongsToGym;

    protected $fillable = [
        'gym_id',
        'membership_id',
        'membership_plan_id',
        'previous_expiry',
        'new_expiry',
        'discount',
        'tax',
        'amount_paid',
        'amount_due',
        'payment_method',
        'renewed_by',
    ];

    protected $casts = [
        'previous_expiry' => 'date',
        'new_expiry' => 'date',
        'discount' => 'decimal:2',
        'tax' => 'decimal:2',
        'amount_paid' => 'decimal:2',
        'amount_due' => 'decimal:2',
    ];

    public function membership(): BelongsTo
    {
        return $this->belongsTo(Membership::class);
    }

    public function plan(): BelongsTo
    {
        return $this->belongsTo(MembershipPlan::class, 'membership_plan_id');
    }

    public function renewedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'renewed_by');
    }
}
