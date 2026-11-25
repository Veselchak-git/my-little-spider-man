#!/usr/bin/env bash
set -euo pipefail

INSTALLER_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$INSTALLER_DIR/.." && pwd)"
DIST="$ROOT/dist"
DISPLAY_APP_NAME="My Little Spider-Man"
BUNDLE_ID="com.veselchak.my-little-spider-man"
PRODUCT_BASENAME="MyLittleSpiderMan"

cd "$ROOT"

echo "==> Building app"
"$ROOT/scripts/buildApp.sh"

APP="$DIST/$DISPLAY_APP_NAME.app"
if [[ ! -d "$APP" ]]; then
  echo "error: missing app bundle at $APP" >&2
  exit 1
fi

VERSION="$(
  /usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist"
)"
BUILD="$(
  /usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$APP/Contents/Info.plist"
)"

STAGE="$DIST/installer-stage"
PKG_ROOT="$STAGE/root"
COMPONENT_PKG="$STAGE/$PRODUCT_BASENAME-component.pkg"
DIST_XML="$STAGE/distribution.xml"
FINAL_PKG="$DIST/$PRODUCT_BASENAME-$VERSION.pkg"
DMG_DIR="$STAGE/dmg"
DMG="$DIST/$PRODUCT_BASENAME-$VERSION.dmg"

rm -rf "$STAGE"
mkdir -p "$PKG_ROOT" "$DMG_DIR"

echo "==> Staging payload"
ditto "$APP" "$PKG_ROOT/$DISPLAY_APP_NAME.app"
codesign --force --deep --sign - "$PKG_ROOT/$DISPLAY_APP_NAME.app"

chmod +x "$INSTALLER_DIR/scripts/postinstall"

echo "==> Building component package"
pkgbuild \
  --root "$PKG_ROOT" \
  --install-location "/Applications" \
  --identifier "$BUNDLE_ID" \
  --version "$VERSION" \
  --scripts "$INSTALLER_DIR/scripts" \
  --ownership recommended \
  "$COMPONENT_PKG"

echo "==> Building product archive"
sed "s/VERSION_PLACEHOLDER/$VERSION/g" "$INSTALLER_DIR/distribution.xml" > "$DIST_XML"

productbuild \
  --distribution "$DIST_XML" \
  --resources "$INSTALLER_DIR/resources" \
  --package-path "$STAGE" \
  "$FINAL_PKG"

echo "==> Building disk image"
cp "$FINAL_PKG" "$DMG_DIR/"
cat > "$DMG_DIR/Install Instructions.txt" <<EOF
My Little Spider-Man $VERSION ($BUILD)

1. Double-click “$PRODUCT_BASENAME-$VERSION.pkg”.
2. Follow the Installer steps (Welcome → License → Install).
3. The app is copied to Applications and launched automatically.

If macOS says the installer can’t be opened:
  • Right-click the .pkg → Open → Open
  • Or allow it in System Settings → Privacy & Security

RU:
1. Дважды щёлкните “$PRODUCT_BASENAME-$VERSION.pkg”.
2. Пройдите шаги установщика.
3. Приложение появится в «Программы» и запустится само.

Если macOS блокирует установщик:
  • ПКМ по .pkg → «Открыть»
  • Или разрешите в Системных настройках → Конфиденциальность и безопасность
EOF

rm -f "$DMG"
diskutil image create from \
  --format UDZO \
  --volumeName "My Little Spider-Man $VERSION" \
  "$DMG_DIR" \
  "$DMG" >/dev/null

rm -rf "$STAGE"

echo
echo "Installer ready:"
echo "  PKG: $FINAL_PKG"
echo "  DMG: $DMG"
ls -lh "$FINAL_PKG" "$DMG"
