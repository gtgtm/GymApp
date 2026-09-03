<?php

declare(strict_types=1);

namespace App\Http\Requests\Api\V1;

class UpdateEquipmentRequest extends StoreEquipmentRequest
{
    public function rules(): array
    {
        $rules = parent::rules();
        $rules['name'] = ['sometimes', 'string', 'max:255'];

        return $rules;
    }
}
