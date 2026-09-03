<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreMembershipPlanRequest;
use App\Http\Requests\Api\V1\UpdateMembershipPlanRequest;
use App\Models\MembershipPlan;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MembershipPlanController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $plans = MembershipPlan::query()
            ->when($request->string('status')->isNotEmpty(), fn ($query) => $query->where('status', $request->string('status')->value()))
            ->orderBy('price')
            ->get();

        return $this->success($plans);
    }

    public function store(StoreMembershipPlanRequest $request): JsonResponse
    {
        $plan = MembershipPlan::query()->create([
            ...$request->validated(),
            'status' => $request->validated('status') ?? 'active',
        ]);

        return $this->success($plan, status: 201);
    }

    public function show(MembershipPlan $membershipPlan): JsonResponse
    {
        return $this->success($membershipPlan);
    }

    public function update(UpdateMembershipPlanRequest $request, MembershipPlan $membershipPlan): JsonResponse
    {
        $membershipPlan->update($request->validated());

        return $this->success($membershipPlan);
    }

    public function destroy(MembershipPlan $membershipPlan): JsonResponse
    {
        $membershipPlan->delete();

        return $this->success(['message' => 'Membership plan deleted.']);
    }
}
