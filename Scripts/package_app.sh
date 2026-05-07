#!/usr/bin/env bash
set -euo pipefail

APP_NAME="CodexMaxx"
BUNDLE_ID="${BUNDLE_ID:-dev.kitze.codexmaxx}"
VERSION="${VERSION:-0.9.1}"
BUILD_NUMBER="${BUILD_NUMBER:-${GITHUB_RUN_NUMBER:-1}}"
CONFIGURATION="${CONFIGURATION:-release}"
SIGN_IDENTITY="${CODE_SIGN_IDENTITY:--}"
OUT_DIR="${OUT_DIR:-$PWD}"
APP="$OUT_DIR/$APP_NAME.app"

swift build -c "$CONFIGURATION" --product "$APP_NAME"
BIN_DIR="$(swift build -c "$CONFIGURATION" --product "$APP_NAME" --show-bin-path)"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$APP/Contents/Frameworks"
cp "$BIN_DIR/$APP_NAME" "$APP/Contents/MacOS/$APP_NAME"
cp Icon.icns "$APP/Contents/Resources/$APP_NAME.icns"

SPARKLE_FRAMEWORK="$BIN_DIR/Sparkle.framework"
if [[ -d "$SPARKLE_FRAMEWORK" ]]; then
  cp -R "$SPARKLE_FRAMEWORK" "$APP/Contents/Frameworks/"
fi

/usr/libexec/PlistBuddy -c 'Clear dict' \
  -c "Add :CFBundleExecutable string $APP_NAME" \
  -c "Add :CFBundleIdentifier string $BUNDLE_ID" \
  -c "Add :CFBundleName string $APP_NAME" \
  -c "Add :CFBundleDisplayName string $APP_NAME" \
  -c 'Add :CFBundlePackageType string APPL' \
  -c "Add :CFBundleVersion string $BUILD_NUMBER" \
  -c "Add :CFBundleShortVersionString string $VERSION" \
  -c "Add :CFBundleIconFile string $APP_NAME.icns" \
  -c 'Add :LSMinimumSystemVersion string 14.0' \
  -c 'Add :LSUIElement bool true' \
  "$APP/Contents/Info.plist"

if [[ -n "${SPARKLE_FEED_URL:-}" ]]; then
  /usr/libexec/PlistBuddy -c "Add :SUFeedURL string $SPARKLE_FEED_URL" "$APP/Contents/Info.plist"
fi
if [[ -n "${SPARKLE_PUBLIC_KEY:-}" ]]; then
  /usr/libexec/PlistBuddy -c "Add :SUPublicEDKey string $SPARKLE_PUBLIC_KEY" "$APP/Contents/Info.plist"
fi

TIMESTAMP_FLAG="--timestamp=none"
if [[ "$SIGN_IDENTITY" != "-" ]]; then
  TIMESTAMP_FLAG="--timestamp"
fi

xattr -cr "$APP" 2>/dev/null || true

if [[ -d "$APP/Contents/Frameworks/Sparkle.framework" ]]; then
  codesign --force "$TIMESTAMP_FLAG" --options runtime --sign "$SIGN_IDENTITY" "$APP/Contents/Frameworks/Sparkle.framework"
fi
xattr -cr "$APP" 2>/dev/null || true
codesign --force --deep "$TIMESTAMP_FLAG" --options runtime --sign "$SIGN_IDENTITY" "$APP"

echo "$APP"
