# GymApp

Gym Management & Member Management SaaS platform for gym owners, trainers, receptionists, and members.

## Structure

```
GymApp/
├── Backend/     Laravel 13 API (PHP 8.3, MySQL, Sanctum token auth)
├── Admin/       Next.js admin dashboard (TypeScript, Tailwind, shadcn/ui)
└── MobileApp/   Flutter member portal (scaffolded, screens land in a later phase)
```

## Backend (Laravel API)

```bash
cd Backend
composer install
cp .env.example .env   # already configured for MySQL, adjust credentials if needed
php artisan key:generate
mysql -u root -e "CREATE DATABASE IF NOT EXISTS gymapp"
php artisan migrate --seed
php artisan serve --port=8000
```

Seeded demo accounts (password: `password`):

| Role | Email |
|------|-------|
| Super Admin | superadmin@gymapp.test |
| Admin | admin@demofitness.test |
| Receptionist | reception@demofitness.test |
| Trainer | trainer@demofitness.test |

Run tests: `php artisan test`

## Admin (Next.js dashboard)

```bash
cd Admin
npm install
cp .env.local.example .env.local   # points at http://127.0.0.1:8000/api/v1
npm run dev
```

Visit http://localhost:3000 and log in with a seeded account above.

## MobileApp (Flutter member portal)

Scaffolded only in Phase 1. Screens (membership, payments, attendance QR, workout/diet plans) are implemented in a later phase.

```bash
cd MobileApp
flutter pub get
flutter run
```

## Architecture notes

- **Multi-tenancy**: every tenant-scoped table carries a `gym_id`, enforced automatically via a Laravel global scope (`App\Models\Scopes\GymScope`) so one gym can never see another gym's data. The scope fails closed (returns zero rows) for any HTTP request with no resolvable gym context, rather than silently returning every tenant's data.
- **Cross-tenant FK validation**: any request field that references another table by ID (e.g. `member_id`, `trainer_id`) uses a custom `App\Rules\ExistsInCurrentGym` rule instead of Laravel's built-in `exists:table,column` rule — the built-in rule does not respect Eloquent global scopes, so it would otherwise validate an ID belonging to a different gym.
- **Auth**: Sanctum personal access tokens (`Authorization: Bearer <token>`), not cookie-based sessions. Tokens expire after 7 days by default (`SANCTUM_TOKEN_EXPIRATION` in `.env`, minutes).
- **API**: versioned under `/api/v1`, consistent `{ success, data, error, meta }` response envelope. Rate-limited globally at 120 req/min per user/IP, with a stricter 10/min limit on login.
- **Payments/notifications**: built behind abstractions (`PaymentService`, `App\Notifications\Channels\NotificationChannel`) so real gateway/SMS/WhatsApp providers can be plugged in without a rewrite. In-app and email channels are wired up; SMS/WhatsApp are defined but unimplemented pending provider credentials.
- **SaaS subscriptions**: a `super_admin` role (no `gym_id`) manages every gym's subscription tier (Starter/Professional/Enterprise) via `/api/v1/subscriptions`; gym admins can view their own via `/api/v1/subscriptions/mine`. Member creation is blocked once a gym's active member count reaches its plan's limit.
- **CSV exports**: values starting with `= + - @` (spreadsheet formula triggers) are automatically prefixed with `'` before being written to any CSV export, to prevent formula/CSV injection when a report is opened in Excel/Sheets.

## Pre-launch checklist

- [ ] Set `APP_DEBUG=false` in production `.env` — debug mode leaks file paths, SQL, and stack traces in API error responses.
- [ ] Set a strong, unique `APP_KEY` per environment (never reuse the one committed during development).
- [ ] Point `SANCTUM_TOKEN_EXPIRATION` and rate limits (`app/Providers/AppServiceProvider.php`) to values appropriate for production traffic.
- [ ] Configure real mail/SMS/WhatsApp credentials before relying on notifications reaching users.
