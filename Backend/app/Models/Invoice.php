<?php

declare(strict_types=1);

namespace App\Models;

use App\Models\Traits\BelongsToGym;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Invoice extends Model
{
    use BelongsToGym;

    protected $fillable = [
        'gym_id',
        'member_id',
        'invoice_number',
        'line_items',
        'total',
        'status',
    ];

    protected $casts = [
        'line_items' => 'array',
        'total' => 'decimal:2',
    ];

    public function member(): BelongsTo
    {
        return $this->belongsTo(Member::class);
    }

    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }
}
