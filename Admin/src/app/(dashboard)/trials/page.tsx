"use client";

import { useSearchParams } from "next/navigation";
import { useTrials, useExpiringSoonTrials } from "@/hooks/use-trials";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { CreateTrialDialog } from "@/components/trials/create-trial-dialog";

const STATUS_STYLES: Record<string, string> = {
  active: "bg-emerald-100 text-emerald-700",
  expired: "bg-red-100 text-red-700",
  converted: "bg-blue-100 text-blue-700",
};

export default function TrialsPage() {
  const searchParams = useSearchParams();
  const { data: trials, isLoading } = useTrials();
  const { data: expiringSoon } = useExpiringSoonTrials();

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold tracking-tight">Trials</h1>
        <CreateTrialDialog defaultOpen={searchParams.get("new") === "1"} />
      </div>

      {expiringSoon && expiringSoon.length > 0 && (
        <Card className="border-amber-300 bg-amber-50">
          <CardHeader>
            <CardTitle className="text-amber-800">
              {expiringSoon.length} trial{expiringSoon.length === 1 ? "" : "s"} expiring within 3
              days
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-1">
            {expiringSoon.map((trial) => (
              <p key={trial.id} className="text-sm text-amber-800">
                {trial.name} ({trial.mobile}) — ends{" "}
                {new Date(trial.trial_end).toLocaleDateString()}
              </p>
            ))}
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
              <TableHead>Trial Period</TableHead>
              <TableHead>Trainer</TableHead>
              <TableHead>Status</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {trials?.length === 0 && (
              <TableRow>
                <TableCell colSpan={5} className="text-center text-muted-foreground">
                  No trials yet.
                </TableCell>
              </TableRow>
            )}
            {trials?.map((trial) => (
              <TableRow key={trial.id}>
                <TableCell className="font-medium">{trial.name}</TableCell>
                <TableCell>{trial.mobile}</TableCell>
                <TableCell>
                  {new Date(trial.trial_start).toLocaleDateString()} –{" "}
                  {new Date(trial.trial_end).toLocaleDateString()}
                </TableCell>
                <TableCell>{trial.trainer?.user.name ?? "—"}</TableCell>
                <TableCell>
                  <Badge className={STATUS_STYLES[trial.status]}>{trial.status}</Badge>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </div>
  );
}
