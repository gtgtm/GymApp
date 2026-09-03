<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AuditLog extends Model
{
    protected $fillable = [
        'gym_id',
        'user_id',
        'action',
        'entity_type',
        'entity_id',
        'before',
        'after',
        'ip_address',
    ];

    protected $casts = [
        'before' => 'array',
        'after' => 'array',
    ];

    public function gym(): BelongsTo
    {
        return $this->belongsTo(Gym::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
