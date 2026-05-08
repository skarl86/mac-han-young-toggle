# mac-han-young-toggle

오른쪽 Command 키를 한/영 전환 키로 매핑하는 macOS 메뉴바 앱.
Karabiner 같은 외부 앱 의존 없이 macOS 내장 `hidutil` 만 사용.

> **Why**: 윈도우에서 오른쪽 Alt를 한/영으로 쓰는 사용자가 macOS에서도 같은 위치(오른쪽 Command)를 쓰고 싶을 때.

## 동작 원리

HID Usage Code 단위 키 리매핑:
- `0x7000000E7` (Right GUI = 오른쪽 Command)
- → `0x70000006D` (F18 = 잘 안 쓰는 펑션 키)

그 후 시스템 설정에서 F18을 "이전 입력 소스 선택" 단축키로 바인딩.

> 처음에는 Lang1 (`0x700000090`) 직접 매핑을 시도했으나
> macOS 15에서 ANSI 키보드는 Lang1 키코드를 한/영 전환으로 처리하지 않음.
> F18 + 시스템 설정 바인딩 조합이 키보드 종류와 상관없이 확실하게 동작.

## 설치

### 1. 클론 + 빌드

```bash
git clone https://github.com/skarl86/mac-han-young-toggle.git ~/.config/keyboard-remap
cd ~/.config/keyboard-remap
./build.sh
open KeyboardRemap.app
```

> 다른 경로에 클론해도 동작합니다. `~/.config/keyboard-remap`는 권장 경로일 뿐.

### 2. 시스템 설정에서 단축키 바인딩 (1회)

앱 첫 실행 시 안내 다이얼로그가 뜹니다. 또는 메뉴바 ⌘ 아이콘 → "설정 방법 보기".

수동으로 하려면:
1. `시스템 설정 > 키보드` 열기
2. **"키보드 단축키..."** 버튼 클릭
3. 왼쪽 사이드바에서 **"입력 소스"** 선택
4. **"이전 입력 소스 선택"** 의 단축키 영역을 더블클릭
5. **오른쪽 Command 키 누르기** (앱이 실행 중이면 F18로 인식됨)
6. 완료

### 3. 한국어 입력 소스 추가 (필요 시)

`시스템 설정 > 키보드 > 텍스트 입력 > 입력 소스 > 편집` 에 한국어(2벌식 등) 추가.

### 4. 자동 실행 (로그인 시)

`시스템 설정 > 일반 > 로그인 항목 및 확장 프로그램` →
"열기 시" 섹션의 `+` 버튼 → `KeyboardRemap.app` 추가.

## 메뉴바 메뉴

```
✓ 한/영 매핑: 활성        ← 토글
─────────────────
설정 방법 보기            ← 안내 다이얼로그 다시 보기
키보드 단축키 설정 열기   ← 시스템 설정 바로 점프
─────────────────
재적용 (sleep 후 풀렸을 때)
설정 폴더 열기
─────────────────
종료
```

## 폴더 구조

```
mac-han-young-toggle/
├── README.md            ← 이 파일
├── Sources/
│   └── main.swift       ← SwiftUI 앱 소스
├── build.sh             ← 빌드 스크립트
├── uninstall.sh         ← 제거 스크립트
└── KeyboardRemap.app/   ← 빌드 결과 (gitignored)
```

## 현재 상태 확인 (미래의 나를 위해)

```bash
# 매핑 적용 여부 확인
hidutil property --get UserKeyMapping
# 출력에 30064771303 (Src=Right Cmd) → 30064771181 (Dst=F18) 보이면 활성

# 앱 실행 여부 확인
pgrep -lf KeyboardRemap

# 즉시 매핑 해제 (앱 종료 + 매핑 리셋)
killall KeyboardRemap; hidutil property --set '{"UserKeyMapping":[]}'
```

## 완전 제거

```bash
~/.config/keyboard-remap/uninstall.sh
```

추가로 시스템 설정 > 일반 > 로그인 항목 및 확장 프로그램에서 KeyboardRemap 제거.

## 트러블슈팅

### 첫 실행 시 보안 경고
로컬 컴파일 앱은 quarantine 속성이 없어서 보통 경고 없이 실행됨.
혹시 뜨면:
```bash
xattr -d com.apple.quarantine ~/.config/keyboard-remap/KeyboardRemap.app
```

### sleep 후 매핑이 풀렸을 때
드물게 sleep/wake 후 매핑이 유지되지 않음. 메뉴바 → "재적용" 클릭.

### 한/영 전환이 안 됨
- 한국어 입력 소스 추가되어 있는지 확인 (`시스템 설정 > 키보드 > 텍스트 입력 > 입력 소스`)
- F18 단축키 바인딩이 되어 있는지 확인 (`시스템 설정 > 키보드 > 키보드 단축키 > 입력 소스`)

### 앱 충돌 / 코드 변경 후 재빌드
```bash
killall KeyboardRemap 2>/dev/null
./build.sh
open KeyboardRemap.app
```

## 요구 사항

- macOS 13 (Ventura) 이상 — `MenuBarExtra` API 필요
- Xcode Command Line Tools (`xcode-select --install`)

## 라이선스

MIT
