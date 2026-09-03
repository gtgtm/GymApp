<?php

declare(strict_types=1);

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class StoreExpenseRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->hasRole('admin');
    }

    public function rules(): array
    {
        return [
            'category' => [
                'required',
                'string',
                'in:rent,electricity,equipment,maintenance,salary,marketing,cleaning,other',
            ],
            'amount' => ['required', 'numeric', 'min:0.01'],
            'expense_date' => ['required', 'date'],
            'description' => ['nullable', 'string'],
            'payment_method' => ['nullable', 'string', 'in:cash,upi,card,bank_transfer,online'],
        ];
    }
}
