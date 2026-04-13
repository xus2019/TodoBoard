import AppKit
import Carbon.HIToolbox
import Foundation

enum AppShortcut: String {
    case search
    case quickInput
    case newProject
}

@MainActor
final class KeyboardShortcuts {
    static let shared = KeyboardShortcuts()

    private var handlerRefs: [AppShortcut: EventHotKeyRef?] = [:]
    private var callbacks: [AppShortcut: () -> Void] = [:]

    private init() {
        installHandlerIfNeeded()
    }

    func register(_ shortcut: AppShortcut, callback: @escaping () -> Void) {
        callbacks[shortcut] = callback
        unregister(shortcut)

        let hotKeyID = EventHotKeyID(signature: OSType(0x54424430), id: shortcut.identifier)
        var ref: EventHotKeyRef?
        let keyCode: UInt32
        let modifiers: UInt32

        switch shortcut {
        case .search:
            keyCode = UInt32(kVK_ANSI_F)
            modifiers = UInt32(cmdKey)
        case .quickInput:
            keyCode = UInt32(kVK_ANSI_T)
            modifiers = UInt32(cmdKey | shiftKey)
        case .newProject:
            keyCode = UInt32(kVK_ANSI_N)
            modifiers = UInt32(cmdKey | shiftKey)
        }

        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &ref)
        handlerRefs[shortcut] = ref
    }

    func unregister(_ shortcut: AppShortcut) {
        if let ref = handlerRefs[shortcut] as? EventHotKeyRef {
            UnregisterEventHotKey(ref)
        }
        handlerRefs[shortcut] = nil
    }

    private func installHandlerIfNeeded() {
        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, eventRef, userData in
                guard let userData else { return noErr }
                let manager = Unmanaged<KeyboardShortcuts>.fromOpaque(userData).takeUnretainedValue()
                var hotKeyID = EventHotKeyID()
                GetEventParameter(
                    eventRef,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                Task { @MainActor in
                    manager.handle(identifier: hotKeyID.id)
                }
                return noErr
            },
            1,
            &eventSpec,
            Unmanaged.passUnretained(self).toOpaque(),
            nil
        )
    }

    private func handle(identifier: UInt32) {
        guard let shortcut = AppShortcut(shortcutIdentifier: identifier) else { return }
        NSApp.activate(ignoringOtherApps: true)
        callbacks[shortcut]?()
    }
}

private extension AppShortcut {
    var identifier: UInt32 {
        switch self {
        case .search:
            1
        case .quickInput:
            2
        case .newProject:
            3
        }
    }

    init?(shortcutIdentifier: UInt32) {
        switch shortcutIdentifier {
        case 1:
            self = .search
        case 2:
            self = .quickInput
        case 3:
            self = .newProject
        default:
            return nil
        }
    }
}
