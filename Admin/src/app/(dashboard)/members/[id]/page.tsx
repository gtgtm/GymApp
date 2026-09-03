"use client";

import { use } from "react";
import { useMember } from "@/hooks/use-members";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { ExpiryBadge } from "@/components/members/expiry-badge";
import { RenewMembershipDialog } from "@/components/members/renew-membership-dialog";
import { MemberPaymentsTab } from "@/components/members/member-payments-tab";
import { MemberAttendanceTab } from "@/components/members/member-attendance-tab";

export default function MemberDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const memberId = Number(id);
  const { data: member, isLoading } = useMember(memberId);

  if (isLoading || !member) {
    return <Skeleton className="h-64 w-full" />;
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">{member.full_name}</h1>
          <p className="text-sm text-muted-foreground">
            {member.member_code} · {member.mobile}
          </p>
        </div>
        <div className="flex items-center gap-3">
          <ExpiryBadge bucket={member.expiry_bucket} />
          <RenewMembershipDialog memberId={memberId} />
        </div>
      </div>

      <Tabs defaultValue="overview">
        <TabsList>
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="membership">Membership</TabsTrigger>
          <TabsTrigger value="payments">Payments</TabsTrigger>
          <TabsTrigger value="attendance">Attendance</TabsTrigger>
        </TabsList>

        <TabsContent value="overview">
          <Card>
            <CardHeader>
              <CardTitle>Basic Information</CardTitle>
            </CardHeader>
            <CardContent className="grid grid-cols-2 gap-4 text-sm">
              <Field label="Email" value={member.email} />
              <Field label="Date of Birth" value={member.date_of_birth} />
              <Field label="Gender" value={member.gender} />
              <Field label="Address" value={member.address} />
              <Field label="Emergency Contact" value={member.emergency_contact_name} />
              <Field label="Emergency Phone" value={member.emergency_contact_phone} />
              <Field label="Joining Date" value={member.joining_date} />
              <Field label="Trainer" value={member.trainer?.name} />
              <Field label="Height (cm)" value={member.height_cm} />
              <Field label="Weight (kg)" value={member.weight_kg} />
              <Field label="Blood Group" value={member.blood_group} />
              <Field label="Notes" value={member.notes} />
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="membership">
          <Card>
            <CardHeader>
              <CardTitle>Current Membership</CardTitle>
            </CardHeader>
            <CardContent className="grid grid-cols-2 gap-4 text-sm">
              <Field label="Start Date" value={member.current_membership?.start_date} />
              <Field label="End Date" value={member.current_membership?.end_date} />
              <Field label="Status" value={member.current_membership?.status} />
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="payments">
          <MemberPaymentsTab memberId={memberId} />
        </TabsContent>

        <TabsContent value="attendance">
          <MemberAttendanceTab memberId={memberId} />
        </TabsContent>
      </Tabs>
    </div>
  );
}

function Field({ label, value }: { label: string; value?: string | null }) {
  return (
    <div>
      <p className="text-xs text-muted-foreground">{label}</p>
      <p className="font-medium">{value || "—"}</p>
    </div>
  );
}
