<?php

declare(strict_types=1);

namespace App\Http\Requests\Api\V1;

class UpdateMembershipPlanRequest extends StoreMembershipPlanRequest
{
    public function rules(): array
    {
        $rules = parent::rules();
        $rules['name'] = ['sometimes', 'string', 'max:255'];
        $rules['duration_days'] = ['sometimes', 'integer', 'min:1'];
        $rules['price'] = ['sometimes', 'numeric', 'min:0'];

        return $rules;
    }
}
