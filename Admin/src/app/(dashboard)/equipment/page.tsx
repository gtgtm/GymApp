"use client";

import { useSearchParams } from "next/navigation";
import { useEquipmentList, useEquipmentMaintenanceDue } from "@/hooks/use-equipment";
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
import { CreateEquipmentDialog } from "@/components/equipment/create-equipment-dialog";

const CONDITION_STYLES: Record<string, string> = {
  good: "bg-emerald-100 text-emerald-700",
  fair: "bg-amber-100 text-amber-700",
  needs_repair: "bg-orange-100 text-orange-700",
  out_of_service: "bg-red-100 text-red-700",
};

export default function EquipmentPage() {
  const searchParams = useSearchParams();
  const { data: equipment, isLoading } = useEquipmentList();
  const { data: maintenanceDue } = useEquipmentMaintenanceDue();

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold tracking-tight">Equipment</h1>
        <CreateEquipmentDialog defaultOpen={searchParams.get("new") === "1"} />
      </div>

      {maintenanceDue && maintenanceDue.length > 0 && (
        <Card className="border-orange-300 bg-orange-50">
          <CardHeader>
            <CardTitle className="text-orange-800">
              {maintenanceDue.length} item{maintenanceDue.length === 1 ? "" : "s"} need maintenance
              soon
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-1">
            {maintenanceDue.map((item) => (
              <p key={item.id} className="text-sm text-orange-800">
                {item.name} — due{" "}
                {item.next_maintenance_date
                  ? new Date(item.next_maintenance_date).toLocaleDateString()
                  : "—"}
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
              <TableHead>Category</TableHead>
              <TableHead>Purchase Price</TableHead>
              <TableHead>Condition</TableHead>
              <TableHead>Next Maintenance</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {equipment?.length === 0 && (
              <TableRow>
                <TableCell colSpan={5} className="text-center text-muted-foreground">
                  No equipment added yet.
                </TableCell>
              </TableRow>
            )}
            {equipment?.map((item) => (
              <TableRow key={item.id}>
                <TableCell className="font-medium">{item.name}</TableCell>
                <TableCell>{item.category ?? "—"}</TableCell>
                <TableCell>{item.purchase_price ? `₹${item.purchase_price}` : "—"}</TableCell>
                <TableCell>
                  <Badge className={CONDITION_STYLES[item.condition]}>
                    {item.condition.replace("_", " ")}
                  </Badge>
                </TableCell>
                <TableCell>
                  {item.next_maintenance_date
                    ? new Date(item.next_maintenance_date).toLocaleDateString()
                    : "—"}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </div>
  );
}
