"use client";

import { useSearchParams } from "next/navigation";
import { usePayments } from "@/hooks/use-payments";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Skeleton } from "@/components/ui/skeleton";
import { CreatePaymentDialog } from "@/components/payments/create-payment-dialog";

export default function PaymentsPage() {
  const searchParams = useSearchParams();
  const { data: payments, isLoading } = usePayments();

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold tracking-tight">Payments</h1>
        <CreatePaymentDialog defaultOpen={searchParams.get("new") === "1"} />
      </div>

      {isLoading ? (
        <Skeleton className="h-64 w-full" />
      ) : (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Receipt</TableHead>
              <TableHead>Member</TableHead>
              <TableHead>Amount</TableHead>
              <TableHead>Method</TableHead>
              <TableHead>Date</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {payments?.length === 0 && (
              <TableRow>
                <TableCell colSpan={5} className="text-center text-muted-foreground">
                  No payments recorded yet.
                </TableCell>
              </TableRow>
            )}
            {payments?.map((payment) => (
              <TableRow key={payment.id}>
                <TableCell>{payment.receipt_number}</TableCell>
                <TableCell>{payment.member?.full_name ?? "—"}</TableCell>
                <TableCell>₹{payment.amount}</TableCell>
                <TableCell className="capitalize">{payment.method.replace("_", " ")}</TableCell>
                <TableCell>{new Date(payment.paid_at).toLocaleDateString()}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </div>
  );
}
