#!/usr/bin/env bash
# Builds the static admin panel for public_html/gautamgupta.in/gymbrain
# and zips it as dist/gymbrain.zip.
set -euo pipefail

ADMIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$ADMIN_DIR/dist"
cd "$ADMIN_DIR"

# Exported vars outrank .env.local, which points at the local API.
set -a
source .env.production
set +a

echo "→ Building (API: $NEXT_PUBLIC_API_URL, base: $NEXT_PUBLIC_BASE_PATH)"
rm -rf out "$DIST_DIR"
npx next build

echo "→ Zipping"
mkdir -p "$DIST_DIR"
rm -rf "$DIST_DIR/gymbrain"
cp -R out "$DIST_DIR/gymbrain"
(cd "$DIST_DIR" && zip -qr gymbrain.zip gymbrain && rm -rf gymbrain)

echo "✓ Built $DIST_DIR/gymbrain.zip ($(du -h "$DIST_DIR/gymbrain.zip" | cut -f1))"
