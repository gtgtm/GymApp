<?php

declare(strict_types=1);

namespace App\Models;

use App\Models\Traits\BelongsToGym;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GymNotification extends Model
{
    use BelongsToGym;

    protected $table = 'notifications';

    public const TYPE_MEMBERSHIP_EXPIRING = 'membership_expiring';

    public const TYPE_PAYMENT_RECEIPT = 'payment_receipt';

    public const TYPE_RENEWAL_CONFIRMATION = 'renewal_confirmation';

    public const TYPE_NEW_WORKOUT_PLAN = 'new_workout_plan';

    public const TYPE_NEW_DIET_PLAN = 'new_diet_plan';

    public const TYPE_PENDING_PAYMENT = 'pending_payment';

    public const TYPE_NEW_ENQUIRY = 'new_enquiry';

    public const TYPE_TRIAL_EXPIRING = 'trial_expiring';

    public const TYPE_EQUIPMENT_MAINTENANCE = 'equipment_maintenance';

    public const CHANNEL_IN_APP = 'in_app';

    public const CHANNEL_EMAIL = 'email';

    public const CHANNEL_SMS = 'sms';

    public const CHANNEL_WHATSAPP = 'whatsapp';

    protected $fillable = [
        'gym_id',
        'user_id',
        'type',
        'title',
        'body',
        'data',
        'channel',
        'read_at',
        'sent_at',
    ];

    protected $casts = [
        'data' => 'array',
        'read_at' => 'datetime',
        'sent_at' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
