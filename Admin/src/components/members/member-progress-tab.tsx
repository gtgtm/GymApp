"use client";

import { useBodyMeasurements } from "@/hooks/use-progress";
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
import { AddMeasurementDialog } from "@/components/progress/add-measurement-dialog";
import { ProgressChart } from "@/components/progress/progress-chart";

export function MemberProgressTab({ memberId }: { memberId: number }) {
  const { data: measurements, isLoading } = useBodyMeasurements(memberId);

  if (isLoading) {
    return <Skeleton className="h-64 w-full" />;
  }

  return (
    <div className="space-y-4">
      <div className="flex justify-end">
        <AddMeasurementDialog memberId={memberId} />
      </div>

      {measurements && measurements.length > 0 ? (
        <>
          <Card>
            <CardHeader>
              <CardTitle>Weight & BMI Trend</CardTitle>
            </CardHeader>
            <CardContent>
              <ProgressChart measurements={measurements} />
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Measurement History</CardTitle>
            </CardHeader>
            <CardContent>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Date</TableHead>
                    <TableHead>Weight</TableHead>
                    <TableHead>BMI</TableHead>
                    <TableHead>Body Fat %</TableHead>
                    <TableHead>Chest</TableHead>
                    <TableHead>Waist</TableHead>
                    <TableHead>Arms</TableHead>
                    <TableHead>Thigh</TableHead>
                    <TableHead>Hips</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {measurements
                    .slice()
                    .reverse()
                    .map((entry) => (
                      <TableRow key={entry.id}>
                        <TableCell>
                          {new Date(entry.recorded_date).toLocaleDateString()}
                        </TableCell>
                        <TableCell>{entry.weight_kg ?? "—"}</TableCell>
                        <TableCell>{entry.bmi ?? "—"}</TableCell>
                        <TableCell>{entry.body_fat_percent ?? "—"}</TableCell>
                        <TableCell>{entry.chest_cm ?? "—"}</TableCell>
                        <TableCell>{entry.waist_cm ?? "—"}</TableCell>
                        <TableCell>{entry.arms_cm ?? "—"}</TableCell>
                        <TableCell>{entry.thigh_cm ?? "—"}</TableCell>
                        <TableCell>{entry.hips_cm ?? "—"}</TableCell>
                      </TableRow>
                    ))}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </>
      ) : (
        <p className="text-sm text-muted-foreground">No progress measurements recorded yet.</p>
      )}
    </div>
  );
}
