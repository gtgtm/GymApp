"use client";

import { useQuery } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type { ApiResponse, Payment } from "@/lib/api-types";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Skeleton } from "@/components/ui/skeleton";

export function MemberPaymentsTab({ memberId }: { memberId: number }) {
  const { data: payments, isLoading } = useQuery({
    queryKey: ["members", memberId, "payments"],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<Payment[]>>(
        `/members/${memberId}/payments`,
      );
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });

  return (
    <Card>
      <CardHeader>
        <CardTitle>Payment History</CardTitle>
      </CardHeader>
      <CardContent>
        {isLoading ? (
          <Skeleton className="h-32 w-full" />
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Receipt</TableHead>
                <TableHead>Amount</TableHead>
                <TableHead>Method</TableHead>
                <TableHead>Date</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {payments?.length === 0 && (
                <TableRow>
                  <TableCell colSpan={4} className="text-center text-muted-foreground">
                    No payments recorded yet.
                  </TableCell>
                </TableRow>
              )}
              {payments?.map((payment) => (
                <TableRow key={payment.id}>
                  <TableCell>{payment.receipt_number}</TableCell>
                  <TableCell>₹{payment.amount}</TableCell>
                  <TableCell className="capitalize">{payment.method.replace("_", " ")}</TableCell>
                  <TableCell>{new Date(payment.paid_at).toLocaleDateString()}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </CardContent>
    </Card>
  );
}
