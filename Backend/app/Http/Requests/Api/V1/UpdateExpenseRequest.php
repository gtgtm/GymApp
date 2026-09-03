<?php

declare(strict_types=1);

namespace App\Http\Requests\Api\V1;

class UpdateExpenseRequest extends StoreExpenseRequest
{
    public function rules(): array
    {
        $rules = parent::rules();
        $rules['category'] = ['sometimes', 'string', 'in:rent,electricity,equipment,maintenance,salary,marketing,cleaning,other'];
        $rules['amount'] = ['sometimes', 'numeric', 'min:0.01'];
        $rules['expense_date'] = ['sometimes', 'date'];

        return $rules;
    }
}
