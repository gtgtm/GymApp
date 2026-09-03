<?php

declare(strict_types=1);

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class StoreMembershipPlanRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->hasRole('admin');
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'duration_days' => ['required', 'integer', 'min:1'],
            'price' => ['required', 'numeric', 'min:0'],
            'registration_fee' => ['nullable', 'numeric', 'min:0'],
            'discount' => ['nullable', 'numeric', 'min:0'],
            'tax' => ['nullable', 'numeric', 'min:0'],
            'description' => ['nullable', 'string'],
            'benefits' => ['nullable', 'array'],
            'benefits.*' => ['string'],
            'freeze_days' => ['nullable', 'integer', 'min:0'],
            'status' => ['nullable', 'string', 'in:active,inactive'],
            'total_amount' => ['required', 'numeric', 'min:0'],
        ];
    }

    protected function prepareForValidation(): void
    {
        $price = (float) $this->input('price', 0);
        $registrationFee = (float) $this->input('registration_fee', 0);
        $discount = (float) $this->input('discount', 0);
        $tax = (float) $this->input('tax', 0);

        $this->merge([
            'total_amount' => max(0, $price + $registrationFee - $discount + $tax),
        ]);
    }
}
