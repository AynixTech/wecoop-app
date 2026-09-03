#!/bin/sh
# Xcode Cloud — runs immediately before xcodebuild.
# Extra safety if SPM binary caches were restored after ci_post_clone.
set -euo pipefail

echo "=== ci_pre_xcodebuild: cleaning SPM artifact caches ==="

rm -rf "${HOME}/Library/Caches/org.swift.swiftpm/artifacts" || true
rm -rf /Users/local/Library/Caches/org.swift.swiftpm/artifacts || true
rm -rf /Volumes/workspace/DerivedData || true

REPO_ROOT="${CI_PRIMARY_REPOSITORY_PATH:-}"
if [ -z "$REPO_ROOT" ]; then
  REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
fi

GENERATED_PACKAGE="${REPO_ROOT}/ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage"
if [ ! -d "${GENERATED_PACKAGE}" ]; then
  echo "ERROR: ${GENERATED_PACKAGE} is missing. ci_post_clone.sh must run successfully first."
  exit 1
fi

echo "=== ci_pre_xcodebuild: ok ==="
exit 0
