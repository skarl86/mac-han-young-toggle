import SwiftUI
import AppKit

// HID Usage Codes
//   0x7000000E7 = Right GUI (Right Command)
//   0x70000006D = F18 (잘 안 쓰는 키 — 시스템 설정에서 한/영 단축키로 바인딩)
let MAPPING_ACTIVE = #"{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x7000000E7,"HIDKeyboardModifierMappingDst":0x70000006D}]}"#
let MAPPING_INACTIVE = #"{"UserKeyMapping":[]}"#

let SETUP_GUIDE_TEXT = """
이 앱은 오른쪽 Command 키를 F18로 리매핑합니다.
한/영 전환은 macOS의 단축키 시스템을 통해 동작합니다.

다음 1회 설정이 필요합니다:

1. 시스템 설정 > 키보드 열기
2. "키보드 단축키..." 버튼 클릭
3. 왼쪽 사이드바에서 "입력 소스" 선택
4. "이전 입력 소스 선택" 의 단축키 영역을 더블클릭
5. 오른쪽 Command 키 누르기 (이 앱이 실행 중이면 F18로 인식됨)
6. 완료 — 닫기

전제 조건:
한국어 입력 소스가 추가되어 있어야 함
(시스템 설정 > 키보드 > 텍스트 입력 > 입력 소스 > 편집)
"""

class RemapManager: ObservableObject {
    @Published private(set) var isActive: Bool = false

    init() {
        applyMapping(active: true)
        isActive = true

        let firstRunKey = "hasShownSetupGuide_v1"
        if !UserDefaults.standard.bool(forKey: firstRunKey) {
            UserDefaults.standard.set(true, forKey: firstRunKey)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.showSetupGuide()
            }
        }
    }

    func toggle() {
        let next = !isActive
        applyMapping(active: next)
        isActive = next
    }

    func reapply() {
        applyMapping(active: isActive)
    }

    private func applyMapping(active: Bool) {
        let process = Process()
        process.launchPath = "/usr/bin/hidutil"
        process.arguments = ["property", "--set", active ? MAPPING_ACTIVE : MAPPING_INACTIVE]
        try? process.run()
        process.waitUntilExit()
    }

    func openConfigFolder() {
        // .app 번들이 위치한 폴더를 열기 — 클론 경로에 무관하게 동작
        let parent = Bundle.main.bundleURL.deletingLastPathComponent()
        NSWorkspace.shared.open(parent)
    }

    func openKeyboardSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.Keyboard-Settings.extension") {
            NSWorkspace.shared.open(url)
        }
    }

    func showSetupGuide() {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = "한/영 매핑 — 설정 방법"
        alert.informativeText = SETUP_GUIDE_TEXT
        alert.alertStyle = .informational
        alert.addButton(withTitle: "키보드 단축키 설정 열기")
        alert.addButton(withTitle: "닫기")

        if alert.runModal() == .alertFirstButtonReturn {
            openKeyboardSettings()
        }
    }
}

@main
struct KeyboardRemapApp: App {
    @StateObject private var manager = RemapManager()

    var body: some Scene {
        MenuBarExtra {
            Button(manager.isActive ? "✓ 한/영 매핑: 활성" : "한/영 매핑: 비활성") {
                manager.toggle()
            }
            Divider()
            Button("설정 방법 보기") {
                manager.showSetupGuide()
            }
            Button("키보드 단축키 설정 열기") {
                manager.openKeyboardSettings()
            }
            Divider()
            Button("재적용 (sleep 후 풀렸을 때)") {
                manager.reapply()
            }
            Button("설정 폴더 열기") {
                manager.openConfigFolder()
            }
            Divider()
            Button("종료") {
                NSApplication.shared.terminate(nil)
            }
        } label: {
            Image(systemName: manager.isActive ? "command.square.fill" : "command.square")
        }
        .menuBarExtraStyle(.menu)
    }
}
