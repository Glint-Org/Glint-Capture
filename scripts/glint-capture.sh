#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f pubspec.yaml ]]; then
  echo "Run this from your Flutter app root." >&2
  exit 1
fi

if command -v glint >/dev/null 2>&1; then
  glint capture
elif [[ -f test/glint_screenshots_test.dart ]]; then
  flutter test test/glint_screenshots_test.dart
else
  dart run glint_capture capture
fi

echo "Done. Import output folder (session.json + PNGs) in Glint-Web."
