import SwiftUI

struct QuickInputWindow: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var selectedProjectId: UUID?
    @State private var selectedTags: Set<String> = []

    let projects: [Project]
    let availableTags: [TagDefinition]
    let onSubmit: (UUID, String, [String]) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("快速添加 Todo")
                .font(.title3.bold())

            NativeTextField(
                placeholder: "标题",
                text: $title,
                becomesFirstResponder: true,
                onSubmit: submit
            )
            .frame(height: 22)

            Picker("项目", selection: Binding(
                get: { selectedProjectId ?? projects.first?.id },
                set: { selectedProjectId = $0 }
            )) {
                ForEach(projects) { project in
                    Text(project.name).tag(Optional(project.id))
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("标签")
                FlowTagSelection(tags: availableTags, selectedTags: $selectedTags)
            }

            HStack {
                Spacer()
                Button("取消") {
                    dismiss()
                }
                Button("添加") {
                    guard let projectId = selectedProjectId ?? projects.first?.id else { return }
                    onSubmit(projectId, title.trimmed, Array(selectedTags))
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.trimmed.isEmpty || projects.isEmpty)
            }
        }
        .padding()
        .frame(width: 420)
        .onAppear {
            selectedProjectId = selectedProjectId ?? projects.first?.id
        }
    }

    private func submit() {
        guard let projectId = selectedProjectId ?? projects.first?.id else { return }
        guard !title.trimmed.isEmpty else { return }
        onSubmit(projectId, title.trimmed, Array(selectedTags))
        dismiss()
    }
}

private struct FlowTagSelection: View {
    let tags: [TagDefinition]
    @Binding var selectedTags: Set<String>

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 88), spacing: 8)], spacing: 8) {
            ForEach(tags) { tag in
                Button {
                    if selectedTags.contains(tag.name) {
                        selectedTags.remove(tag.name)
                    } else {
                        selectedTags.insert(tag.name)
                    }
                } label: {
                    TagBadgeView(tag: tag, showRemove: false)
                        .overlay(
                            Capsule()
                                .stroke(selectedTags.contains(tag.name) ? Color.accentColor : Color.clear, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
