"use client";

import { useState } from "react";
import { Download } from "lucide-react";
import { Button } from "@/components/ui/button";
import { downloadReport } from "@/hooks/use-reports";
import { toast } from "sonner";

interface DateRange {
  from: string;
  to: string;
}

export function ExportButtons({
  report,
  range,
  includePdf = false,
}: {
  report: "financial" | "members" | "attendance" | "trainers" | "sales";
  range?: DateRange;
  includePdf?: boolean;
}) {
  const [isExporting, setIsExporting] = useState<"csv" | "pdf" | null>(null);

  async function handleExport(format: "csv" | "pdf") {
    setIsExporting(format);
    try {
      await downloadReport(report, format, range);
    } catch {
      toast.error(`Failed to export ${format.toUpperCase()} report.`);
    } finally {
      setIsExporting(null);
    }
  }

  return (
    <div className="flex gap-2">
      <Button
        variant="outline"
        size="sm"
        onClick={() => void handleExport("csv")}
        disabled={isExporting !== null}
      >
        <Download className="h-4 w-4" />
        {isExporting === "csv" ? "Exporting..." : "Export CSV"}
      </Button>
      {includePdf && (
        <Button
          variant="outline"
          size="sm"
          onClick={() => void handleExport("pdf")}
          disabled={isExporting !== null}
        >
          <Download className="h-4 w-4" />
          {isExporting === "pdf" ? "Exporting..." : "Export PDF"}
        </Button>
      )}
    </div>
  );
}
