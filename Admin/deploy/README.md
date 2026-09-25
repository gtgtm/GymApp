# Deploying the admin panel

Target folder: `public_html/gautamgupta.in/gymbrain`
URL: `https://gautamgupta.in/gymbrain` (talks to `https://gautamgupta.in/gymbrainapi/api/v1`)

The panel is a static export (plain HTML/JS/CSS), so no Node.js is needed on
the server. URLs are set in `.env.production`.

## Build

```bash
cd Admin
./deploy/build.sh        # → dist/gymbrain.zip
```

## Upload

1. In File Manager open `public_html/gautamgupta.in/`.
2. Delete the old `gymbrain/` folder if it exists.
3. Upload `gymbrain.zip` and extract it, giving `public_html/gautamgupta.in/gymbrain/`.
4. Make sure hidden files are shown and `gymbrain/.htaccess` is present.

## Verify

- `https://gautamgupta.in/gymbrain/` redirects to `/gymbrain/login/`
- Log in with the super-admin or vendor login from `ProductionSeeder`.

## Notes

- Changing the folder name means updating `NEXT_PUBLIC_BASE_PATH` in
  `.env.production` and the `ErrorDocument` path in `public/.htaccess`, then rebuilding.
- Member and gym detail pages use query URLs (`/members/view/?id=5`) because a
  static export can't pre-generate one page per ID.
