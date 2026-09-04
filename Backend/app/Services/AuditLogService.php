<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\AuditLog;
use Illuminate\Database\Eloquent\Model;

class AuditLogService
{
    public function log(string $action, ?Model $entity = null, ?array $before = null, ?array $after = null, ?int $gymId = null): AuditLog
    {
        $user = auth()->user();

        return AuditLog::query()->create([
            'gym_id' => $gymId ?? $user?->gym_id,
            'user_id' => $user?->id,
            'action' => $action,
            'entity_type' => $entity ? $entity::class : 'auth',
            'entity_id' => $entity?->getKey(),
            'before' => $before,
            'after' => $after,
            'ip_address' => request()->ip(),
        ]);
    }
}
