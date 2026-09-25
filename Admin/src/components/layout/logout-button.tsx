"use client";

import { useState } from "react";
import { Loader2, LogOut } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { useAuth } from "@/hooks/use-auth";

/** Header logout icon that asks for confirmation before ending the session. */
export function LogoutButton() {
  const { user, logout } = useAuth();
  const [open, setOpen] = useState(false);
  const [isLoggingOut, setIsLoggingOut] = useState(false);

  async function handleConfirm() {
    setIsLoggingOut(true);
    try {
      await logout();
    } catch {
      // logout() always clears the local session and redirects, even when
      // the server-side token revoke fails, so there is nothing to recover.
    } finally {
      setIsLoggingOut(false);
      setOpen(false);
    }
  }

  return (
    <Dialog open={open} onOpenChange={(next) => !isLoggingOut && setOpen(next)}>
      <DialogTrigger
        render={
          <Button variant="ghost" size="icon" title="Log out" aria-label="Log out">
            <LogOut className="h-4 w-4" />
          </Button>
        }
      />
      <DialogContent className="sm:max-w-sm">
        <DialogHeader>
          <DialogTitle>Log out?</DialogTitle>
          <DialogDescription>
            {user?.email ? (
              <>
                You&apos;ll be signed out of <span className="font-medium text-foreground">{user.email}</span>{" "}
                on this device.
              </>
            ) : (
              "You'll be signed out on this device."
            )}
          </DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <DialogClose render={<Button variant="outline" disabled={isLoggingOut}>Cancel</Button>} />
          <Button
            variant="destructive"
            onClick={() => void handleConfirm()}
            disabled={isLoggingOut}
            className="gap-1.5"
          >
            {isLoggingOut ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              <LogOut className="h-4 w-4" />
            )}
            {isLoggingOut ? "Logging out..." : "Log out"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
