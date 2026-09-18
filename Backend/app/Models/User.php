<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use App\Services\ActingGymContext;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

#[Fillable(['gym_id', 'role_id', 'name', 'email', 'phone', 'password', 'status'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function gym(): BelongsTo
    {
        return $this->belongsTo(Gym::class);
    }

    public function role(): BelongsTo
    {
        return $this->belongsTo(Role::class);
    }

    public function assignedMembers(): HasMany
    {
        return $this->hasMany(Member::class, 'trainer_id');
    }

    public function memberProfile(): HasOne
    {
        return $this->hasOne(Member::class, 'user_id');
    }

    public function hasRole(string ...$roles): bool
    {
        if (! $this->role) {
            return false;
        }

        if (in_array($this->role->name, $roles, true)) {
            return true;
        }

        // A super_admin acting as a specific gym (see ResolveActingGym
        // middleware) is treated as that gym's admin everywhere hasRole()
        // is checked — route middleware, FormRequest::authorize(), and
        // controllers alike — so it never needs bypassing case by case.
        return $this->role->name === Role::SUPER_ADMIN
            && in_array(Role::ADMIN, $roles, true)
            && app(ActingGymContext::class)->gymId() !== null;
    }
}
