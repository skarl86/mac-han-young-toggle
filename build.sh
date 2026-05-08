#!/bin/bash
set -e

cd "$(dirname "$0")"

APP_NAME="KeyboardRemap"
APP_DIR="${PWD}/${APP_NAME}.app"
BIN_PATH="${APP_DIR}/Contents/MacOS/${APP_NAME}"

echo "Building ${APP_NAME}..."

rm -rf "${APP_DIR}"
mkdir -p "${APP_DIR}/Contents/MacOS"
mkdir -p "${APP_DIR}/Contents/Resources"

swiftc -O -parse-as-library -o "${BIN_PATH}" "${PWD}/Sources/main.swift"

cat > "${APP_DIR}/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.local.keyboard-remap</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>한/영 매핑</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

echo "✓ Built: ${APP_DIR}"
echo ""
echo "실행: open '${APP_DIR}'"
