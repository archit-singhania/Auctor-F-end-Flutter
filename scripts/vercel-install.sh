#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Match the SDK used for the locally verified release build.
auctor_flutter_version=3.47.3
auctor_flutter_revision=e8113bf45620cbeb8aff64947ee4c93e16adb4cf
auctor_sdk="$PWD/.vercel-flutter"
if [[ ! -d "$auctor_sdk/.git" ]]; then
  git clone --depth 1 --branch "$auctor_flutter_version" https://github.com/flutter/flutter.git "$auctor_sdk"
fi
if [[ "$(git -C "$auctor_sdk" rev-parse HEAD)" != "$auctor_flutter_revision" ]]; then
  echo 'Flutter SDK does not match the verified pinned revision.' >&2
  exit 1
fi
export PATH="$auctor_sdk/bin:$PATH"
export FLUTTER_SUPPRESS_ANALYTICS=true
flutter pub get
