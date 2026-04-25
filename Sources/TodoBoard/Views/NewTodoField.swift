import AppKit
import SwiftUI

struct NewTodoField: View {
    @Binding var title: String
    let onSubmit: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "plus")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary.opacity(0.5))
                .padding(.top, 2)
            WrappingTitleField(
                placeholder: "添加新任务...",
                text: $title,
                font: .systemFont(ofSize: 13),
                textColor: .labelColor,
                onSubmit: onSubmit
            )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.primary.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.5)
        )
    }
}
