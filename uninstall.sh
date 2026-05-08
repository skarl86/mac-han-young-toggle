#!/bin/bash
set -e

APP_DIR="$HOME/.config/keyboard-remap/KeyboardRemap.app"

killall KeyboardRemap 2>/dev/null || true

hidutil property --set '{"UserKeyMapping":[]}' >/dev/null

rm -rf "${APP_DIR}"

echo "✓ 키 매핑 해제 완료. 오른쪽 Command 키가 원래 동작으로 복원됨."
echo ""
echo "추가 정리 (수동):"
echo "  1. 시스템 설정 > 일반 > 로그인 항목 및 확장 프로그램 > KeyboardRemap 제거"
echo "  2. 폴더 자체를 삭제하려면: rm -rf ~/.config/keyboard-remap"
