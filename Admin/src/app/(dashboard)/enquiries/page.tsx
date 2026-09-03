"use client";

import { useSearchParams } from "next/navigation";
import { useEnquiries, useConversionStats } from "@/hooks/use-enquiries";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { CreateEnquiryDialog } from "@/components/enquiries/create-enquiry-dialog";
import { EnquiryStatusSelect } from "@/components/enquiries/enquiry-status-select";

export default function EnquiriesPage() {
  const searchParams = useSearchParams();
  const { data: enquiries, isLoading } = useEnquiries();
  const { data: stats } = useConversionStats();

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold tracking-tight">Enquiries</h1>
        <CreateEnquiryDialog defaultOpen={searchParams.get("new") === "1"} />
      </div>

      {stats && (
        <Card>
          <CardHeader>
            <CardTitle>Conversion Rate</CardTitle>
          </CardHeader>
          <CardContent className="flex items-center gap-6">
            <div>
              <p className="text-3xl font-bold">{stats.conversion_rate}%</p>
              <p className="text-sm text-muted-foreground">
                {stats.converted} converted of {stats.total} total enquiries
              </p>
            </div>
          </CardContent>
        </Card>
      )}

      {isLoading ? (
        <Skeleton className="h-64 w-full" />
      ) : (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Name</TableHead>
              <TableHead>Mobile</TableHead>
              <TableHead>Source</TableHead>
              <TableHead>Interested Plan</TableHead>
              <TableHead>Follow-up</TableHead>
              <TableHead>Status</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {enquiries?.length === 0 && (
              <TableRow>
                <TableCell colSpan={6} className="text-center text-muted-foreground">
                  No enquiries yet.
                </TableCell>
              </TableRow>
            )}
            {enquiries?.map((enquiry) => (
              <TableRow key={enquiry.id}>
                <TableCell className="font-medium">{enquiry.name}</TableCell>
                <TableCell>{enquiry.mobile}</TableCell>
                <TableCell>{enquiry.source ?? "—"}</TableCell>
                <TableCell>{enquiry.interested_plan?.name ?? "—"}</TableCell>
                <TableCell>
                  {enquiry.follow_up_date
                    ? new Date(enquiry.follow_up_date).toLocaleDateString()
                    : "—"}
                </TableCell>
                <TableCell>
                  <EnquiryStatusSelect id={enquiry.id} status={enquiry.status} />
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </div>
  );
}
