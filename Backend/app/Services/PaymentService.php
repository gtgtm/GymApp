<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Payment;
use Illuminate\Support\Str;

class PaymentService
{
    public function create(array $data): Payment
    {
        return Payment::query()->create([
            ...$data,
            'receipt_number' => $this->generateReceiptNumber(),
            'status' => 'completed',
            'paid_at' => now(),
            'collected_by' => auth()->id(),
        ]);
    }

    public function generateReceiptNumber(): string
    {
        do {
            $number = 'RCPT-'.strtoupper(Str::random(10));
        } while (Payment::withoutGlobalScopes()->where('receipt_number', $number)->exists());

        return $number;
    }
}
