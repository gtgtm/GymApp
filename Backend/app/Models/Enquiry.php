<?php

declare(strict_types=1);

namespace App\Models;

use App\Models\Traits\BelongsToGym;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Enquiry extends Model
{
    use BelongsToGym, HasFactory, SoftDeletes;

    public const STATUS_NEW = 'new';

    public const STATUS_CONTACTED = 'contacted';

    public const STATUS_TRIAL = 'trial';

    public const STATUS_FOLLOW_UP = 'follow_up';

    public const STATUS_CONVERTED = 'converted';

    public const STATUS_LOST = 'lost';

    protected $fillable = [
        'gym_id',
        'name',
        'mobile',
        'email',
        'source',
        'interested_plan_id',
        'follow_up_date',
        'assigned_staff_id',
        'status',
        'notes',
    ];

    protected $casts = [
        'follow_up_date' => 'date',
    ];

    public function interestedPlan(): BelongsTo
    {
        return $this->belongsTo(MembershipPlan::class, 'interested_plan_id');
    }

    public function assignedStaff(): BelongsTo
    {
        return $this->belongsTo(User::class, 'assigned_staff_id');
    }

    public function trials(): HasMany
    {
        return $this->hasMany(Trial::class);
    }
}
