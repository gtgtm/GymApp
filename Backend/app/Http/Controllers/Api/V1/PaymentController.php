<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StorePaymentRequest;
use App\Models\Payment;
use App\Services\AuditLogService;
use App\Services\PaymentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PaymentController extends Controller
{
    public function __construct(
        private readonly PaymentService $paymentService,
        private readonly AuditLogService $auditLog,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $payments = Payment::query()
            ->with('member:id,full_name,member_code')
            ->when($request->date('from'), fn ($query, $from) => $query->whereDate('paid_at', '>=', $from))
            ->when($request->date('to'), fn ($query, $to) => $query->whereDate('paid_at', '<=', $to))
            ->latest('paid_at')
            ->paginate($request->integer('per_page', 20));

        return $this->success($payments->items(), [
            'total' => $payments->total(),
            'page' => $payments->currentPage(),
            'limit' => $payments->perPage(),
        ]);
    }

    public function store(StorePaymentRequest $request): JsonResponse
    {
        $payment = $this->paymentService->create($request->validated());

        $this->auditLog->log('payment.created', $payment, null, $payment->toArray());

        return $this->success($payment, status: 201);
    }

    public function show(Payment $payment): JsonResponse
    {
        return $this->success($payment->load('member', 'collectedBy'));
    }
}
