#!/usr/bin/env bash
set -euo pipefail

PRODUCT_NAME="${PRODUCT_NAME:-CodexMaxx}"
APP_NAME="${APP_NAME:-CodexMaxx}"
BUNDLE_ID="${BUNDLE_ID:-dev.kitze.codexmaxx}"
VERSION="${VERSION:-0.9.1}"
BUILD_NUMBER="${BUILD_NUMBER:-${GITHUB_RUN_NUMBER:-1}}"
CONFIGURATION="${CONFIGURATION:-release}"
SIGN_IDENTITY="${CODE_SIGN_IDENTITY:--}"
SPARKLE_FEED_URL="${SPARKLE_FEED_URL-https://releaseflow.net/kitze/codexmaxx/sparkle/appcast.xml}"
SPARKLE_PUBLIC_KEY="${SPARKLE_PUBLIC_KEY-JrmuMZR2IMke8Tkm+znSxzRCzgmsvpLFT/9Bp5TRiEw=}"
EXECUTABLE_NAME="${EXECUTABLE_NAME:-$APP_NAME}"
ICON_FILE="${ICON_FILE:-$PRODUCT_NAME.icns}"
OUT_DIR="${OUT_DIR:-$PWD}"
APP="$OUT_DIR/$APP_NAME.app"
ENTITLEMENTS="$OUT_DIR/$APP_NAME.entitlements"

swift build -c "$CONFIGURATION" --product "$PRODUCT_NAME"
BIN_DIR="$(swift build -c "$CONFIGURATION" --product "$PRODUCT_NAME" --show-bin-path)"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$APP/Contents/Frameworks"
cp "$BIN_DIR/$PRODUCT_NAME" "$APP/Contents/MacOS/$EXECUTABLE_NAME"
cp Icon.icns "$APP/Contents/Resources/$ICON_FILE"
install_name_tool -add_rpath "@executable_path/../Frameworks" "$APP/Contents/MacOS/$EXECUTABLE_NAME" 2>/dev/null || true

SPARKLE_FRAMEWORK="$BIN_DIR/Sparkle.framework"
if [[ -d "$SPARKLE_FRAMEWORK" ]]; then
  cp -R "$SPARKLE_FRAMEWORK" "$APP/Contents/Frameworks/"
fi

/usr/libexec/PlistBuddy -c 'Clear dict' \
  -c "Add :CFBundleExecutable string $EXECUTABLE_NAME" \
  -c "Add :CFBundleIdentifier string $BUNDLE_ID" \
  -c "Add :CFBundleName string $APP_NAME" \
  -c "Add :CFBundleDisplayName string $APP_NAME" \
  -c 'Add :CFBundlePackageType string APPL' \
  -c "Add :CFBundleVersion string $BUILD_NUMBER" \
  -c "Add :CFBundleShortVersionString string $VERSION" \
  -c "Add :CFBundleIconFile string $ICON_FILE" \
  -c 'Add :LSMinimumSystemVersion string 14.0' \
  -c 'Add :LSUIElement bool true' \
  "$APP/Contents/Info.plist"

/usr/libexec/PlistBuddy -c 'Clear dict' \
  -c 'Add :com.apple.security.cs.disable-library-validation bool true' \
  "$ENTITLEMENTS"

if [[ -n "$SPARKLE_FEED_URL" ]]; then
  /usr/libexec/PlistBuddy -c "Add :SUFeedURL string $SPARKLE_FEED_URL" "$APP/Contents/Info.plist"
fi
if [[ -n "$SPARKLE_PUBLIC_KEY" ]]; then
  /usr/libexec/PlistBuddy -c "Add :SUPublicEDKey string $SPARKLE_PUBLIC_KEY" "$APP/Contents/Info.plist"
fi

TIMESTAMP_FLAG="--timestamp=none"
if [[ "$SIGN_IDENTITY" != "-" ]]; then
  TIMESTAMP_FLAG="--timestamp"
fi

xattr -cr "$APP" 2>/dev/null || true

clear_code_signing_xattrs() {
  xattr -cr "$APP" 2>/dev/null || true
  if command -v SetFile >/dev/null 2>&1; then
    while IFS= read -r target; do
      SetFile -a b "$target" 2>/dev/null || true
    done < <(find "$APP" -xattrname com.apple.FinderInfo -print 2>/dev/null || true)
  fi
  while IFS= read -r target; do
    xattr -d com.apple.FinderInfo "$target" 2>/dev/null || true
    xattr -d 'com.apple.fileprovider.fpfs#P' "$target" 2>/dev/null || true
  done < <(find "$APP" \( -xattrname com.apple.FinderInfo -o -xattrname 'com.apple.fileprovider.fpfs#P' \) -print 2>/dev/null || true)
}

clear_code_signing_xattrs

sign_path() {
  local target="$1"
  if ! codesign --force "$TIMESTAMP_FLAG" --options runtime --sign "$SIGN_IDENTITY" "$target"; then
    if [[ "$SIGN_IDENTITY" == "-" ]]; then
      return 1
    fi
    echo "Developer ID signing failed for $target; falling back to ad-hoc signing." >&2
    codesign --force --timestamp=none --options runtime --sign - "$target"
  fi
}

if [[ -d "$APP/Contents/Frameworks/Sparkle.framework" ]]; then
  sign_path "$APP/Contents/Frameworks/Sparkle.framework"
fi
xattr -cr "$APP" 2>/dev/null || true
if ! codesign --force --deep "$TIMESTAMP_FLAG" --options runtime --entitlements "$ENTITLEMENTS" --sign "$SIGN_IDENTITY" "$APP"; then
  if [[ "$SIGN_IDENTITY" == "-" ]]; then
    exit 1
  fi
  echo "Developer ID signing failed for $APP; falling back to ad-hoc signing." >&2
  codesign --force --deep --timestamp=none --options runtime --entitlements "$ENTITLEMENTS" --sign - "$APP"
fi
clear_code_signing_xattrs

echo "$APP"
