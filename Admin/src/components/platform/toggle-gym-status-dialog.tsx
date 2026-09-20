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
import { useUpdateGym } from "@/hooks/use-platform";
import { toast } from "sonner";
import { Ban, CheckCircle2 } from "lucide-react";

export function ToggleGymStatusDialog({
  gymId,
  gymName,
  status,
  iconOnly = false,
}: {
  gymId: number;
  gymName: string;
  status: string;
  iconOnly?: boolean;
}) {
  const [open, setOpen] = useState(false);
  const updateGym = useUpdateGym(gymId);
  const isActive = status === "active";
  const nextStatus = isActive ? "inactive" : "active";
  const actionLabel = isActive ? "Disable" : "Enable";

  async function handleConfirm() {
    try {
      await updateGym.mutateAsync({ status: nextStatus });
      toast.success(isActive ? `${gymName} has been disabled.` : `${gymName} has been enabled.`);
      setOpen(false);
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to update gym status.";
      toast.error(message);
    }
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger
        render={
          iconOnly ? (
            <Button
              variant={isActive ? "destructive" : "outline"}
              size="icon-sm"
              title={actionLabel}
            >
              {isActive ? <Ban className="h-3.5 w-3.5" /> : <CheckCircle2 className="h-3.5 w-3.5" />}
            </Button>
          ) : (
            <Button variant={isActive ? "destructive" : "outline"} size="sm" className="gap-1.5">
              {isActive ? (
                <Ban className="h-3.5 w-3.5" />
              ) : (
                <CheckCircle2 className="h-3.5 w-3.5" />
              )}
              {actionLabel}
            </Button>
          )
        }
      />
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{isActive ? "Disable" : "Enable"} {gymName}?</DialogTitle>
        </DialogHeader>
        <p className="text-sm text-muted-foreground">
          {isActive
            ? "Staff at this gym will be immediately blocked from signing in. Existing data is kept and this can be reversed at any time."
            : "Staff at this gym will be able to sign in again."}
        </p>
        <DialogFooter>
          <DialogClose render={<Button variant="outline">Cancel</Button>} />
          <Button
            variant={isActive ? "destructive" : "default"}
            onClick={() => void handleConfirm()}
            disabled={updateGym.isPending}
          >
            {updateGym.isPending ? "Saving..." : isActive ? "Disable Gym" : "Enable Gym"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
