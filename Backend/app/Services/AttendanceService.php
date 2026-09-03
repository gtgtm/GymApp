<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Attendance;
use App\Models\Member;
use Illuminate\Support\Carbon;

class AttendanceService
{
    /**
     * @return array{attendance: ?Attendance, expired: bool, membership_end_date: ?string}
     */
    public function markAttendance(Member $member, string $status, string $markedVia): array
    {
        $membership = $member->currentMembership();
        $expired = ! $membership || $membership->end_date->isPast();

        if ($expired) {
            return [
                'attendance' => null,
                'expired' => true,
                'membership_end_date' => $membership?->end_date->toDateString(),
            ];
        }

        $attendance = Attendance::query()->updateOrCreate(
            ['member_id' => $member->id, 'date' => Carbon::today()->toDateString()],
            [
                'gym_id' => $member->gym_id,
                'check_in_time' => Carbon::now()->toTimeString(),
                'status' => $status,
                'marked_via' => $markedVia,
                'marked_by' => auth()->id(),
            ],
        );

        return [
            'attendance' => $attendance,
            'expired' => false,
            'membership_end_date' => $membership->end_date->toDateString(),
        ];
    }
}
