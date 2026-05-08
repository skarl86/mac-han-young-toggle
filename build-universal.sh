#!/bin/bash
# Universal Binary 빌드 (arm64 + x86_64) — 배포용
# Apple Silicon / Intel 맥 모두에서 동작하는 단일 .app 생성
set -e

cd "$(dirname "$0")"

APP_NAME="KeyboardRemap"
APP_DIR="${PWD}/${APP_NAME}.app"
BIN_PATH="${APP_DIR}/Contents/MacOS/${APP_NAME}"
TMP_DIR="${PWD}/.build-tmp"

echo "Building universal ${APP_NAME} (arm64 + x86_64, macOS 13+)..."

rm -rf "${APP_DIR}" "${TMP_DIR}"
mkdir -p "${APP_DIR}/Contents/MacOS"
mkdir -p "${APP_DIR}/Contents/Resources"
mkdir -p "${TMP_DIR}"

echo "  → arm64 컴파일..."
swiftc -O -parse-as-library \
    -target arm64-apple-macos13 \
    -o "${TMP_DIR}/${APP_NAME}-arm64" \
    "${PWD}/Sources/main.swift"

echo "  → x86_64 컴파일..."
swiftc -O -parse-as-library \
    -target x86_64-apple-macos13 \
    -o "${TMP_DIR}/${APP_NAME}-x86_64" \
    "${PWD}/Sources/main.swift"

echo "  → lipo 로 합치기..."
lipo -create -output "${BIN_PATH}" \
    "${TMP_DIR}/${APP_NAME}-arm64" \
    "${TMP_DIR}/${APP_NAME}-x86_64"

rm -rf "${TMP_DIR}"

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

echo ""
echo "✓ Universal binary built: ${APP_DIR}"
echo ""
file "${BIN_PATH}"
