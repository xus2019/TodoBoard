import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    static let mainWindowFrameName: NSWindow.FrameAutosaveName = "TodoBoardMainWindow"
    private var mainWindowsApplied: Set<ObjectIdentifier> = []

    func applicationWillFinishLaunching(_ notification: Notification) {
        // Subscribe early so the very first main window can be re-framed before users see jitter.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidBecomeMain(_:)),
            name: NSWindow.didBecomeMainNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidBecomeKey(_:)),
            name: NSWindow.didBecomeKeyNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowWillClose(_:)),
            name: NSWindow.willCloseNotification,
            object: nil
        )
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.async {
            NSApp.mainWindow?.makeKeyAndOrderFront(nil)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        for window in NSApp.windows where Self.isMainWindow(window) {
            window.saveFrame(usingName: Self.mainWindowFrameName)
        }
    }

    @objc nonisolated private func windowDidBecomeMain(_ notification: Notification) {
        let window = notification.object as? NSWindow
        DispatchQueue.main.async { [self] in
            guard let window, Self.isMainWindow(window) else { return }
            applyMainWindowFrameIfNeeded(window)
        }
    }

    @objc nonisolated private func windowDidBecomeKey(_ notification: Notification) {
        let window = notification.object as? NSWindow
        DispatchQueue.main.async { [self] in
            guard let window else { return }
            let id = window.identifier?.rawValue ?? ""
            let title = window.title
            if id.contains("settings") || title.contains("设置") || title == "Settings" {
                window.center()
            } else if Self.isMainWindow(window) {
                applyMainWindowFrameIfNeeded(window)
            }
        }
    }

    @objc nonisolated private func windowWillClose(_ notification: Notification) {
        let window = notification.object as? NSWindow
        DispatchQueue.main.async { [self] in
            guard let window, Self.isMainWindow(window) else { return }
            window.saveFrame(usingName: Self.mainWindowFrameName)
            mainWindowsApplied.remove(ObjectIdentifier(window))
        }
    }

    private func applyMainWindowFrameIfNeeded(_ window: NSWindow) {
        let key = ObjectIdentifier(window)
        guard !mainWindowsApplied.contains(key) else { return }
        mainWindowsApplied.insert(key)

        // Hide while reframing so SwiftUI's initial frame doesn't visually pop.
        let originalAlpha = window.alphaValue
        window.alphaValue = 0

        if !window.setFrameUsingName(Self.mainWindowFrameName) {
            // First launch (or autosave gone): center a sensible default size on the active screen.
            let screen = window.screen ?? NSScreen.main
            let visible = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
            let target = NSSize(width: 1200, height: 800)
            let origin = NSPoint(
                x: visible.midX - target.width / 2,
                y: visible.midY - target.height / 2
            )
            window.setFrame(NSRect(origin: origin, size: target), display: true)
            window.saveFrame(usingName: Self.mainWindowFrameName)
        }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.18
            window.animator().alphaValue = max(originalAlpha, 1)
        }
    }

    private static func isMainWindow(_ window: NSWindow) -> Bool {
        let id = window.identifier?.rawValue ?? ""
        let title = window.title
        if id.contains("settings") || title.contains("设置") || title == "Settings" {
            return false
        }
        return true
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            sender.mainWindow?.makeKeyAndOrderFront(nil)
        }
        sender.activate(ignoringOtherApps: true)
        return true
    }
}
