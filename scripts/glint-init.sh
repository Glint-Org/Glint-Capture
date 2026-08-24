#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f pubspec.yaml ]]; then
  echo "Run this from your Flutter app root." >&2
  exit 1
fi

if ! grep -q 'glint_capture' pubspec.yaml; then
  echo "Add glint_capture under dev_dependencies first." >&2
  exit 1
fi

dart run glint_capture init
echo "Edit test/glint_screenshots_test.dart with real screens."
