import SwiftUI

struct TodoEditorView: View {
    @ObservedObject var viewModel: TodoDetailViewModel
    @ObservedObject var themeManager: ThemeManager
    @State private var showTagPicker = false
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Spacer()
                Button("关闭", action: onClose)
            }

            TextField("标题", text: $viewModel.title)
                .textFieldStyle(.roundedBorder)

            HStack {
                ForEach(viewModel.tags, id: \.self) { tag in
                    TagBadgeView(
                        tag: TagDefinition(name: tag, color: themeManager.tagColor(for: tag).hexString ?? "#4A90D9"),
                        showRemove: true
                    )
                    .onTapGesture {
                        viewModel.tags.removeAll { $0 == tag }
                    }
                }
                Button {
                    showTagPicker = true
                } label: {
                    Label("添加标签", systemImage: "plus.circle")
                }
                .buttonStyle(.plain)
            }

            Picker("模式", selection: $viewModel.editorMode) {
                Text("编辑").tag(EditorMode.edit)
                Text("预览").tag(EditorMode.preview)
                Text("分栏").tag(EditorMode.split)
            }
            .pickerStyle(.segmented)

            Group {
                switch viewModel.editorMode {
                case .edit:
                    MarkdownTextEditor(text: $viewModel.content)
                case .preview:
                    MarkdownPreviewView(content: viewModel.content)
                case .split:
                    HSplitView {
                        MarkdownTextEditor(text: $viewModel.content)
                        MarkdownPreviewView(content: viewModel.content)
                    }
                }
            }
            .frame(maxHeight: .infinity)

            Button("保存") {
                viewModel.save()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background {
            if themeManager.useGlassMaterial {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(themeManager.columnBackground.opacity(max(0.08, themeManager.materialOpacity * 0.35)))
                    )
            } else {
                RoundedRectangle(cornerRadius: 14)
                    .fill(themeManager.columnBackground.opacity(themeManager.materialOpacity))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .onDisappear {
            viewModel.save()
        }
        .sheet(isPresented: $showTagPicker) {
            TagPickerView(
                availableTags: themeManager.config.tagColors
                    .map { TagDefinition(name: $0.key, color: $0.value) }
                    .sorted { $0.name < $1.name },
                selected: Set(viewModel.tags)
            ) { tag in
                if viewModel.tags.contains(tag) {
                    viewModel.tags.removeAll { $0 == tag }
                } else {
                    viewModel.tags.append(tag)
                }
            }
        }
    }
}
