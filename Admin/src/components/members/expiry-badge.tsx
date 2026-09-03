import { Badge } from "@/components/ui/badge";
import type { ExpiryBucket } from "@/lib/api-types";

const BUCKET_STYLES: Record<ExpiryBucket, string> = {
  green: "bg-emerald-100 text-emerald-700",
  yellow: "bg-amber-100 text-amber-700",
  orange: "bg-orange-100 text-orange-700",
  red: "bg-red-100 text-red-700",
};

const BUCKET_LABELS: Record<ExpiryBucket, string> = {
  green: "Active",
  yellow: "Expiring soon",
  orange: "Expiring soon",
  red: "Expired",
};

export function ExpiryBadge({ bucket }: { bucket: ExpiryBucket }) {
  return <Badge className={BUCKET_STYLES[bucket]}>{BUCKET_LABELS[bucket]}</Badge>;
}
