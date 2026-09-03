"use client";

import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { useUpdateEnquiryStatus } from "@/hooks/use-enquiries";
import type { EnquiryStatus } from "@/lib/api-types";
import { toast } from "sonner";

const STATUSES: { value: EnquiryStatus; label: string }[] = [
  { value: "new", label: "New" },
  { value: "contacted", label: "Contacted" },
  { value: "trial", label: "Trial" },
  { value: "follow_up", label: "Follow-up" },
  { value: "converted", label: "Converted" },
  { value: "lost", label: "Lost" },
];

export function EnquiryStatusSelect({ id, status }: { id: number; status: EnquiryStatus }) {
  const updateStatus = useUpdateEnquiryStatus();

  async function handleChange(value: string | null) {
    if (!value || value === status) return;

    try {
      await updateStatus.mutateAsync({ id, status: value as EnquiryStatus });
      toast.success("Status updated.");
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to update status.";
      toast.error(message);
    }
  }

  return (
    <Select value={status} onValueChange={handleChange}>
      <SelectTrigger size="sm" className="w-36">
        <SelectValue />
      </SelectTrigger>
      <SelectContent>
        {STATUSES.map((s) => (
          <SelectItem key={s.value} value={s.value}>
            {s.label}
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  );
}
