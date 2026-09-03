import type { Role } from "@/lib/api-types";

export type RoleName = Role["name"];

export type NavKey = "dashboard" | "members" | "trainers" | "plans" | "payments" | "attendance";

const ROLE_NAV_ACCESS: Record<RoleName, NavKey[]> = {
  admin: ["dashboard", "members", "trainers", "plans", "payments", "attendance"],
  receptionist: ["dashboard", "members", "payments", "attendance"],
  trainer: ["dashboard", "members", "attendance"],
  member: [],
};

export function canAccessNav(role: RoleName | undefined, key: NavKey): boolean {
  if (!role) return false;
  return ROLE_NAV_ACCESS[role].includes(key);
}

const ROUTE_NAV_KEY: Record<string, NavKey> = {
  "/dashboard": "dashboard",
  "/members": "members",
  "/trainers": "trainers",
  "/plans": "plans",
  "/payments": "payments",
  "/attendance": "attendance",
};

export function canAccessRoute(role: RoleName | undefined, pathname: string): boolean {
  const matchedPrefix = Object.keys(ROUTE_NAV_KEY)
    .filter((prefix) => pathname.startsWith(prefix))
    .sort((a, b) => b.length - a.length)[0];

  if (!matchedPrefix) return true;

  return canAccessNav(role, ROUTE_NAV_KEY[matchedPrefix]);
}
