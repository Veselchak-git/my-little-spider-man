#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PRODUCT_NAME="MyLittleSpiderMan"
DISPLAY_APP_NAME="My Little Spider-Man"
DIST="$ROOT/dist"
APP="$DIST/$DISPLAY_APP_NAME.app"
BIN_DIR="$APP/Contents/MacOS"
RES_DIR="$APP/Contents/Resources"

cd "$ROOT"

swift build -c release --product "$PRODUCT_NAME"

BIN_PATH="$(swift build -c release --show-bin-path)"
BINARY="$BIN_PATH/$PRODUCT_NAME"

rm -rf "$DIST/$PRODUCT_NAME.app" "$APP"
mkdir -p "$BIN_DIR" "$RES_DIR"
cp "$BINARY" "$BIN_DIR/$PRODUCT_NAME"
cp "$ROOT/resources/Info.plist" "$APP/Contents/Info.plist"
rm -rf "$RES_DIR/en.lproj" "$RES_DIR/ru.lproj"
cp -R "$ROOT/resources/en.lproj" "$RES_DIR/en.lproj"
cp -R "$ROOT/resources/ru.lproj" "$RES_DIR/ru.lproj"

chmod +x "$BIN_DIR/$PRODUCT_NAME"

# Ad-hoc sign so Gatekeeper treats the bundle as a coherent app.
codesign --force --deep --sign - "$APP"

echo "Built: $APP"
echo "Run with: open \"$APP\""
