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

- **Multi-tenancy**: every tenant-scoped table carries a `gym_id`, enforced automatically via a Laravel global scope (`App\Models\Scopes\GymScope`) so one gym can never see another gym's data.
- **Auth**: Sanctum personal access tokens (`Authorization: Bearer <token>`), not cookie-based sessions.
- **API**: versioned under `/api/v1`, consistent `{ success, data, error, meta }` response envelope.
- **Payments/notifications**: built behind abstractions (`PaymentService`, notification channels added in a later phase) so real gateway/SMS/WhatsApp providers can be plugged in without a rewrite.
