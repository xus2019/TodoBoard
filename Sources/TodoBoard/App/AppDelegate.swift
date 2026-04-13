import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.async {
            NSApp.mainWindow?.makeKeyAndOrderFront(nil)
        }

        // Center settings window whenever it appears
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidBecomeKey(_:)),
            name: NSWindow.didBecomeKeyNotification,
            object: nil
        )
    }

    @objc nonisolated private func windowDidBecomeKey(_ notification: Notification) {
        let window = notification.object as? NSWindow
        DispatchQueue.main.async {
            guard let window else { return }
            let id = window.identifier?.rawValue ?? ""
            let title = window.title
            if id.contains("settings") || title.contains("设置") || title == "Settings" {
                window.center()
            }
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            sender.mainWindow?.makeKeyAndOrderFront(nil)
        }
        sender.activate(ignoringOtherApps: true)
        return true
    }
}
