# Gym Management & Member Management SaaS — Phased Build Plan

## Context

The user wants a full, production-ready, multi-tenant Gym Management SaaS platform covering admin/receptionist/trainer/member roles, membership & payment lifecycle, attendance (incl. QR), workout/diet plans, progress tracking, leads/trials, expenses, equipment, notifications, reports, and an AI-suggestions layer — sellable as a commercial SaaS product to gyms.

`/Users/gautam/Desktop/Gautam/GymApp` is currently a blank slate: three empty folders (`Admin`, `Backend`, `MobileApp`), a fresh local git repo (no commits yet), and a target GitHub remote at `https://github.com/gtgtm/GymApp.git`. Sibling projects in the same parent directory (`MedicalPortal`, `ChapChap`) already use this same three-folder convention with a Laravel backend + Flutter mobile app, which validates the chosen stack and gives us naming/structure precedent to follow (route versioning under `/api/v1`, Sanctum auth, RBAC via roles/permissions tables, `ARCHITECTURE.md`/`README.md` docs).

Given the size of the spec (30 sections), this is being broken into sequential phases. Phase 1 delivers a working core (auth, multi-tenant schema, members, plans, payments, attendance, admin dashboard) that alone is usable by a small gym. Later phases layer on workouts/diet/progress, CRM (enquiries/trials), expenses/equipment, notifications, reports/AI, then the mobile app and SaaS billing polish.

**Confirmed decisions:**
- Backend: **Laravel 11/12 + MySQL** (Sanctum for API auth)
- Admin web: **Next.js + React + Tailwind + shadcn/ui**
- Mobile (member portal): **Flutter**
- Multi-tenancy: **shared database, `gym_id` column + global scope** on every tenant-scoped table (not database-per-tenant)
- Payments & notifications: **abstraction layer only in Phase 1** (manual payment recording with receipts; in-app + email notifications; SMS/WhatsApp/payment-gateway providers stubbed behind interfaces for later real integration)
- Git: local repo already initialized; remote `origin` will be set to `https://github.com/gtgtm/GymApp.git`. Initial scaffolding will be committed locally; **pushing to the remote requires separate explicit confirmation** (per standing git-safety rules, pushes are not automatic).

---

## Phase 1 — Foundation: Auth, Multi-Tenant Schema, Members, Plans, Payments, Attendance, Dashboard

Goal: a gym owner can log in, add members, define membership plans, record payments/renewals, mark attendance, and see a live dashboard. This is the smallest end-to-end usable slice.

### 1.1 Repo & project scaffolding
- Local git repo already initialized; add `.gitignore` (Laravel + Node + Flutter + `.env` + IDE files); set `git remote add origin https://github.com/gtgtm/GymApp.git` (no push yet — confirm separately when ready)
- `Backend/`: `composer create-project laravel/laravel .` (PHP 8.3), install `laravel/sanctum`, configure **MySQL** connection
- `Admin/`: `npx create-next-app@latest .` (TypeScript, Tailwind, App Router), add shadcn/ui, Recharts (or Tremor) for charts, TanStack Query for server state
- `MobileApp/`: `flutter create .` — scaffold only in Phase 1 (real screens come in a later phase); confirm it builds
- Root-level `README.md` describing the three sub-projects and how to run them locally (mirror `ChapChap`'s doc style)

### 1.2 Database schema (multi-tenant core)
Design normalized MySQL schema via Laravel migrations. Every tenant-scoped table gets a `gym_id` foreign key (enforced via a Laravel **global scope** + a `BelongsToGym` trait applied to all tenant models, resolved from the authenticated user's `gym_id`).

Core tables for Phase 1:
- `gyms` (id, name, address, settings JSON, subscription fields placeholder, timestamps, soft delete)
- `users` (id, gym_id nullable for super-admin, name, email, password, role_id, phone, status, timestamps)
- `roles`, `permissions`, `role_permissions` (admin, receptionist, trainer, member — seeded)
- `members` (all fields from spec section 3: photo, contact, DOB, gender, address, emergency contact, joining date, trainer_id, height, weight, blood group, notes, status; `gym_id`)
- `membership_plans` (name, duration, price, registration_fee, discount, tax, total_amount, description, benefits JSON, freeze_days, status; `gym_id`)
- `memberships` (member_id, plan_id, start_date, end_date, status, computed remaining days; `gym_id`)
- `membership_renewals` (membership_id, previous_expiry, new_expiry, plan_id, discount, tax, amount_paid, amount_due, payment_method, renewed_by user_id, timestamps)
- `payments` (receipt_number, member_id, invoice_id nullable, amount, discount, tax, method enum [cash, upi, card, bank_transfer, online], status, paid_at; `gym_id`)
- `invoices` (member_id, items JSON or line-items table, total, status)
- `attendance` (member_id, date, check_in_time, status enum [present, absent, late, leave], marked_via enum [manual, qr, search], marked_by user_id; `gym_id`)
- `audit_logs` (user_id, gym_id, action, entity_type, entity_id, before/after JSON, timestamps) — start capturing from Phase 1 since it's foundational, not bolted on later
- Indexes: `gym_id` on every tenant table, composite index on `(member_id, date)` for attendance, `(gym_id, status)` on memberships for expiry queries

### 1.3 Auth & RBAC (Backend)
- Laravel Sanctum token-based API auth (`POST /api/v1/login`, `POST /api/v1/logout`)
- Middleware enforcing role-based access per route group (admin / receptionist / trainer / member)
- Global `gym_id` scope so every query is automatically tenant-isolated; a request can never touch another gym's rows
- Password hashing via Laravel's default bcrypt, request validation via Form Requests on every endpoint
- Basic login history / audit log entries on login events

### 1.4 Core REST API (Backend)
Follow the spec's example routes under `/api/v1`, consistent JSON envelope (`{success, data, error, meta}`) and proper HTTP status codes:
- `GET/POST /members`, `GET/PUT/DELETE /members/{id}`, `POST /members/{id}/renew`, `GET /members/{id}/payments`
- `GET/POST /membership-plans`
- `POST /payments`, `GET /payments`
- `POST /attendance`, `GET /attendance` (with member-id/mobile search support for the "smart QR" flow's non-QR fallback)
- `GET /dashboard` — aggregate counts (total/active/expired members, expiring-soon, today's attendance, today's new members, today's/monthly revenue, pending payments)
- Automatic expiry-bucket calculation exposed via API: Green (>15 days), Yellow (7–15), Orange (1–6), Red (expired) — computed from `memberships.end_date`, not stored redundantly

### 1.5 Admin web app (Next.js)
- Auth pages (login), role-aware layout: left sidebar + top nav
- Dashboard page: stat cards (from 2.), Recharts for monthly revenue / new memberships / attendance trend / plan distribution; "Add Member / Collect Payment / Mark Attendance / Add Membership" quick actions
- Members: list (search/filter/pagination) + create/edit form + profile page with tabs (Overview, Membership, Payments, Attendance — workout/diet/progress tabs stubbed as "coming soon" until their phase)
- Membership Plans: card-grid CRUD
- Renewal flow: select member → select plan → discount/tax → payment method/amount → auto-computed previous/new expiry → receipt
- Payments: list + printable/downloadable receipt (PDF via a Laravel package, e.g. `barryvdh/laravel-dompdf`, matching the `MedicalPortal` precedent)
- Attendance: manual mark by search (member ID/mobile/name); QR scanning UI deferred to the mobile-app phase, but the manual/search path fully works now
- Consistent UI states: loading, empty, error, toast notifications (per section 24)

### 1.6 Testing & verification for Phase 1
- Backend: PHPUnit feature tests for auth, tenant isolation (a user from gym A cannot see gym B's members), member CRUD, renewal calculation, payment creation, attendance marking — target meaningful coverage on business logic (expiry calculation, tenant scoping) rather than chasing a blanket percentage
- Admin: run the dev server, exercise the golden path manually (login → add member → add plan → renew → collect payment → mark attendance → see dashboard update) before calling Phase 1 done
- Seed script: one demo gym, one admin/receptionist/trainer user each, a few plans, a handful of members in different expiry buckets, so the dashboard is visibly populated

---

## Phase 2 — Trainers, Workouts, Diet, Progress Tracking

- `trainers` table (extends users or separate profile: specialization, salary, joining date, status) + assign-members-to-trainer relation
- `workout_plans`, `workout_exercises` (day-based structure: exercise name, muscle group, sets, reps, weight, rest, instructions, video URL, trainer notes)
- `diet_plans`, `diet_meals` (Breakfast/Mid-Morning/Lunch/Evening Snack/Dinner/Before Bed; food item, quantity, macros; daily nutrition summary computed from meals)
- `body_measurements` (weight, height, BMI computed, body fat%, chest, waist, arms, thigh, hips, recorded_by, date) + `progress_photos` (before/after, storage via Laravel filesystem/S3-ready)
- Admin: Trainer management screens, workout/diet plan builder, member profile Workout/Diet/Progress tabs go live with charts (weight/BMI over time)
- Trainer-role views: assigned members, today's sessions, quick workout/diet assignment, progress entry

## Phase 3 — CRM: Enquiries, Trials, Expenses, Equipment

- `enquiries` (name, mobile, email, source, interested_plan, follow_up_date, assigned_staff, status enum [new, contacted, trial, follow_up, converted, lost], notes) + conversion-rate dashboard metric + follow-up reminders
- `trials` (name, mobile, trial_start/end, trainer_id, status) + expiring-trial notification hook
- `expenses` (category enum [rent, electricity, equipment, maintenance, salary, marketing, cleaning, other], amount, date, description, payment_method, receipt) → Revenue − Expenses = Net Profit on dashboard
- `equipment` (name, category, purchase_date/price, warranty, condition, maintenance_date, next_maintenance_date) + maintenance reminders
- Admin: Enquiry/CRM board (status pipeline), Trials list, Expenses ledger, Equipment inventory with maintenance alerts

## Phase 4 — Notifications, Reports, AI Suggestions

- `notifications` table + **NotificationChannel abstraction** (interface with `InAppChannel`, `EmailChannel` implemented now; `SmsChannel`/`WhatsAppChannel` interface defined but unimplemented/stubbed — matches spec's "don't hard-code a provider" requirement) driven by Laravel Notifications + scheduled jobs (expiry checks, pending payments, trial expiry, equipment maintenance run via Laravel's scheduler)
- Reports module: financial (daily/monthly/annual revenue, expenses, profit, payment-method breakdown), member (new/active/expired/renewals/churn), attendance (daily/weekly/monthly/member-wise), trainer performance, sales/conversion — with date filters and CSV/Excel/PDF export
- `GET /api/v1/ai/suggestions`: a rules-engine service (not an LLM call) that queries existing data to generate the suggestion cards from spec sections 18/26 (inactive members, expiring memberships, pending payments, plan popularity, attendance-by-day trends, uncontacted leads, likely trial conversions) — each with an actionable button wired to the relevant screen. Explicitly no medical-diagnosis language per spec section 19.
- Dashboard gets the "💡 Smart Suggestions" section wired to this endpoint

## Phase 5 — Mobile App (Flutter) — Member Portal

- Flutter app consuming the same `/api/v1` backend: member login, view membership/expiry, payment history, attendance (view + QR code display for scan-in), workout plan, diet plan, progress charts, trainer info, notifications, renew membership
- QR-based attendance: member's QR encodes member ID + gym ID; reception/trainer-side scanning happens via the Admin web (camera access) or a lightweight staff scan view — validate membership status server-side before marking attendance and return an expiry warning if invalid, per spec section 7

## Phase 6 — SaaS Hardening: Subscriptions, Security Pass, Global Search

- `subscriptions` table (gym's own SaaS plan: Starter/Professional/Enterprise, member limits, start/expiry, payment status) enforced via middleware that blocks member-creation past the plan's limit
- Global search endpoint spanning members/payments/trainers/enquiries by name/mobile/ID/receipt, categorized results in Admin UI
- Full security pass: rate limiting (Laravel throttle middleware), CSRF for any session-based routes, secure file upload validation (photo/progress-photo MIME + size checks), review of audit log coverage, login-history review
- Final `security-reviewer` agent pass across the whole Backend before considering the product launch-ready

---

## Execution Notes

- Each phase should end with: automated tests passing, a manual golden-path walkthrough in the browser (Admin) noted in the response, and a commit (only when the user asks to commit, per standing git rules).
- Reuse Laravel conventions already established by `MedicalPortal`/`ChapChap` (Sanctum, `/api/v1` versioning, migration/seeder structure) rather than inventing new ones, since they're proven sibling patterns.
- Files stay small and feature-organized (Laravel: one controller/request/resource per domain concept; Next.js: `components/<feature>/`, `app/<route>/` per the user's web coding-style rules).
- Defer real payment-gateway and SMS/WhatsApp provider wiring until the user has accounts/credentials — the abstraction is built so plugging them in later is a config change, not a rewrite.

## Verification (Phase 1 acceptance)

1. `cd Backend && php artisan migrate --seed && php artisan serve` — API reachable, seeded gym/users/members present
2. `cd Admin && npm run dev` — log in as seeded admin, walk the golden path: dashboard loads with real numbers → add a member → create a plan → renew a membership (verify expiry math) → collect a payment (receipt generated) → mark attendance → dashboard counts update
3. `cd Backend && php artisan test` — auth, tenant-isolation, renewal-calculation, and payment tests pass
4. Confirm a gym-A user cannot fetch gym-B's members via the API (manual curl check with two seeded gyms)
