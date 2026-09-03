"use client";

import {
  createContext,
  startTransition,
  useCallback,
  useContext,
  useEffect,
  useState,
  type ReactNode,
} from "react";
import { useRouter } from "next/navigation";
import { apiClient, clearStoredToken, getStoredToken, setStoredToken } from "@/lib/api-client";
import type { ApiResponse, AuthUser } from "@/lib/api-types";

interface AuthContextValue {
  user: AuthUser | null;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const router = useRouter();

  const loadUser = useCallback(async () => {
    const token = getStoredToken();
    if (!token) {
      setIsLoading(false);
      return;
    }

    try {
      const { data } = await apiClient.get<ApiResponse<AuthUser>>("/me");
      if (data.success) {
        setUser(data.data);
      }
    } catch {
      clearStoredToken();
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    startTransition(() => {
      void loadUser();
    });
  }, [loadUser]);

  const login = useCallback(
    async (email: string, password: string) => {
      const { data } = await apiClient.post<ApiResponse<{ token: string; user: AuthUser }>>(
        "/login",
        { email, password },
      );

      if (!data.success) {
        throw new Error(data.error.message);
      }

      setStoredToken(data.data.token);
      setUser(data.data.user);
      router.push("/dashboard");
    },
    [router],
  );

  const logout = useCallback(async () => {
    try {
      await apiClient.post("/logout");
    } finally {
      clearStoredToken();
      setUser(null);
      router.push("/login");
    }
  }, [router]);

  return (
    <AuthContext.Provider value={{ user, isLoading, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth(): AuthContextValue {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within AuthProvider");
  }
  return context;
}
