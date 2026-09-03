"use client";

import { useQuery } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type { ApiResponse } from "@/lib/api-types";
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
import { Badge } from "@/components/ui/badge";

interface AttendanceEntry {
  id: number;
  date: string;
  check_in_time: string | null;
  status: string;
}

export function MemberAttendanceTab({ memberId }: { memberId: number }) {
  const { data: attendance, isLoading } = useQuery({
    queryKey: ["members", memberId, "attendance"],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<AttendanceEntry[]>>("/attendance", {
        params: { member_id: memberId },
      });
      if (!data.success) throw new Error(data.error.message);
      return data.data;
    },
  });

  return (
    <Card>
      <CardHeader>
        <CardTitle>Attendance History</CardTitle>
        <p className="text-sm text-muted-foreground">
          Total visits: {attendance?.length ?? 0}
        </p>
      </CardHeader>
      <CardContent>
        {isLoading ? (
          <Skeleton className="h-32 w-full" />
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Date</TableHead>
                <TableHead>Check-in Time</TableHead>
                <TableHead>Status</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {attendance?.length === 0 && (
                <TableRow>
                  <TableCell colSpan={3} className="text-center text-muted-foreground">
                    No attendance recorded yet.
                  </TableCell>
                </TableRow>
              )}
              {attendance?.map((entry) => (
                <TableRow key={entry.id}>
                  <TableCell>{entry.date}</TableCell>
                  <TableCell>{entry.check_in_time ?? "—"}</TableCell>
                  <TableCell>
                    <Badge variant="secondary" className="capitalize">
                      {entry.status}
                    </Badge>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </CardContent>
    </Card>
  );
}
