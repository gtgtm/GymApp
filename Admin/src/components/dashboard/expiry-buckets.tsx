import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import type { DashboardResponse, ExpiryBucket } from "@/lib/api-types";

const BUCKET_META: Record<ExpiryBucket, { label: string; className: string }> = {
  green: { label: "Healthy (15+ days)", className: "bg-emerald-100 text-emerald-700" },
  yellow: { label: "Expiring in 7-15 days", className: "bg-amber-100 text-amber-700" },
  orange: { label: "Expiring in 1-6 days", className: "bg-orange-100 text-orange-700" },
  red: { label: "Expired", className: "bg-red-100 text-red-700" },
};

export function ExpiryBuckets({ expiring }: { expiring: DashboardResponse["expiring"] }) {
  const urgentBuckets: ExpiryBucket[] = ["red", "orange", "yellow"];

  return (
    <Card>
      <CardHeader>
        <CardTitle>Membership Expiring Soon</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {urgentBuckets.map((bucket) => {
          const members = expiring[bucket] ?? [];
          if (members.length === 0) return null;

          return (
            <div key={bucket} className="space-y-2">
              <Badge variant="secondary" className={BUCKET_META[bucket].className}>
                {BUCKET_META[bucket].label} · {members.length}
              </Badge>
              <ul className="space-y-1">
                {members.slice(0, 5).map((entry) => (
                  <li
                    key={entry.id}
                    className="flex items-center justify-between text-sm text-muted-foreground"
                  >
                    <span>
                      {entry.member.full_name} ({entry.member.member_code})
                    </span>
                    <span>{new Date(entry.end_date).toLocaleDateString()}</span>
                  </li>
                ))}
              </ul>
            </div>
          );
        })}
        {urgentBuckets.every((bucket) => (expiring[bucket] ?? []).length === 0) && (
          <p className="text-sm text-muted-foreground">No memberships expiring soon.</p>
        )}
      </CardContent>
    </Card>
  );
}
