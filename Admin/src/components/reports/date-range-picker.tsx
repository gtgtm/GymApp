"use client";

import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

interface DateRange {
  from: string;
  to: string;
}

export function DateRangePicker({
  range,
  onChange,
}: {
  range: DateRange;
  onChange: (range: DateRange) => void;
}) {
  return (
    <div className="flex items-end gap-3">
      <div className="space-y-1.5">
        <Label htmlFor="report-from" className="text-xs">
          From
        </Label>
        <Input
          id="report-from"
          type="date"
          value={range.from}
          onChange={(e) => onChange({ ...range, from: e.target.value })}
        />
      </div>
      <div className="space-y-1.5">
        <Label htmlFor="report-to" className="text-xs">
          To
        </Label>
        <Input
          id="report-to"
          type="date"
          value={range.to}
          onChange={(e) => onChange({ ...range, to: e.target.value })}
        />
      </div>
    </div>
  );
}
