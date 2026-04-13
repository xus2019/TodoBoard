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

echo "==> Building TodoBoard.app v$VERSION"

# Clean previous build
rm -rf "$APP_DIR"

# Create bundle structure
mkdir -p "$CONTENTS/MacOS"
mkdir -p "$CONTENTS/Resources"

# Copy executable
cp "$BINARY_SRC" "$CONTENTS/MacOS/TodoBoard"
chmod +x "$CONTENTS/MacOS/TodoBoard"

# Copy resources (Assets.xcassets compiled output, InfoPlist.strings, etc.)
if [ -d "$RESOURCES_SRC" ]; then
  cp -R "$RESOURCES_SRC/." "$CONTENTS/Resources/"
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
