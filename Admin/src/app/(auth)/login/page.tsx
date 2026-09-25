"use client";

import { useState, type FormEvent } from "react";
import { ArrowRight, Eye, EyeOff, Loader2, Lock, Mail } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { BrandMark } from "@/components/auth/brand-mark";
import { BrandPanel } from "@/components/auth/brand-panel";
import { useAuth } from "@/hooks/use-auth";
import { getApiErrorMessage } from "@/lib/api-client";
import { toast } from "sonner";

const FIELD_CLASS =
  "h-12 rounded-md border-brand-line bg-brand-surface pl-10 text-base text-brand-text placeholder:text-brand-muted/50 focus-visible:border-brand-blaze focus-visible:ring-brand-blaze/25 md:text-base";
const LABEL_CLASS = "text-xs font-medium uppercase tracking-[0.18em] text-brand-muted";
const FIELD_ICON_CLASS =
  "pointer-events-none absolute left-3.5 top-1/2 size-4 -translate-y-1/2 text-brand-muted transition-colors group-focus-within:text-brand-blaze";

export default function LoginPage() {
  const { login } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isPasswordVisible, setIsPasswordVisible] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setIsSubmitting(true);

    try {
      await login(email, password);
    } catch (error: unknown) {
      toast.error(getApiErrorMessage(error, "Login failed. Please try again."));
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <main className="relative grid min-h-dvh flex-1 bg-brand-ink text-brand-text lg:grid-cols-[1.15fr_1fr]">
      <div className="bg-grain pointer-events-none absolute inset-0 opacity-[0.06] mix-blend-overlay" />

      <BrandPanel />

      <section
        aria-labelledby="login-heading"
        className="relative flex flex-col justify-center px-6 py-8 sm:px-12 sm:py-12 [@media(max-height:680px)]:py-6"
      >
        <div className="bg-hazard absolute inset-x-0 top-0 h-1.5 opacity-90" />

        <div className="mx-auto w-full max-w-sm">
          <div className="mb-8 sm:mb-12 lg:hidden">
            <BrandMark />
          </div>

          <p className="flex items-center gap-2 font-mono text-xs uppercase tracking-[0.3em] text-brand-volt">
            <span className="relative flex size-2">
              <span className="absolute inline-flex size-full rounded-full bg-brand-volt opacity-75 motion-safe:animate-ping" />
              <span className="relative inline-flex size-2 rounded-full bg-brand-volt" />
            </span>
            Staff access
          </p>
          <h2
            id="login-heading"
            className="mt-3 font-display text-5xl font-extrabold uppercase leading-none tracking-tight sm:mt-4 sm:text-6xl"
          >
            Clock in
          </h2>
          <p className="mt-3 text-sm leading-relaxed text-brand-muted">
            Sign in to run today&apos;s floor — members, check-ins and payments.
          </p>

          <form onSubmit={handleSubmit} className="mt-8 space-y-5 sm:mt-10 [@media(max-height:680px)]:mt-6 [@media(max-height:680px)]:space-y-4">
            <div className="space-y-2">
              <Label htmlFor="email" className={LABEL_CLASS}>
                Email
              </Label>
              <div className="group relative">
                <Mail className={FIELD_ICON_CLASS} />
                <Input
                  id="email"
                  type="email"
                  required
                  autoComplete="email"
                  value={email}
                  onChange={(event) => setEmail(event.target.value)}
                  placeholder="you@yourgym.com"
                  className={FIELD_CLASS}
                />
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="password" className={LABEL_CLASS}>
                Password
              </Label>
              <div className="group relative">
                <Lock className={FIELD_ICON_CLASS} />
                <Input
                  id="password"
                  type={isPasswordVisible ? "text" : "password"}
                  required
                  autoComplete="current-password"
                  value={password}
                  onChange={(event) => setPassword(event.target.value)}
                  placeholder="••••••••"
                  className={`${FIELD_CLASS} pr-11`}
                />
                <button
                  type="button"
                  onClick={() => setIsPasswordVisible((visible) => !visible)}
                  aria-label={isPasswordVisible ? "Hide password" : "Show password"}
                  aria-pressed={isPasswordVisible}
                  className="absolute inset-y-0 right-0 flex w-11 items-center justify-center rounded-r-md text-brand-muted transition-colors hover:text-brand-text focus-visible:text-brand-blaze focus-visible:outline-none"
                >
                  {isPasswordVisible ? <EyeOff className="size-4" /> : <Eye className="size-4" />}
                </button>
              </div>
            </div>

            <button
              type="submit"
              disabled={isSubmitting}
              className="group mt-2 flex h-12 w-full items-center justify-center gap-2 rounded-md bg-brand-blaze font-display text-xl font-extrabold uppercase tracking-wider text-brand-on-blaze shadow-[0_12px_32px_-12px_var(--brand-blaze)] transition-[transform,filter,box-shadow] duration-150 hover:brightness-110 hover:shadow-[0_16px_40px_-10px_var(--brand-blaze)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-volt focus-visible:ring-offset-2 focus-visible:ring-offset-brand-ink active:translate-y-px disabled:cursor-not-allowed disabled:opacity-70"
            >
              {isSubmitting ? (
                <>
                  <Loader2 className="size-5 animate-spin" />
                  Warming up…
                </>
              ) : (
                <>
                  Start session
                  <ArrowRight className="size-5 transition-transform duration-150 group-hover:translate-x-1" />
                </>
              )}
            </button>
          </form>

          <p className="mt-8 border-t border-brand-line pt-5 text-xs leading-relaxed sm:mt-10 sm:pt-6 [@media(max-height:680px)]:mt-6 [@media(max-height:680px)]:pt-4 text-brand-muted">
            Gym member? Use the <span className="text-brand-text">GymBrain app</span> to check in,
            see your plan and track progress.
          </p>
        </div>
      </section>
    </main>
  );
}
