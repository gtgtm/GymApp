import axios from "axios";

const TOKEN_STORAGE_KEY = "gymapp_token";
const ACTING_GYM_STORAGE_KEY = "gymapp_acting_gym";

export const apiClient = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL ?? "http://127.0.0.1:8000/api/v1",
  headers: {
    Accept: "application/json",
  },
});

apiClient.interceptors.request.use((config) => {
  const token = getStoredToken();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }

  // Mirrors the X-Gym-Id header the backend's ResolveActingGym middleware
  // reads. Only meaningful for a super_admin session: once set, every
  // request is scoped to that gym exactly like a real gym-admin session.
  const actingGym = getStoredActingGym();
  if (actingGym) {
    config.headers["X-Gym-Id"] = String(actingGym.id);
  }

  return config;
});

apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401 && typeof window !== "undefined") {
      clearStoredToken();
      // Full reload (not router.push) is intentional: this runs outside React
      // and must also reset all in-memory query cache/state after auth failure.
      window.location.assign("/login");
    }
    return Promise.reject(error);
  },
);

export function getStoredToken(): string | null {
  if (typeof window === "undefined") return null;
  return window.localStorage.getItem(TOKEN_STORAGE_KEY);
}

export function setStoredToken(token: string): void {
  window.localStorage.setItem(TOKEN_STORAGE_KEY, token);
}

export function clearStoredToken(): void {
  window.localStorage.removeItem(TOKEN_STORAGE_KEY);
}

export interface ActingGym {
  id: number;
  name: string;
}

export function getStoredActingGym(): ActingGym | null {
  if (typeof window === "undefined") return null;
  const raw = window.localStorage.getItem(ACTING_GYM_STORAGE_KEY);
  if (!raw) return null;
  try {
    return JSON.parse(raw) as ActingGym;
  } catch {
    return null;
  }
}

export function setStoredActingGym(gym: ActingGym): void {
  window.localStorage.setItem(ACTING_GYM_STORAGE_KEY, JSON.stringify(gym));
}

export function clearStoredActingGym(): void {
  window.localStorage.removeItem(ACTING_GYM_STORAGE_KEY);
}
