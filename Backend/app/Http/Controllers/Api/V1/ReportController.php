<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\Reports\AttendanceReportService;
use App\Services\Reports\CsvExporter;
use App\Services\Reports\FinancialReportService;
use App\Services\Reports\MemberReportService;
use App\Services\Reports\SalesReportService;
use App\Services\Reports\TrainerReportService;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class ReportController extends Controller
{
    public function __construct(
        private readonly FinancialReportService $financialReports,
        private readonly MemberReportService $memberReports,
        private readonly AttendanceReportService $attendanceReports,
        private readonly TrainerReportService $trainerReports,
        private readonly SalesReportService $salesReports,
        private readonly CsvExporter $csvExporter,
    ) {}

    public function financial(Request $request): JsonResponse
    {
        [$from, $to] = $this->resolveRange($request);

        return $this->success([
            'summary' => $this->financialReports->summary($from, $to),
            'daily_revenue' => $this->financialReports->dailyRevenueSeries($from, $to),
        ]);
    }

    public function financialExportCsv(Request $request)
    {
        [$from, $to] = $this->resolveRange($request);

        return $this->csvExporter->stream(
            'financial-report.csv',
            $this->financialReports->paymentRows($from, $to),
        );
    }

    public function financialExportPdf(Request $request)
    {
        [$from, $to] = $this->resolveRange($request);

        $summary = $this->financialReports->summary($from, $to);

        return Pdf::loadView('reports.financial', [
            'gym' => $request->user()->gym,
            'summary' => $summary,
        ])->download('financial-report.pdf');
    }

    public function members(Request $request): JsonResponse
    {
        [$from, $to] = $this->resolveRange($request);

        return $this->success([
            'summary' => $this->memberReports->summary($from, $to),
            'plan_distribution' => $this->memberReports->planDistribution(),
        ]);
    }

    public function membersExportCsv(Request $request)
    {
        [$from, $to] = $this->resolveRange($request);

        return $this->csvExporter->stream(
            'members-report.csv',
            $this->memberReports->planDistribution(),
        );
    }

    public function attendance(Request $request): JsonResponse
    {
        [$from, $to] = $this->resolveRange($request);

        return $this->success([
            'daily' => $this->attendanceReports->dailySeries($from, $to),
            'by_day_of_week' => $this->attendanceReports->byDayOfWeek($from, $to),
            'member_wise' => $this->attendanceReports->memberWise($from, $to),
        ]);
    }

    public function attendanceExportCsv(Request $request)
    {
        [$from, $to] = $this->resolveRange($request);

        return $this->csvExporter->stream(
            'attendance-report.csv',
            $this->attendanceReports->memberWise($from, $to),
        );
    }

    public function trainers(): JsonResponse
    {
        return $this->success($this->trainerReports->performance());
    }

    public function trainersExportCsv()
    {
        return $this->csvExporter->stream('trainer-report.csv', $this->trainerReports->performance());
    }

    public function sales(Request $request): JsonResponse
    {
        [$from, $to] = $this->resolveRange($request);

        return $this->success([
            'summary' => $this->salesReports->summary($from, $to),
            'revenue_by_plan' => $this->salesReports->revenueByPlan($from, $to),
        ]);
    }

    public function salesExportCsv(Request $request)
    {
        [$from, $to] = $this->resolveRange($request);

        return $this->csvExporter->stream(
            'sales-report.csv',
            $this->salesReports->revenueByPlan($from, $to),
        );
    }

    /**
     * @return array{0: Carbon, 1: Carbon}
     */
    private function resolveRange(Request $request): array
    {
        $from = $request->date('from') ? Carbon::instance($request->date('from')) : Carbon::today()->startOfMonth();
        $to = $request->date('to') ? Carbon::instance($request->date('to')) : Carbon::today();

        return [$from, $to];
    }
}
