"use client";

import { useState, type FormEvent } from "react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { useCreateExpense } from "@/hooks/use-expenses";
import type { ExpenseCategory } from "@/lib/api-types";
import { toast } from "sonner";

const CATEGORIES: ExpenseCategory[] = [
  "rent",
  "electricity",
  "equipment",
  "maintenance",
  "salary",
  "marketing",
  "cleaning",
  "other",
];

const TODAY = new Date().toISOString().slice(0, 10);

export function CreateExpenseDialog({ defaultOpen = false }: { defaultOpen?: boolean }) {
  const [open, setOpen] = useState(defaultOpen);
  const [category, setCategory] = useState<ExpenseCategory>("rent");
  const [amount, setAmount] = useState("");
  const [expenseDate, setExpenseDate] = useState(TODAY);
  const [description, setDescription] = useState("");
  const createExpense = useCreateExpense();

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    try {
      await createExpense.mutateAsync({
        category,
        amount: Number(amount),
        expense_date: expenseDate,
        description: description || undefined,
      });
      toast.success("Expense recorded.");
      setOpen(false);
      setAmount("");
      setDescription("");
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to record expense.";
      toast.error(message);
    }
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger render={<Button>Add Expense</Button>} />
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Add Expense</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label>Category</Label>
            <Select
              value={category}
              onValueChange={(value) => setCategory((value ?? "rent") as ExpenseCategory)}
            >
              <SelectTrigger className="w-full">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {CATEGORIES.map((cat) => (
                  <SelectItem key={cat} value={cat}>
                    {cat.charAt(0).toUpperCase() + cat.slice(1)}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <Label htmlFor="amount">Amount</Label>
            <Input
              id="amount"
              type="number"
              min="0.01"
              step="0.01"
              required
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="expense_date">Date</Label>
            <Input
              id="expense_date"
              type="date"
              required
              value={expenseDate}
              onChange={(e) => setExpenseDate(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="description">Description (optional)</Label>
            <Input
              id="description"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
            />
          </div>
          <Button type="submit" className="w-full" disabled={createExpense.isPending}>
            {createExpense.isPending ? "Saving..." : "Save Expense"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
