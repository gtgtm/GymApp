<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * One row = one person's access to one gym, with the role and (optionally)
 * the member profile that apply at that gym specifically. A person can hold
 * several of these — e.g. trainer at Gym A, member at Gym B.
 *
 * Deliberately does NOT use the BelongsToGym trait / GymScope: this table
 * is what *defines* tenancy for everything else, so scoping it to "the
 * current gym" would be circular (you could never list a person's other
 * gyms). Every query against this model must state its own gym_id/user_id
 * filter explicitly.
 *
 * No soft deletes: a revoked membership is kept as a row with
 * status = 'inactive' rather than deleted, so the (user_id, gym_id) unique
 * constraint stays meaningful without deleted_at bookkeeping.
 */
class UserGymMembership extends Model
{
    public const STATUS_ACTIVE = 'active';

    public const STATUS_PENDING = 'pending';

    public const STATUS_INACTIVE = 'inactive';

    protected $fillable = [
        'user_id',
        'gym_id',
        'role_id',
        'member_id',
        'status',
        'joined_at',
    ];

    protected $casts = [
        'joined_at' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function gym(): BelongsTo
    {
        return $this->belongsTo(Gym::class);
    }

    public function role(): BelongsTo
    {
        return $this->belongsTo(Role::class);
    }

    public function member(): BelongsTo
    {
        return $this->belongsTo(Member::class);
    }

    public function isActive(): bool
    {
        return $this->status === self::STATUS_ACTIVE;
    }
}
