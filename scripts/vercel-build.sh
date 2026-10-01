#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Only public URLs enter the Flutter bundle. Provider/database credentials belong
# exclusively to the FastAPI service's protected environment.
node scripts/production-config.cjs
export PATH="$PWD/.vercel-flutter/bin:$PATH"
export FLUTTER_SUPPRESS_ANALYTICS=true
flutter build web --release --no-wasm-dry-run \
  --dart-define="API_BASE_URL=$AUCTOR_API_URL" \
  --dart-define="WEB_BASE_URL=$AUCTOR_WEB_URL"
