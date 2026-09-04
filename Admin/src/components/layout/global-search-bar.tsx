"use client";

import { useRef, useState } from "react";
import Link from "next/link";
import { Search } from "lucide-react";
import { Input } from "@/components/ui/input";
import { useGlobalSearch } from "@/hooks/use-global-search";
import { useDebounce } from "@/hooks/use-debounce";

export function GlobalSearchBar() {
  const [query, setQuery] = useState("");
  const [isFocused, setIsFocused] = useState(false);
  const debouncedQuery = useDebounce(query, 300);
  const { data: results, isFetching } = useGlobalSearch(debouncedQuery);
  const containerRef = useRef<HTMLDivElement>(null);

  const hasQuery = debouncedQuery.trim().length >= 2;
  const hasResults =
    results &&
    (results.members.length > 0 ||
      results.trainers.length > 0 ||
      results.payments.length > 0 ||
      results.enquiries.length > 0);

  return (
    <div ref={containerRef} className="relative w-72">
      <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
      <Input
        placeholder="Search members, payments, trainers..."
        className="pl-8"
        value={query}
        onChange={(event) => setQuery(event.target.value)}
        onFocus={() => setIsFocused(true)}
        onBlur={() => setTimeout(() => setIsFocused(false), 150)}
      />

      {isFocused && hasQuery && (
        <div className="absolute left-0 top-full z-50 mt-1 w-full rounded-lg border bg-popover p-2 text-popover-foreground shadow-md">
          {isFetching && <p className="px-2 py-3 text-sm text-muted-foreground">Searching...</p>}

          {!isFetching && !hasResults && (
            <p className="px-2 py-3 text-sm text-muted-foreground">No results found.</p>
          )}

          {!isFetching && results && (
            <div className="max-h-96 space-y-3 overflow-y-auto">
              {results.members.length > 0 && (
                <SearchGroup label="Members">
                  {results.members.map((member) => (
                    <Link
                      key={member.id}
                      href={`/members/${member.id}`}
                      className="block rounded-md px-2 py-1.5 text-sm hover:bg-muted"
                    >
                      <span className="font-medium">{member.full_name}</span>
                      <span className="ml-2 text-xs text-muted-foreground">
                        {member.mobile} · {member.member_code}
                      </span>
                    </Link>
                  ))}
                </SearchGroup>
              )}

              {results.trainers.length > 0 && (
                <SearchGroup label="Trainers">
                  {results.trainers.map((trainer) => (
                    <Link
                      key={trainer.id}
                      href="/trainers"
                      className="block rounded-md px-2 py-1.5 text-sm hover:bg-muted"
                    >
                      <span className="font-medium">{trainer.user.name}</span>
                      {trainer.user.phone && (
                        <span className="ml-2 text-xs text-muted-foreground">
                          {trainer.user.phone}
                        </span>
                      )}
                    </Link>
                  ))}
                </SearchGroup>
              )}

              {results.payments.length > 0 && (
                <SearchGroup label="Payments">
                  {results.payments.map((payment) => (
                    <Link
                      key={payment.id}
                      href="/payments"
                      className="block rounded-md px-2 py-1.5 text-sm hover:bg-muted"
                    >
                      <span className="font-medium">{payment.receipt_number}</span>
                      <span className="ml-2 text-xs text-muted-foreground">₹{payment.amount}</span>
                    </Link>
                  ))}
                </SearchGroup>
              )}

              {results.enquiries.length > 0 && (
                <SearchGroup label="Enquiries">
                  {results.enquiries.map((enquiry) => (
                    <Link
                      key={enquiry.id}
                      href="/enquiries"
                      className="block rounded-md px-2 py-1.5 text-sm hover:bg-muted"
                    >
                      <span className="font-medium">{enquiry.name}</span>
                      <span className="ml-2 text-xs text-muted-foreground capitalize">
                        {enquiry.status}
                      </span>
                    </Link>
                  ))}
                </SearchGroup>
              )}
            </div>
          )}
        </div>
      )}
    </div>
  );
}

function SearchGroup({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div>
      <p className="px-2 py-1 text-xs font-medium text-muted-foreground">{label}</p>
      {children}
    </div>
  );
}
