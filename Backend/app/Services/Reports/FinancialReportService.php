<?php

declare(strict_types=1);

namespace App\Services\Reports;

use App\Models\Expense;
use App\Models\Payment;
use Illuminate\Support\Carbon;

class FinancialReportService
{
    public function summary(Carbon $from, Carbon $to): array
    {
        $revenue = (float) Payment::query()
            ->whereBetween('paid_at', [$from->startOfDay(), $to->endOfDay()])
            ->sum('amount');

        $expenses = (float) Expense::query()
            ->whereBetween('expense_date', [$from->startOfDay(), $to->endOfDay()])
            ->sum('amount');

        $paymentMethodBreakdown = Payment::query()
            ->whereBetween('paid_at', [$from->startOfDay(), $to->endOfDay()])
            ->selectRaw('method, sum(amount) as total')
            ->groupBy('method')
            ->pluck('total', 'method');

        $expenseCategoryBreakdown = Expense::query()
            ->whereBetween('expense_date', [$from->startOfDay(), $to->endOfDay()])
            ->selectRaw('category, sum(amount) as total')
            ->groupBy('category')
            ->pluck('total', 'category');

        return [
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
            'revenue' => $revenue,
            'expenses' => $expenses,
            'profit' => $revenue - $expenses,
            'payment_method_breakdown' => $paymentMethodBreakdown,
            'expense_category_breakdown' => $expenseCategoryBreakdown,
        ];
    }

    public function dailyRevenueSeries(Carbon $from, Carbon $to): array
    {
        return Payment::query()
            ->whereBetween('paid_at', [$from->startOfDay(), $to->endOfDay()])
            ->selectRaw('DATE(paid_at) as date, sum(amount) as total')
            ->groupBy('date')
            ->orderBy('date')
            ->get()
            ->map(fn ($row) => ['date' => $row->date, 'total' => (float) $row->total])
            ->all();
    }

    public function paymentRows(Carbon $from, Carbon $to): array
    {
        return Payment::query()
            ->with('member:id,full_name,member_code')
            ->whereBetween('paid_at', [$from->startOfDay(), $to->endOfDay()])
            ->orderBy('paid_at')
            ->get()
            ->map(fn (Payment $payment) => [
                'receipt_number' => $payment->receipt_number,
                'member' => $payment->member?->full_name,
                'amount' => (float) $payment->amount,
                'method' => $payment->method,
                'paid_at' => $payment->paid_at->toDateTimeString(),
            ])
            ->all();
    }
}
