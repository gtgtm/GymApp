<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreExpenseRequest;
use App\Http\Requests\Api\V1\UpdateExpenseRequest;
use App\Models\Expense;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ExpenseController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $expenses = Expense::query()
            ->when($request->date('from'), fn ($query, $from) => $query->whereDate('expense_date', '>=', $from))
            ->when($request->date('to'), fn ($query, $to) => $query->whereDate('expense_date', '<=', $to))
            ->when($request->string('category')->isNotEmpty(), fn ($query) => $query->where('category', $request->string('category')->value()))
            ->latest('expense_date')
            ->get();

        return $this->success($expenses);
    }

    public function store(StoreExpenseRequest $request): JsonResponse
    {
        $expense = Expense::query()->create([
            ...$request->validated(),
            'recorded_by' => auth()->id(),
        ]);

        return $this->success($expense, status: 201);
    }

    public function show(Expense $expense): JsonResponse
    {
        return $this->success($expense);
    }

    public function update(UpdateExpenseRequest $request, Expense $expense): JsonResponse
    {
        $expense->update($request->validated());

        return $this->success($expense);
    }

    public function destroy(Expense $expense): JsonResponse
    {
        $expense->delete();

        return $this->success(['message' => 'Expense deleted.']);
    }
}
