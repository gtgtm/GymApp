<?php

declare(strict_types=1);

namespace App\Http\Requests\Api\V1;

class UpdateEnquiryRequest extends StoreEnquiryRequest
{
    public function rules(): array
    {
        $rules = parent::rules();
        $rules['name'] = ['sometimes', 'string', 'max:255'];
        $rules['mobile'] = ['sometimes', 'string', 'max:20'];

        return $rules;
    }
}
