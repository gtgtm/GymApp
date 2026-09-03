"use client";

import { useSearchParams } from "next/navigation";
import { useTrainers } from "@/hooks/use-trainers";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { CreateTrainerDialog } from "@/components/trainers/create-trainer-dialog";

export default function TrainersPage() {
  const searchParams = useSearchParams();
  const { data: trainers, isLoading } = useTrainers();

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold tracking-tight">Trainers</h1>
        <CreateTrainerDialog defaultOpen={searchParams.get("new") === "1"} />
      </div>

      {isLoading ? (
        <Skeleton className="h-64 w-full" />
      ) : (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Name</TableHead>
              <TableHead>Contact</TableHead>
              <TableHead>Specialization</TableHead>
              <TableHead>Assigned Members</TableHead>
              <TableHead>Status</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {trainers?.length === 0 && (
              <TableRow>
                <TableCell colSpan={5} className="text-center text-muted-foreground">
                  No trainers added yet.
                </TableCell>
              </TableRow>
            )}
            {trainers?.map((trainer) => (
              <TableRow key={trainer.id}>
                <TableCell className="font-medium">{trainer.user.name}</TableCell>
                <TableCell>
                  <p>{trainer.user.email}</p>
                  {trainer.user.phone && (
                    <p className="text-xs text-muted-foreground">{trainer.user.phone}</p>
                  )}
                </TableCell>
                <TableCell>{trainer.specialization ?? "—"}</TableCell>
                <TableCell>{trainer.assigned_members_count ?? 0}</TableCell>
                <TableCell>
                  <Badge variant={trainer.status === "active" ? "default" : "secondary"}>
                    {trainer.status}
                  </Badge>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </div>
  );
}
