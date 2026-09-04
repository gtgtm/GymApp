<?php

declare(strict_types=1);

namespace App\Http\Requests\Api\V1;

use App\Models\Invoice;
use App\Models\Member;
use App\Rules\ExistsInCurrentGym;
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
            'member_id' => ['required', new ExistsInCurrentGym(Member::class)],
            'invoice_id' => ['nullable', new ExistsInCurrentGym(Invoice::class)],
            'amount' => ['required', 'numeric', 'min:0.01'],
            'discount' => ['nullable', 'numeric', 'min:0'],
            'tax' => ['nullable', 'numeric', 'min:0'],
            'method' => ['required', 'string', 'in:cash,upi,card,bank_transfer,online'],
        ];
    }
}
