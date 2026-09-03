<?php

declare(strict_types=1);

namespace App\Http\Requests\Api\V1;

class UpdateTrialRequest extends StoreTrialRequest
{
    public function rules(): array
    {
        $rules = parent::rules();
        $rules['name'] = ['sometimes', 'string', 'max:255'];
        $rules['mobile'] = ['sometimes', 'string', 'max:20'];
        $rules['trial_start'] = ['sometimes', 'date'];
        $rules['trial_end'] = ['sometimes', 'date', 'after_or_equal:trial_start'];

        return $rules;
    }
}
