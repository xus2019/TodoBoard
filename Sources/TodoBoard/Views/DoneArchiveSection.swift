import SwiftUI

struct DoneArchiveSection: View {
    let groups: [ArchiveGroup]
    let themeManager: ThemeManager
    let onToggleDone: (TodoItem) -> Void
    let onOpenEditor: (TodoItem) -> Void
    let onSave: (TodoItem) -> Void
    var highlightedTodoId: String?
    @State private var expandedGroupIDs: Set<String> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(groups) { group in
                DisclosureGroup(
                    group.title.isEmpty ? "已完成" : group.title,
                    isExpanded: binding(for: group)
                ) {
                    VStack(spacing: 8) {
                        ForEach(group.todos) { todo in
                            DoneTodoCardView(
                                todo: todo,
                                themeManager: themeManager,
                                onToggleDone: { onToggleDone(todo) },
                                onOpenEditor: { onOpenEditor(todo) },
                                onSave: { onSave(todo) },
                                isHighlighted: highlightedTodoId == todo.id
                            )
                            .id(todo.id)
                        }
                    }
                    .padding(.top, 8)
                }
                .disclosureGroupStyle(.automatic)
            }
        }
        .onAppear {
            resetExpandedGroups()
        }
        .onChange(of: groups.map(\.id)) { _, _ in
            resetExpandedGroups()
        }
        .onChange(of: highlightedTodoId) { _, todoId in
            guard let todoId else { return }
            for group in groups where group.todos.contains(where: { $0.id == todoId }) {
                expandedGroupIDs.insert(group.id)
            }
        }
    }

    private func binding(for group: ArchiveGroup) -> Binding<Bool> {
        Binding(
            get: { expandedGroupIDs.contains(group.id) },
            set: { isExpanded in
                if isExpanded {
                    expandedGroupIDs.insert(group.id)
                } else {
                    expandedGroupIDs.remove(group.id)
                }
            }
        )
    }

    private func resetExpandedGroups() {
        expandedGroupIDs = Set(groups.filter(\.isExpanded).map(\.id))
    }
}
