import AppKit
import SwiftUI

struct WrappingTitleField: NSViewRepresentable {
    let placeholder: String
    @Binding var text: String
    var font: NSFont
    var textColor: NSColor
    /// When true, plain Enter submits and Cmd+Enter inserts a literal newline.
    /// When false (the default for titles), all newlines (typed, Cmd+Enter, or pasted) are
    /// normalized to spaces so the value stays single-line for Markdown serialization.
    var allowsNewlines: Bool = false
    var onSubmit: (() -> Void)? = nil

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, allowsNewlines: allowsNewlines, onSubmit: onSubmit)
    }

    func makeNSView(context: Context) -> NSTextField {
        let field = NSTextField(string: text)
        field.placeholderString = placeholder
        field.delegate = context.coordinator
        field.isBordered = false
        field.isBezeled = false
        field.drawsBackground = false
        field.backgroundColor = .clear
        field.focusRingType = .none
        field.usesSingleLineMode = false
        field.maximumNumberOfLines = 0
        field.cell?.wraps = true
        field.cell?.isScrollable = false
        field.cell?.lineBreakMode = .byWordWrapping
        field.cell?.usesSingleLineMode = false
        field.font = font
        field.textColor = textColor
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return field
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
        if nsView.placeholderString != placeholder {
            nsView.placeholderString = placeholder
        }
        if nsView.font != font {
            nsView.font = font
        }
        if nsView.textColor != textColor {
            nsView.textColor = textColor
        }
        context.coordinator.allowsNewlines = allowsNewlines
        context.coordinator.onSubmit = onSubmit
    }

    final class Coordinator: NSObject, NSTextFieldDelegate {
        @Binding private var text: String
        var allowsNewlines: Bool
        var onSubmit: (() -> Void)?

        init(text: Binding<String>, allowsNewlines: Bool, onSubmit: (() -> Void)?) {
            _text = text
            self.allowsNewlines = allowsNewlines
            self.onSubmit = onSubmit
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            let raw = field.stringValue
            if !allowsNewlines, raw.contains(where: { $0.isNewline }) {
                let sanitized = Self.flattenNewlines(raw)
                field.stringValue = sanitized
                text = sanitized
            } else {
                text = raw
            }
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                onSubmit?()
                return true
            }
            if commandSelector == #selector(NSResponder.insertNewlineIgnoringFieldEditor(_:)) {
                if allowsNewlines {
                    let range = textView.selectedRange()
                    textView.insertText("\n", replacementRange: range)
                } else {
                    onSubmit?()
                }
                return true
            }
            return false
        }

        private static func flattenNewlines(_ value: String) -> String {
            value
                .replacingOccurrences(of: "\r\n", with: " ")
                .replacingOccurrences(of: "\n", with: " ")
                .replacingOccurrences(of: "\r", with: " ")
        }
    }
}
