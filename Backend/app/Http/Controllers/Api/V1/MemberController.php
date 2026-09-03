<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\RenewMembershipRequest;
use App\Http\Requests\Api\V1\StoreMemberRequest;
use App\Http\Requests\Api\V1\UpdateMemberRequest;
use App\Http\Resources\Api\V1\MemberResource;
use App\Models\Member;
use App\Models\MembershipPlan;
use App\Models\Payment;
use App\Services\AuditLogService;
use App\Services\MemberService;
use App\Services\RenewalService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MemberController extends Controller
{
    public function __construct(
        private readonly MemberService $memberService,
        private readonly RenewalService $renewalService,
        private readonly AuditLogService $auditLog,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $members = Member::query()
            ->with('trainer')
            ->when($request->string('search')->isNotEmpty(), function ($query) use ($request) {
                $search = $request->string('search')->value();
                $query->where(function ($q) use ($search) {
                    $q->where('full_name', 'like', "%{$search}%")
                        ->orWhere('mobile', 'like', "%{$search}%")
                        ->orWhere('member_code', 'like', "%{$search}%");
                });
            })
            ->when($request->string('status')->isNotEmpty(), fn ($query) => $query->where('status', $request->string('status')->value()))
            ->latest()
            ->paginate($request->integer('per_page', 20));

        return $this->success(
            MemberResource::collection($members->items()),
            [
                'total' => $members->total(),
                'page' => $members->currentPage(),
                'limit' => $members->perPage(),
            ]
        );
    }

    public function store(StoreMemberRequest $request): JsonResponse
    {
        $member = $this->memberService->create($request->validated());

        $this->auditLog->log('member.created', $member, null, $member->toArray());

        return $this->success(new MemberResource($member), status: 201);
    }

    public function show(Member $member): JsonResponse
    {
        return $this->success(new MemberResource($member->load('trainer')));
    }

    public function update(UpdateMemberRequest $request, Member $member): JsonResponse
    {
        $before = $member->toArray();
        $member->update($request->validated());

        $this->auditLog->log('member.updated', $member, $before, $member->toArray());

        return $this->success(new MemberResource($member));
    }

    public function destroy(Member $member): JsonResponse
    {
        $this->auditLog->log('member.deleted', $member, $member->toArray());
        $member->delete();

        return $this->success(['message' => 'Member deleted.']);
    }

    public function renew(RenewMembershipRequest $request, Member $member): JsonResponse
    {
        $plan = MembershipPlan::query()->findOrFail($request->validated('membership_plan_id'));

        $renewal = $this->renewalService->renew($member, $plan, $request->validated());

        $this->auditLog->log('membership.renewed', $member, null, $renewal->toArray());

        return $this->success($renewal->load('plan'), status: 201);
    }

    public function payments(Member $member): JsonResponse
    {
        $payments = Payment::query()
            ->where('member_id', $member->id)
            ->latest('paid_at')
            ->get();

        return $this->success($payments);
    }
}
