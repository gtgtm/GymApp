<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Member;
use App\Models\Role;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class MemberService
{
    public function create(array $data): Member
    {
        return DB::transaction(function () use ($data) {
            $password = $data['password'] ?? null;
            unset($data['password']);

            $data['member_code'] = $this->generateMemberCode();
            $data['qr_token'] = $this->generateQrToken();

            if ($password) {
                $data['user_id'] = $this->createMemberAccount($data, $password)->id;
            }

            return Member::query()->create($data);
        });
    }

    private function createMemberAccount(array $memberData, string $password): User
    {
        $memberRoleId = Role::query()->where('name', Role::MEMBER)->value('id');

        return User::query()->create([
            'gym_id' => $memberData['gym_id'] ?? auth()->user()->gym_id,
            'role_id' => $memberRoleId,
            'name' => $memberData['full_name'],
            'email' => $memberData['email'] ?? $this->placeholderEmail($memberData),
            'phone' => $memberData['mobile'] ?? null,
            'password' => Hash::make($password),
            'status' => 'active',
        ]);
    }

    private function placeholderEmail(array $memberData): string
    {
        return 'member-'.Str::random(10).'@members.local';
    }

    private function generateMemberCode(): string
    {
        do {
            $code = 'MEM-'.strtoupper(Str::random(8));
        } while (Member::withoutGlobalScopes()->where('member_code', $code)->exists());

        return $code;
    }

    private function generateQrToken(): string
    {
        do {
            $token = Str::random(48);
        } while (Member::withoutGlobalScopes()->where('qr_token', $token)->exists());

        return $token;
    }
}
