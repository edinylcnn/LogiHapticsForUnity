#!/usr/bin/env bash
# Release the Unity package as a GitHub release + tag.
#
# Usage:   ./scripts/release-unity.sh <version>
# Example: ./scripts/release-unity.sh 1.0.1
#
# Bumps package.json → commits → pushes → tags → pushes tag → creates release.
# Keeping the bump *before* the tag is what lets OpenUPM read the right
# version from package.json at the tagged commit.

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "usage: $0 <version>   (e.g. 1.0.1)"
  exit 1
fi

VERSION="$1"
TAG="unity-v${VERSION}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PKG_JSON="$REPO_ROOT/unity-package/package.json"

echo ">> checking preconditions"
command -v gh >/dev/null || { echo "gh not found"; exit 1; }
command -v jq >/dev/null || { echo "jq not found"; exit 1; }

if [ -n "$(git -C "$REPO_ROOT" status --porcelain)" ]; then
  echo "working tree not clean — commit or stash first"
  git -C "$REPO_ROOT" status --short
  exit 1
fi

if git -C "$REPO_ROOT" rev-parse "$TAG" >/dev/null 2>&1; then
  echo "tag $TAG already exists"
  exit 1
fi

CURRENT="$(jq -r .version "$PKG_JSON")"
if [ "$CURRENT" != "$VERSION" ]; then
  echo ">> bumping package.json $CURRENT -> $VERSION"
  tmp=$(mktemp)
  jq --arg v "$VERSION" '.version = $v' "$PKG_JSON" > "$tmp"
  mv "$tmp" "$PKG_JSON"
  git -C "$REPO_ROOT" add "$PKG_JSON"
  git -C "$REPO_ROOT" commit -m "Bump unity-package to $VERSION"
  git -C "$REPO_ROOT" push
fi

echo ">> tagging $TAG (at HEAD, so package.json inside the tag is $VERSION)"
git -C "$REPO_ROOT" tag -a "$TAG" -m "Unity Package $VERSION"
git -C "$REPO_ROOT" push origin "$TAG"

echo ">> creating GitHub release"
gh release create "$TAG" \
  --title "HapticBridge for Unity — Package v$VERSION" \
  --generate-notes \
  --notes "Unity Package Manager install:

    openupm add com.edinylcnn.hapticbridge

or Git URL: https://github.com/edinylcnn/HapticBridgeForUnity.git?path=/unity-package#$TAG

For the companion Logi Options+ plugin (.lplug4), see the plugin-v* release."

echo
echo "done — https://github.com/edinylcnn/HapticBridgeForUnity/releases/tag/$TAG"
