"use client";

import Link from "next/link";
import { Lightbulb } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { useAiSuggestions } from "@/hooks/use-ai-suggestions";
import { cn } from "@/lib/utils";
import type { AiSuggestion } from "@/lib/api-types";

const SEVERITY_STYLES: Record<AiSuggestion["severity"], string> = {
  info: "border-l-sky-400 bg-sky-50",
  warning: "border-l-amber-400 bg-amber-50",
  success: "border-l-emerald-400 bg-emerald-50",
  danger: "border-l-red-400 bg-red-50",
};

export function SmartSuggestions() {
  const { data: suggestions, isLoading } = useAiSuggestions();

  if (isLoading) {
    return <Skeleton className="h-32 w-full" />;
  }

  if (!suggestions || suggestions.length === 0) {
    return null;
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Lightbulb className="h-4 w-4 text-amber-500" />
          Smart Suggestions
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-3">
        {suggestions.map((suggestion, index) => (
          <div
            key={index}
            className={cn(
              "flex items-center justify-between gap-4 rounded-md border-l-4 p-3",
              SEVERITY_STYLES[suggestion.severity],
            )}
          >
            <p className="text-sm">{suggestion.message}</p>
            <Button
              size="sm"
              variant="outline"
              nativeButton={false}
              render={<Link href={suggestion.action_route} />}
              className="shrink-0"
            >
              {suggestion.action_label}
            </Button>
          </div>
        ))}
      </CardContent>
    </Card>
  );
}
