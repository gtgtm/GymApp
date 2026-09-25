"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { Building2, Users, IndianRupee, Eye, LogIn } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Skeleton } from "@/components/ui/skeleton";
import { useAuth } from "@/hooks/use-auth";
import { usePlatformGyms } from "@/hooks/use-platform";
import type { PlatformGymSummary } from "@/lib/api-types";
import { CreateGymDialog } from "@/components/platform/create-gym-dialog";
import { ToggleGymStatusDialog } from "@/components/platform/toggle-gym-status-dialog";

const PLAN_LABELS: Record<string, string> = {
  starter: "Starter",
  professional: "Professional",
  enterprise: "Enterprise",
};

const PAYMENT_STATUS_VARIANT = {
  active: "default",
  past_due: "destructive",
  cancelled: "secondary",
} as const;

export default function GymsPage() {
  const { enterGym } = useAuth();
  const router = useRouter();
  const { data: gyms, isLoading, isError, refetch } = usePlatformGyms();

  function handleEnter(gym: PlatformGymSummary) {
    enterGym({ id: gym.id, name: gym.name });
    router.push("/dashboard");
  }

  if (isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-8 w-40" />
        <Skeleton className="h-96 w-full" />
      </div>
    );
  }

  if (isError || !gyms) {
    return (
      <Card>
        <CardContent className="flex flex-col items-center gap-3 py-10 text-center">
          <p className="text-sm text-muted-foreground">Failed to load gyms.</p>
          <Button variant="outline" onClick={() => void refetch()}>
            Retry
          </Button>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">Gyms</h1>
          <p className="text-sm text-muted-foreground">{gyms.length} gyms on GymBrain.</p>
        </div>
        <CreateGymDialog />
      </div>

      <Card>
        {gyms.length === 0 ? (
          <CardContent className="flex flex-col items-center gap-2 py-10 text-center">
            <Building2 className="h-8 w-8 text-muted-foreground" />
            <p className="text-sm text-muted-foreground">No gyms yet.</p>
          </CardContent>
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Gym</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Members</TableHead>
                <TableHead>Plan</TableHead>
                <TableHead>Billing</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {gyms.map((gym) => (
                <TableRow key={gym.id}>
                  <TableCell className="font-medium">
                    <Link href={`/gyms/view?id=${gym.id}`} className="hover:underline">
                      {gym.name}
                    </Link>
                  </TableCell>
                  <TableCell>
                    <Badge variant={gym.status === "active" ? "default" : "secondary"}>
                      {gym.status}
                    </Badge>
                  </TableCell>
                  <TableCell>
                    <span className="inline-flex items-center gap-1.5 text-muted-foreground">
                      <Users className="h-3.5 w-3.5" />
                      {gym.members_count}
                    </span>
                  </TableCell>
                  <TableCell>
                    {gym.subscription ? (
                      <span className="inline-flex items-center gap-1.5">
                        <IndianRupee className="h-3.5 w-3.5 text-muted-foreground" />
                        {PLAN_LABELS[gym.subscription.plan] ?? gym.subscription.plan}
                      </span>
                    ) : (
                      <span className="text-muted-foreground">No plan</span>
                    )}
                  </TableCell>
                  <TableCell>
                    {gym.subscription ? (
                      <Badge variant={PAYMENT_STATUS_VARIANT[gym.subscription.payment_status]}>
                        {gym.subscription.payment_status.replace("_", " ")}
                      </Badge>
                    ) : (
                      "—"
                    )}
                  </TableCell>
                  <TableCell className="text-right">
                    <div className="flex justify-end gap-2">
                      <Button
                        variant="outline"
                        size="icon-sm"
                        title="Details"
                        nativeButton={false}
                        render={<Link href={`/gyms/view?id=${gym.id}`} />}
                      >
                        <Eye className="h-3.5 w-3.5" />
                      </Button>
                      <Button
                        size="icon-sm"
                        title="Enter as Admin"
                        onClick={() => handleEnter(gym)}
                      >
                        <LogIn className="h-3.5 w-3.5" />
                      </Button>
                      <ToggleGymStatusDialog
                        gymId={gym.id}
                        gymName={gym.name}
                        status={gym.status}
                        iconOnly
                      />
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </Card>
    </div>
  );
}
