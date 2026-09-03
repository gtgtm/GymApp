<?php

declare(strict_types=1);

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class StorePaymentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->hasRole('admin', 'receptionist');
    }

    public function rules(): array
    {
        return [
            'member_id' => ['required', 'exists:members,id'],
            'invoice_id' => ['nullable', 'exists:invoices,id'],
            'amount' => ['required', 'numeric', 'min:0.01'],
            'discount' => ['nullable', 'numeric', 'min:0'],
            'tax' => ['nullable', 'numeric', 'min:0'],
            'method' => ['required', 'string', 'in:cash,upi,card,bank_transfer,online'],
        ];
    }
}
