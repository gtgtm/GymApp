<?php

declare(strict_types=1);

namespace App\Models;

use App\Models\Traits\BelongsToGym;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Member extends Model
{
    use BelongsToGym, HasFactory, SoftDeletes;

    protected $fillable = [
        'gym_id',
        'member_code',
        'photo_path',
        'full_name',
        'mobile',
        'email',
        'date_of_birth',
        'gender',
        'address',
        'emergency_contact_name',
        'emergency_contact_phone',
        'joining_date',
        'trainer_id',
        'height_cm',
        'weight_kg',
        'blood_group',
        'notes',
        'status',
    ];

    protected $casts = [
        'date_of_birth' => 'date',
        'joining_date' => 'date',
        'height_cm' => 'decimal:2',
        'weight_kg' => 'decimal:2',
    ];

    public function trainer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'trainer_id');
    }

    public function memberships(): HasMany
    {
        return $this->hasMany(Membership::class);
    }

    public function currentMembership(): ?Membership
    {
        return $this->memberships()->latest('end_date')->first();
    }

    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }

    public function attendance(): HasMany
    {
        return $this->hasMany(Attendance::class);
    }

    public function expiryBucket(): string
    {
        $membership = $this->currentMembership();

        if (! $membership) {
            return 'red';
        }

        $daysRemaining = Carbon::today()->diffInDays($membership->end_date, false);

        return match (true) {
            $daysRemaining < 0 => 'red',
            $daysRemaining <= 6 => 'orange',
            $daysRemaining <= 15 => 'yellow',
            default => 'green',
        };
    }
}
