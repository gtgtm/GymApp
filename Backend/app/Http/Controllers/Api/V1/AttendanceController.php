<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreAttendanceRequest;
use App\Models\Attendance;
use App\Models\Member;
use App\Services\AttendanceService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AttendanceController extends Controller
{
    public function __construct(private readonly AttendanceService $attendanceService) {}

    public function index(Request $request): JsonResponse
    {
        $attendance = Attendance::query()
            ->with('member:id,full_name,member_code')
            ->when($request->date('date'), fn ($query, $date) => $query->whereDate('date', $date))
            ->when($request->integer('member_id'), fn ($query, $memberId) => $query->where('member_id', $memberId))
            ->latest('date')
            ->paginate($request->integer('per_page', 50));

        return $this->success($attendance->items(), [
            'total' => $attendance->total(),
            'page' => $attendance->currentPage(),
            'limit' => $attendance->perPage(),
        ]);
    }

    public function store(StoreAttendanceRequest $request): JsonResponse
    {
        $member = Member::query()->findOrFail($request->validated('member_id'));

        $result = $this->attendanceService->markAttendance(
            $member,
            $request->validated('status', 'present'),
            $request->validated('marked_via', 'manual'),
        );

        if ($result['expired']) {
            return $this->fail(
                'This member\'s membership has expired. Please renew before marking attendance.',
                422,
                ['membership_end_date' => $result['membership_end_date']],
            );
        }

        return $this->success([
            'attendance' => $result['attendance'],
            'membership_end_date' => $result['membership_end_date'],
        ], status: 201);
    }
}
