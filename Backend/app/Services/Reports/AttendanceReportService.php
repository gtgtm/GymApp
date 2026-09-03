<?php

declare(strict_types=1);

namespace App\Services\Reports;

use App\Models\Attendance;
use Illuminate\Support\Carbon;

class AttendanceReportService
{
    public function dailySeries(Carbon $from, Carbon $to): array
    {
        return Attendance::query()
            ->whereBetween('date', [$from->toDateString(), $to->toDateString()])
            ->selectRaw('date, count(*) as count')
            ->groupBy('date')
            ->orderBy('date')
            ->get()
            ->map(fn ($row) => ['date' => $row->date, 'count' => (int) $row->count])
            ->all();
    }

    public function byDayOfWeek(Carbon $from, Carbon $to): array
    {
        $rows = Attendance::query()
            ->whereBetween('date', [$from->toDateString(), $to->toDateString()])
            ->get(['date']);

        $counts = array_fill(0, 7, 0);
        foreach ($rows as $row) {
            $counts[Carbon::parse($row->date)->dayOfWeek]++;
        }

        $labels = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

        return collect($labels)
            ->map(fn ($label, $index) => ['day' => $label, 'count' => $counts[$index]])
            ->all();
    }

    public function memberWise(Carbon $from, Carbon $to): array
    {
        return Attendance::query()
            ->with('member:id,full_name,member_code')
            ->whereBetween('date', [$from->toDateString(), $to->toDateString()])
            ->selectRaw('member_id, count(*) as visits')
            ->groupBy('member_id')
            ->orderByDesc('visits')
            ->get()
            ->map(fn ($row) => [
                'member' => $row->member?->full_name,
                'member_code' => $row->member?->member_code,
                'visits' => (int) $row->visits,
            ])
            ->all();
    }
}
