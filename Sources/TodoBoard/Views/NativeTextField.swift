import AppKit
import SwiftUI

struct NativeTextField: NSViewRepresentable {
    let placeholder: String
    @Binding var text: String
    var becomesFirstResponder: Bool = false
    var onSubmit: (() -> Void)? = nil

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onSubmit: onSubmit)
    }

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField(string: text)
        textField.placeholderString = placeholder
        textField.delegate = context.coordinator
        textField.isBordered = true
        textField.isBezeled = true
        textField.focusRingType = .default
        textField.lineBreakMode = .byTruncatingTail
        textField.font = .systemFont(ofSize: NSFont.systemFontSize)
        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
        nsView.placeholderString = placeholder

        if !becomesFirstResponder {
            context.coordinator.didRequestFirstResponder = false
            return
        }
        guard !context.coordinator.didRequestFirstResponder else { return }
        context.coordinator.didRequestFirstResponder = true
        DispatchQueue.main.async {
            guard let window = nsView.window else { return }
            if window.firstResponder !== nsView.currentEditor() && window.firstResponder !== nsView {
                window.makeFirstResponder(nsView)
            }
        }
    }

    final class Coordinator: NSObject, NSTextFieldDelegate {
        @Binding private var text: String
        private let onSubmit: (() -> Void)?
        var didRequestFirstResponder = false

        init(text: Binding<String>, onSubmit: (() -> Void)?) {
            _text = text
            self.onSubmit = onSubmit
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            text = textField.stringValue
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                onSubmit?()
                return onSubmit != nil
            }
            return false
        }
    }
}
