<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\GymNotification;
use App\Models\Payment;
use App\Notifications\NotificationMessage;
use Illuminate\Support\Str;

class PaymentService
{
    public function __construct(private readonly NotificationService $notificationService) {}

    public function create(array $data): Payment
    {
        $payment = Payment::query()->create([
            ...$data,
            'receipt_number' => $this->generateReceiptNumber(),
            'status' => 'completed',
            'paid_at' => now(),
            'collected_by' => auth()->id(),
        ]);

        if (auth()->user()) {
            $this->notificationService->notify(
                auth()->user(),
                new NotificationMessage(
                    type: GymNotification::TYPE_PAYMENT_RECEIPT,
                    title: 'Payment recorded',
                    body: sprintf('Receipt %s for ₹%s.', $payment->receipt_number, $payment->amount),
                    data: ['payment_id' => $payment->id],
                ),
            );
        }

        return $payment;
    }

    public function generateReceiptNumber(): string
    {
        do {
            $number = 'RCPT-'.strtoupper(Str::random(10));
        } while (Payment::withoutGlobalScopes()->where('receipt_number', $number)->exists());

        return $number;
    }
}
