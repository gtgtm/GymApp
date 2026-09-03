<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Member;
use Illuminate\Support\Str;

class MemberService
{
    public function create(array $data): Member
    {
        $data['member_code'] = $this->generateMemberCode();

        return Member::query()->create($data);
    }

    private function generateMemberCode(): string
    {
        do {
            $code = 'MEM-'.strtoupper(Str::random(8));
        } while (Member::withoutGlobalScopes()->where('member_code', $code)->exists());

        return $code;
    }
}
