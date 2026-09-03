<?php

declare(strict_types=1);

namespace App\Models;

use App\Models\Traits\BelongsToGym;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Attendance extends Model
{
    use BelongsToGym;

    public const TABLE_NAME = 'attendance';

    public const STATUS_PRESENT = 'present';

    public const STATUS_ABSENT = 'absent';

    public const STATUS_LATE = 'late';

    public const STATUS_LEAVE = 'leave';

    public const VIA_MANUAL = 'manual';

    public const VIA_QR = 'qr';

    public const VIA_SEARCH = 'search';

    protected $table = self::TABLE_NAME;

    protected $fillable = [
        'gym_id',
        'member_id',
        'date',
        'check_in_time',
        'status',
        'marked_via',
        'marked_by',
    ];

    protected $casts = [
        'date' => 'date',
    ];

    public function member(): BelongsTo
    {
        return $this->belongsTo(Member::class);
    }

    public function markedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'marked_by');
    }
}
