"use client";

import { useState } from "react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogFooter,
  DialogClose,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { useDeleteSubscriptionPlan } from "@/hooks/use-subscription-plans";
import { toast } from "sonner";
import { Trash2 } from "lucide-react";

export function DeleteSubscriptionPlanDialog({
  planId,
  planName,
}: {
  planId: number;
  planName: string;
}) {
  const [open, setOpen] = useState(false);
  const deletePlan = useDeleteSubscriptionPlan();

  async function handleConfirm() {
    try {
      await deletePlan.mutateAsync(planId);
      toast.success(`${planName} plan deleted.`);
      setOpen(false);
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to delete plan.";
      toast.error(message);
    }
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger
        render={
          <Button variant="destructive" size="icon-sm" title="Delete">
            <Trash2 className="h-3.5 w-3.5" />
          </Button>
        }
      />
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Delete {planName}?</DialogTitle>
        </DialogHeader>
        <p className="text-sm text-muted-foreground">
          Existing subscriptions already on this plan are not affected, but it will no longer be
          offered when assigning a new subscription.
        </p>
        <DialogFooter>
          <DialogClose render={<Button variant="outline">Cancel</Button>} />
          <Button
            variant="destructive"
            onClick={() => void handleConfirm()}
            disabled={deletePlan.isPending}
          >
            {deletePlan.isPending ? "Deleting..." : "Delete Plan"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
