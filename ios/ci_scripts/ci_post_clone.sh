#!/bin/sh
# Xcode Cloud — runs after git clone, before package resolution / xcodebuild.
# Generates Flutter/ephemeral (incl. FlutterGeneratedPluginSwiftPackage), which
# is gitignored and therefore missing on a clean CI checkout.
set -euo pipefail

echo "=== ci_post_clone: start ==="

REPO_ROOT="${CI_PRIMARY_REPOSITORY_PATH:-}"
if [ -z "$REPO_ROOT" ]; then
  # Local fallback: ios/ci_scripts -> app root
  REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
fi

cd "$REPO_ROOT"
echo "Repo root: $REPO_ROOT"

# Homebrew Cask Flutter is unavailable on Xcode Cloud; clone the SDK.
FLUTTER_DIR="${HOME}/flutter"
FLUTTER_CHANNEL="${FLUTTER_CHANNEL:-stable}"

if [ ! -x "${FLUTTER_DIR}/bin/flutter" ]; then
  echo "=== Cloning Flutter (${FLUTTER_CHANNEL}) ==="
  rm -rf "${FLUTTER_DIR}"
  git clone https://github.com/flutter/flutter.git \
    --depth 1 \
    -b "${FLUTTER_CHANNEL}" \
    "${FLUTTER_DIR}"
else
  echo "=== Reusing cached Flutter at ${FLUTTER_DIR} ==="
fi

export PATH="${PATH}:${FLUTTER_DIR}/bin"
export FLUTTER_ROOT="${FLUTTER_DIR}"
export PUB_CACHE="${HOME}/.pub-cache"

flutter --version
flutter precache --ios
flutter pub get

# Ensures Generated.xcconfig + ephemeral Swift packages exist, and bumps the
# FlutterGeneratedPluginSwiftPackage iOS deployment target toward the project.
echo "=== flutter build ios --config-only ==="
flutter build ios --config-only --no-codesign

GENERATED_PACKAGE="${REPO_ROOT}/ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift"
if [ -f "${GENERATED_PACKAGE}" ]; then
  echo "=== Patching FlutterGeneratedPluginSwiftPackage platforms to iOS 15.0 ==="
  # pub get can reset this to 13.0; Firebase / project require 15.0+
  sed -i '' 's/\.iOS("[0-9]*\.[0-9]*")/\.iOS("15.0")/' "${GENERATED_PACKAGE}"
  grep -n 'iOS(' "${GENERATED_PACKAGE}" | head -5
else
  echo "ERROR: FlutterGeneratedPluginSwiftPackage was not generated"
  ls -la "${REPO_ROOT}/ios/Flutter/ephemeral" || true
  ls -la "${REPO_ROOT}/ios/Flutter/ephemeral/Packages" || true
  exit 1
fi

echo "=== CocoaPods ==="
cd "${REPO_ROOT}/ios"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
pod install --repo-update

# Clean stale SPM binary artifacts so Xcode Cloud package resolution does not
# hit "already exists in file system" with Firebase / gRPC zips.
echo "=== Cleaning SPM binary-target caches ==="
rm -rf "${HOME}/Library/Caches/org.swift.swiftpm/artifacts" || true
rm -rf /Users/local/Library/Caches/org.swift.swiftpm/artifacts || true
rm -rf /Volumes/workspace/DerivedData || true

echo "=== ci_post_clone: done ==="
exit 0
