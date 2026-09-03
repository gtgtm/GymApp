<?php

declare(strict_types=1);

namespace App\Services\Reports;

use App\Models\Trainer;

class TrainerReportService
{
    public function performance(): array
    {
        return Trainer::query()
            ->with('user:id,name')
            ->withCount('assignedMembers', 'workoutPlans', 'dietPlans')
            ->get()
            ->map(fn (Trainer $trainer) => [
                'trainer' => $trainer->user->name,
                'assigned_members' => $trainer->assigned_members_count,
                'workout_plans_created' => $trainer->workout_plans_count,
                'diet_plans_created' => $trainer->diet_plans_count,
            ])
            ->all();
    }
}
