"use client";

import { useState } from "react";
import { useMembers } from "@/hooks/use-members";
import { useAttendance, useMarkAttendance } from "@/hooks/use-attendance";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Button } from "@/components/ui/button";
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
import { Badge } from "@/components/ui/badge";
import { toast } from "sonner";

const TODAY = new Date().toISOString().slice(0, 10);

export default function AttendancePage() {
  const [search, setSearch] = useState("");
  const [selectedMemberId, setSelectedMemberId] = useState("");
  const { data: membersResponse } = useMembers({ search: search || undefined });
  const { data: attendance, isLoading } = useAttendance(TODAY);
  const markAttendance = useMarkAttendance();

  async function handleMark() {
    if (!selectedMemberId) {
      toast.error("Please select a member.");
      return;
    }

    try {
      const result = await markAttendance.mutateAsync({ member_id: Number(selectedMemberId) });
      toast.success(`Attendance marked. Membership valid until ${result.membership_end_date}.`);
      setSelectedMemberId("");
      setSearch("");
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to mark attendance.";
      toast.error(message);
    }
  }

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-semibold tracking-tight">Attendance</h1>

      <Card>
        <CardHeader>
          <CardTitle>Mark Attendance</CardTitle>
        </CardHeader>
        <CardContent className="flex flex-col gap-4 sm:flex-row">
          <Select value={selectedMemberId} onValueChange={(value) => setSelectedMemberId(value ?? "")}>
            <SelectTrigger className="sm:w-96">
              <SelectValue placeholder="Search member by name, mobile, or ID" />
            </SelectTrigger>
            <SelectContent>
              {membersResponse?.data.map((member) => (
                <SelectItem key={member.id} value={String(member.id)}>
                  {member.full_name} — {member.mobile} ({member.member_code})
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          <Button
            size="lg"
            onClick={() => void handleMark()}
            disabled={markAttendance.isPending}
          >
            {markAttendance.isPending ? "Marking..." : "Mark Present"}
          </Button>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Today&apos;s Attendance</CardTitle>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <Skeleton className="h-48 w-full" />
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Member</TableHead>
                  <TableHead>Check-in Time</TableHead>
                  <TableHead>Status</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {attendance?.length === 0 && (
                  <TableRow>
                    <TableCell colSpan={3} className="text-center text-muted-foreground">
                      No attendance marked yet today.
                    </TableCell>
                  </TableRow>
                )}
                {attendance?.map((entry) => (
                  <TableRow key={entry.id}>
                    <TableCell>{entry.member?.full_name}</TableCell>
                    <TableCell>{entry.check_in_time}</TableCell>
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
    </div>
  );
}
