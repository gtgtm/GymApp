<?php

declare(strict_types=1);

namespace App\Models;

use App\Models\Traits\BelongsToGym;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ProgressPhoto extends Model
{
    use BelongsToGym;

    public const TYPE_BEFORE = 'before';

    public const TYPE_AFTER = 'after';

    public const TYPE_PROGRESS = 'progress';

    protected $fillable = [
        'gym_id',
        'member_id',
        'photo_path',
        'type',
        'taken_on',
        'notes',
        'uploaded_by',
    ];

    protected $casts = [
        'taken_on' => 'date',
    ];

    public function member(): BelongsTo
    {
        return $this->belongsTo(Member::class);
    }

    public function uploadedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'uploaded_by');
    }
}
