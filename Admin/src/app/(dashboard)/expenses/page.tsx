"use client";

import { useSearchParams } from "next/navigation";
import { useExpenses } from "@/hooks/use-expenses";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { CreateExpenseDialog } from "@/components/expenses/create-expense-dialog";

export default function ExpensesPage() {
  const searchParams = useSearchParams();
  const { data: expenses, isLoading } = useExpenses();

  const total = expenses?.reduce((sum, expense) => sum + Number(expense.amount), 0) ?? 0;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold tracking-tight">Expenses</h1>
        <CreateExpenseDialog defaultOpen={searchParams.get("new") === "1"} />
      </div>

      {isLoading ? (
        <Skeleton className="h-64 w-full" />
      ) : (
        <>
          <p className="text-sm text-muted-foreground">
            Total: <span className="font-semibold text-foreground">₹{total.toLocaleString("en-IN")}</span>
          </p>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Category</TableHead>
                <TableHead>Amount</TableHead>
                <TableHead>Date</TableHead>
                <TableHead>Description</TableHead>
                <TableHead>Payment Method</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {expenses?.length === 0 && (
                <TableRow>
                  <TableCell colSpan={5} className="text-center text-muted-foreground">
                    No expenses recorded yet.
                  </TableCell>
                </TableRow>
              )}
              {expenses?.map((expense) => (
                <TableRow key={expense.id}>
                  <TableCell>
                    <Badge variant="secondary" className="capitalize">
                      {expense.category}
                    </Badge>
                  </TableCell>
                  <TableCell>₹{expense.amount}</TableCell>
                  <TableCell>{new Date(expense.expense_date).toLocaleDateString()}</TableCell>
                  <TableCell>{expense.description ?? "—"}</TableCell>
                  <TableCell className="capitalize">
                    {expense.payment_method?.replace("_", " ") ?? "—"}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </>
      )}
    </div>
  );
}
