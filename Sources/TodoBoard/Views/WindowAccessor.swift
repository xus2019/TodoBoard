import AppKit
import SwiftUI

struct WindowAccessor: NSViewRepresentable {
    let onResolve: (NSWindow) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                resolve(window, coordinator: context.coordinator)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            if let window = nsView.window {
                resolve(window, coordinator: context.coordinator)
            }
        }
    }

    private func resolve(_ window: NSWindow, coordinator: Coordinator) {
        guard coordinator.window !== window else { return }
        coordinator.window = window
        onResolve(window)
    }

    final class Coordinator {
        weak var window: NSWindow?
    }
}
