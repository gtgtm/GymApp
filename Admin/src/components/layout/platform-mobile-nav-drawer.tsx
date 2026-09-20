"use client";

import { useEffect } from "react";
import { createPortal } from "react-dom";
import { XIcon } from "lucide-react";
import { Button } from "@/components/ui/button";
import { PlatformSidebarNav } from "@/components/layout/platform-sidebar";

interface PlatformMobileNavDrawerProps {
  open: boolean;
  onClose: () => void;
}

export function PlatformMobileNavDrawer({ open, onClose }: PlatformMobileNavDrawerProps) {
  useEffect(() => {
    if (!open) return;

    function handleKeyDown(event: KeyboardEvent) {
      if (event.key === "Escape") onClose();
    }

    document.addEventListener("keydown", handleKeyDown);
    document.body.style.overflow = "hidden";

    return () => {
      document.removeEventListener("keydown", handleKeyDown);
      document.body.style.overflow = "";
    };
  }, [open, onClose]);

  if (!open) return null;

  return createPortal(
    <div className="fixed inset-0 z-50 md:hidden" role="dialog" aria-modal="true" aria-label="Navigation">
      <div className="absolute inset-0 bg-black/10 supports-backdrop-filter:backdrop-blur-xs" onClick={onClose} />
      <div className="absolute inset-y-0 left-0 flex h-full w-3/4 max-w-xs flex-col border-r bg-popover text-popover-foreground shadow-lg">
        <Button
          variant="ghost"
          size="icon-sm"
          className="absolute top-3 right-3"
          onClick={onClose}
          title="Close menu"
        >
          <XIcon className="h-4 w-4" />
          <span className="sr-only">Close</span>
        </Button>
        <PlatformSidebarNav onNavigate={onClose} />
      </div>
    </div>,
    document.body,
  );
}
