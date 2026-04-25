#!/usr/bin/env bash
# Build a macOS .app bundle from the SPM release binary.
# Usage: scripts/build-app.sh <version>
# e.g.:  scripts/build-app.sh 1.0.0

set -euo pipefail

VERSION="${1:-1.0.0}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$REPO_ROOT/build"
APP_DIR="$BUILD_DIR/TodoBoard.app"
CONTENTS="$APP_DIR/Contents"
BINARY_SRC="$REPO_ROOT/.build/release/TodoBoard"
RESOURCES_SRC="$REPO_ROOT/Sources/TodoBoard/Resources"
ICON_SRC="$REPO_ROOT/docs/icon.png"

echo "==> Building TodoBoard.app v$VERSION"

# Clean previous build
rm -rf "$APP_DIR"

# Create bundle structure
mkdir -p "$CONTENTS/MacOS"
mkdir -p "$CONTENTS/Resources"

# Copy executable
cp "$BINARY_SRC" "$CONTENTS/MacOS/TodoBoard"
chmod +x "$CONTENTS/MacOS/TodoBoard"

# Copy resources (InfoPlist.strings, etc.)
if [ -d "$RESOURCES_SRC" ]; then
  cp -R "$RESOURCES_SRC/." "$CONTENTS/Resources/"
fi

# Generate .icns from docs/icon.png
if [ -f "$ICON_SRC" ]; then
  echo "==> Generating app icon..."
  ICONSET_DIR="$BUILD_DIR/TodoBoard.iconset"
  ICON_PADDED="$BUILD_DIR/icon-padded.png"
  rm -rf "$ICONSET_DIR"
  mkdir -p "$ICONSET_DIR"

  # Pad the source so content fits the macOS Big Sur+ squircle template
  # (~824/1024 = 80% content area on a transparent canvas). Without this the
  # icon visually overshoots Apple's own icons in the Dock/Finder.
  swift "$REPO_ROOT/scripts/pad-icon.swift" "$ICON_SRC" "$ICON_PADDED"
  ICON_MASTER="$ICON_PADDED"

  sips -z 16   16   "$ICON_MASTER" --out "$ICONSET_DIR/icon_16x16.png"    > /dev/null
  sips -z 32   32   "$ICON_MASTER" --out "$ICONSET_DIR/icon_16x16@2x.png" > /dev/null
  sips -z 32   32   "$ICON_MASTER" --out "$ICONSET_DIR/icon_32x32.png"    > /dev/null
  sips -z 64   64   "$ICON_MASTER" --out "$ICONSET_DIR/icon_32x32@2x.png" > /dev/null
  sips -z 128  128  "$ICON_MASTER" --out "$ICONSET_DIR/icon_128x128.png"  > /dev/null
  sips -z 256  256  "$ICON_MASTER" --out "$ICONSET_DIR/icon_128x128@2x.png" > /dev/null
  sips -z 256  256  "$ICON_MASTER" --out "$ICONSET_DIR/icon_256x256.png"  > /dev/null
  sips -z 512  512  "$ICON_MASTER" --out "$ICONSET_DIR/icon_256x256@2x.png" > /dev/null
  sips -z 512  512  "$ICON_MASTER" --out "$ICONSET_DIR/icon_512x512.png"  > /dev/null
  cp "$ICON_MASTER"                       "$ICONSET_DIR/icon_512x512@2x.png"

  iconutil -c icns "$ICONSET_DIR" -o "$CONTENTS/Resources/TodoBoard.icns"
  rm -rf "$ICONSET_DIR"
  rm -f "$ICON_PADDED"
  echo "    Icon generated."
fi

# Write Info.plist
cat > "$CONTENTS/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.xus2019.todoboard</string>
    <key>CFBundleName</key>
    <string>TodoBoard</string>
    <key>CFBundleDisplayName</key>
    <string>TodoBoard</string>
    <key>CFBundleExecutable</key>
    <string>TodoBoard</string>
    <key>CFBundleIconFile</key>
    <string>TodoBoard</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>CFBundleDevelopmentRegion</key>
    <string>zh-Hans</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
</dict>
</plist>
PLIST

echo "==> App bundle created at $APP_DIR"
echo "    Version: $VERSION"
echo "    Size: $(du -sh "$APP_DIR" | awk '{print $1}')"
