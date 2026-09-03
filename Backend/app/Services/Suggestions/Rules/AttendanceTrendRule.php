<?php

declare(strict_types=1);

namespace App\Services\Suggestions\Rules;

use App\Models\Attendance;
use App\Services\Suggestions\Suggestion;
use App\Services\Suggestions\SuggestionRule;
use Illuminate\Support\Carbon;

class AttendanceTrendRule implements SuggestionRule
{
    private const MIN_SAMPLE_SIZE = 10;

    private const LOOKBACK_DAYS = 30;

    private const DAY_LABELS = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    public function generate(): array
    {
        $records = Attendance::query()
            ->where('date', '>=', Carbon::today()->subDays(self::LOOKBACK_DAYS))
            ->get(['date']);

        if ($records->count() < self::MIN_SAMPLE_SIZE) {
            return [];
        }

        $counts = array_fill(0, 7, 0);
        foreach ($records as $record) {
            $counts[Carbon::parse($record->date)->dayOfWeek]++;
        }

        $maxDay = array_keys($counts, max($counts))[0];
        $minDay = array_keys($counts, min($counts))[0];

        if ($counts[$maxDay] === $counts[$minDay]) {
            return [];
        }

        $percentHigher = $counts[$minDay] > 0
            ? round((($counts[$maxDay] - $counts[$minDay]) / $counts[$minDay]) * 100)
            : 100;

        return [
            new Suggestion(
                category: 'business',
                message: sprintf(
                    '%s attendance is %d%% higher than %s.',
                    self::DAY_LABELS[$maxDay],
                    $percentHigher,
                    self::DAY_LABELS[$minDay],
                ),
                actionLabel: 'View Attendance Report',
                actionRoute: '/reports/attendance',
                severity: 'info',
            ),
        ];
    }
}
