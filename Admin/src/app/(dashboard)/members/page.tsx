"use client";

import { useState } from "react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { useMembers } from "@/hooks/use-members";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Input } from "@/components/ui/input";
import { Skeleton } from "@/components/ui/skeleton";
import { ExpiryBadge } from "@/components/members/expiry-badge";
import { CreateMemberDialog } from "@/components/members/create-member-dialog";

export default function MembersPage() {
  const searchParams = useSearchParams();
  const [search, setSearch] = useState("");
  const { data, isLoading } = useMembers({ search: search || undefined });

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold tracking-tight">Members</h1>
        <CreateMemberDialog defaultOpen={searchParams.get("new") === "1"} />
      </div>

      <Input
        placeholder="Search by name, mobile, or member ID"
        value={search}
        onChange={(event) => setSearch(event.target.value)}
        className="max-w-sm"
      />

      {isLoading ? (
        <div className="space-y-2">
          {Array.from({ length: 5 }).map((_, index) => (
            <Skeleton key={index} className="h-12 w-full" />
          ))}
        </div>
      ) : (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Member</TableHead>
              <TableHead>Mobile</TableHead>
              <TableHead>Trainer</TableHead>
              <TableHead>Membership Ends</TableHead>
              <TableHead>Status</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {data?.data.length === 0 && (
              <TableRow>
                <TableCell colSpan={5} className="text-center text-muted-foreground">
                  No members found.
                </TableCell>
              </TableRow>
            )}
            {data?.data.map((member) => (
              <TableRow key={member.id}>
                <TableCell>
                  <Link href={`/members/${member.id}`} className="font-medium hover:underline">
                    {member.full_name}
                  </Link>
                  <p className="text-xs text-muted-foreground">{member.member_code}</p>
                </TableCell>
                <TableCell>{member.mobile}</TableCell>
                <TableCell>{member.trainer?.name ?? "—"}</TableCell>
                <TableCell>{member.current_membership?.end_date ?? "—"}</TableCell>
                <TableCell>
                  <ExpiryBadge bucket={member.expiry_bucket} />
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </div>
  );
}
