<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Enquiry;
use App\Models\Member;
use App\Models\Payment;
use App\Models\Trainer;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GlobalSearchController extends Controller
{
    private const RESULTS_PER_CATEGORY = 5;

    public function index(Request $request): JsonResponse
    {
        $query = trim((string) $request->string('q'));

        if ($query === '') {
            return $this->success([
                'members' => [],
                'trainers' => [],
                'payments' => [],
                'enquiries' => [],
            ]);
        }

        $members = Member::query()
            ->where(function ($q) use ($query) {
                $q->where('full_name', 'like', "%{$query}%")
                    ->orWhere('mobile', 'like', "%{$query}%")
                    ->orWhere('member_code', 'like', "%{$query}%");
            })
            ->limit(self::RESULTS_PER_CATEGORY)
            ->get(['id', 'full_name', 'mobile', 'member_code']);

        $trainers = Trainer::query()
            ->with('user:id,name,phone')
            ->whereHas('user', function ($q) use ($query) {
                $q->where('name', 'like', "%{$query}%")->orWhere('phone', 'like', "%{$query}%");
            })
            ->limit(self::RESULTS_PER_CATEGORY)
            ->get();

        $payments = Payment::query()
            ->with('member:id,full_name')
            ->where('receipt_number', 'like', "%{$query}%")
            ->limit(self::RESULTS_PER_CATEGORY)
            ->get(['id', 'receipt_number', 'amount', 'member_id']);

        $enquiries = Enquiry::query()
            ->where(function ($q) use ($query) {
                $q->where('name', 'like', "%{$query}%")->orWhere('mobile', 'like', "%{$query}%");
            })
            ->limit(self::RESULTS_PER_CATEGORY)
            ->get(['id', 'name', 'mobile', 'status']);

        return $this->success([
            'members' => $members,
            'trainers' => $trainers,
            'payments' => $payments,
            'enquiries' => $enquiries,
        ]);
    }
}
