<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Member;
use Illuminate\Support\Str;

class MemberService
{
    public function __construct(private readonly GymMembershipService $gymMembershipService) {}

    public function create(array $data): Member
    {
        $password = $data['password'] ?? null;
        unset($data['password']);

        $data['member_code'] = $this->generateMemberCode();
        $data['qr_token'] = $this->generateQrToken();
        $data['gym_id'] = $data['gym_id'] ?? app(ActingGymContext::class)->gymId();

        return $this->gymMembershipService->joinGym($data, $password, $data['gym_id']);
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
