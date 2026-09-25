#!/usr/bin/env bash
# Builds an upload-ready zip for shared hosting:
#   public_html/gautamgupta.in/gymbrainapi
# Only tracked/unignored files are packaged (no .env, uploads, caches),
# with production-only Composer dependencies.
set -euo pipefail

BACKEND_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$BACKEND_DIR/dist"
STAGE_DIR="$DIST_DIR/gymbrainapi"
ZIP_PATH="$DIST_DIR/gymbrainapi.zip"

EXCLUDES=(
    "tests" "deploy" "*.md" "phpunit.xml" ".editorconfig" ".npmrc"
    "package.json" "vite.config.js" "resources/css/*" "resources/js/*"
)

echo "→ Staging files"
rm -rf "$DIST_DIR"
mkdir -p "$STAGE_DIR"
cd "$BACKEND_DIR"
git ls-files --cached --others --exclude-standard -z -- . \
    | rsync -a --from0 --files-from=- ./ "$STAGE_DIR/"
for pattern in "${EXCLUDES[@]}"; do
    (cd "$STAGE_DIR" && rm -rf $pattern)
done

echo "→ Installing production dependencies"
composer install --working-dir="$STAGE_DIR" --no-dev --optimize-autoloader \
    --no-interaction --no-progress --quiet

# package:discover writes caches for this machine; the server rebuilds them.
rm -f "$STAGE_DIR"/bootstrap/cache/*.php

echo "→ Zipping"
(cd "$DIST_DIR" && zip -qr "$ZIP_PATH" gymbrainapi)
rm -rf "$STAGE_DIR"

echo "✓ Built $ZIP_PATH ($(du -h "$ZIP_PATH" | cut -f1))"
