<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Subscription extends Model
{
    public const PLAN_STARTER = 'starter';

    public const PLAN_PROFESSIONAL = 'professional';

    public const PLAN_ENTERPRISE = 'enterprise';

    public const STATUS_ACTIVE = 'active';

    public const STATUS_PAST_DUE = 'past_due';

    public const STATUS_CANCELLED = 'cancelled';

    public const PLAN_LIMITS = [
        self::PLAN_STARTER => 300,
        self::PLAN_PROFESSIONAL => 1000,
        self::PLAN_ENTERPRISE => null,
    ];

    protected $fillable = [
        'gym_id',
        'plan',
        'member_limit',
        'start_date',
        'expiry_date',
        'payment_status',
    ];

    protected $casts = [
        'start_date' => 'date',
        'expiry_date' => 'date',
    ];

    public function gym(): BelongsTo
    {
        return $this->belongsTo(Gym::class);
    }

    public function isExpired(): bool
    {
        return $this->expiry_date->isPast();
    }

    public function isUnlimited(): bool
    {
        return $this->member_limit === null;
    }
}
