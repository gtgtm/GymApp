# Deploying the API to shared hosting

Target folder: `public_html/gautamgupta.in/gymbrainapi`
Public URL: `https://gautamgupta.in/gymbrainapi` (API base: `/api/v1`)

The app root is web-reachable on this host, so the root `.htaccess` + `index.php`
route every request through Laravel and deny direct access to `.env`,
`vendor/`, `storage/`, etc. Only `public/storage/*` (photos), `favicon.ico` and
`robots.txt` are served as files.

## 1. Build (locally)

```bash
cd Backend
./deploy/build.sh        # → dist/gymbrainapi.zip (prod deps only, no .env)
```

## 2. Server prerequisites (hPanel / cPanel)

- PHP **8.3+** selected for the domain, with `pdo_mysql`, `mbstring`, `openssl`,
  `fileinfo`, `gd`, `dom`, `zip` enabled.
- A MySQL database + user created; note the name, user and password.

## 3. Upload

Upload `gymbrainapi.zip` into `public_html/gautamgupta.in/` and extract it so the
folder becomes `public_html/gautamgupta.in/gymbrainapi/`.

## 4. Configure and migrate (SSH)

```bash
cd ~/public_html/gautamgupta.in/gymbrainapi   # adjust to the account's path
cp .env.production.example .env               # then fill DB_* and MAIL_*
php artisan key:generate --force
php artisan migrate --force
php artisan db:seed --class=ProductionSeeder --force   # prompts for logins
php artisan storage:link
php artisan config:cache && php artisan route:cache && php artisan view:cache
chmod -R 775 storage bootstrap/cache
```

`ProductionSeeder` creates roles and plans, then asks for the super-admin
login and one vendor (gym + owner login); passwords are typed hidden. Re-run
it any time to add another vendor — it skips the super admin once one exists.
Never run the plain `db:seed` here: that loads demo data with `password` logins.

## 5. Cron (every minute)

Runs the membership/payment reminder commands and drains the mail queue:

```
* * * * * cd ~/public_html/gautamgupta.in/gymbrainapi && php artisan schedule:run >> /dev/null 2>&1
```

Use the host's full PHP binary path if `php` is not the 8.3 CLI
(e.g. `/opt/alt/php83/usr/bin/php`).

## 6. Verify

```bash
curl https://gautamgupta.in/gymbrainapi/up                       # 200
curl https://gautamgupta.in/gymbrainapi/.env                     # 403
curl -X POST -H 'Accept: application/json' \
     https://gautamgupta.in/gymbrainapi/api/v1/login             # 422
```

## 7. Point the clients at it

- AdminApp: `flutter build apk --dart-define=API_BASE_URL=https://gautamgupta.in/gymbrainapi/api/v1`
- Admin (Next.js): `NEXT_PUBLIC_API_URL=https://gautamgupta.in/gymbrainapi/api/v1`

## Updating later

Rebuild, upload and extract over the existing folder (keeps `.env` and
`storage/`), then:

```bash
php artisan migrate --force
php artisan optimize:clear && php artisan config:cache && php artisan route:cache
```
