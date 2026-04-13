import SwiftUI

struct TagPickerView: View {
    @Environment(\.dismiss) private var dismiss

    let availableTags: [TagDefinition]
    let selected: Set<String>
    let onToggle: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("管理标签")
                .font(.headline)

            List(availableTags) { tag in
                Button {
                    onToggle(tag.name)
                } label: {
                    HStack {
                        TagBadgeView(tag: tag, showRemove: false)
                        Spacer()
                        if selected.contains(tag.name) {
                            Image(systemName: "checkmark")
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            HStack {
                Spacer()
                Button("完成") {
                    dismiss()
                }
            }
        }
        .padding()
        .frame(width: 320, height: 360)
    }
}
