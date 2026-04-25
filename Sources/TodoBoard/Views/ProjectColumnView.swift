import SwiftUI

struct ProjectColumnView: View {
    @ObservedObject var viewModel: ProjectColumnViewModel
    @ObservedObject var workspaceViewModel: WorkspaceViewModel
    @ObservedObject var themeManager: ThemeManager
    let availableTags: [TagDefinition]

    @State private var newTodoTitle = ""
    @State private var isRenaming = false
    @State private var draftName = ""
    @State private var dropTargeted = false
    @State private var projectDropTargeted = false
    @State private var isHeaderHovered = false
    @State private var showDeleteConfirmation = false
    @State private var showIconPicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            Divider()
                .opacity(0.3)
                .padding(.horizontal, -4)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.project.todos) { todo in
                            todoCard(for: todo)
                                .id(todo.id)
                        }

                        NewTodoField(title: $newTodoTitle) {
                            guard !newTodoTitle.trimmed.isEmpty else { return }
                            viewModel.addTodo(title: newTodoTitle)
                            newTodoTitle = ""
                        }

                        // Done section header with archive tabs
                        Divider()
                            .opacity(0.3)
                            .padding(.top, 12)

                        HStack(spacing: 8) {
                            Text("已完成")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(themeManager.textSecondary.opacity(0.7))
                            Text("\(viewModel.project.doneCount)")
                                .font(.system(size: 10))
                                .foregroundStyle(themeManager.textSecondary.opacity(0.5))

                            Spacer()

                            archiveGroupTabs
                        }
                        .padding(.top, 4)

                        DoneArchiveSection(
                            groups: viewModel.groupedDoneTodos(),
                            themeManager: themeManager,
                            onToggleDone: { todo in viewModel.toggleDone(todo) },
                            onOpenEditor: { todo in
                                workspaceViewModel.selectedTodoForEditor = todo
                                workspaceViewModel.isEditorVisible = true
                            },
                            onSave: { todo in viewModel.saveTodo(todo) },
                            highlightedTodoId: workspaceViewModel.highlightedTodoId
                        )
                    }
                }
                .scrollIndicators(.hidden)
                .onChange(of: workspaceViewModel.highlightedTodoId) { _, newValue in
                    guard let todoId = newValue,
                          (viewModel.project.todos + viewModel.project.doneTodos).contains(where: { $0.id == todoId }) else { return }
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(todoId, anchor: .center)
                    }
                }
            }
        }
        .padding(16)
        .frame(width: themeManager.columnWidth)
        .background { columnBackgroundView }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    (dropTargeted || projectDropTargeted)
                        ? Color.accentColor
                        : (themeManager.isDark ? Color.white.opacity(0.04) : Color.black.opacity(0.04)),
                    lineWidth: (dropTargeted || projectDropTargeted) ? 2 : 0.5
                )
        )
        .shadow(
            color: themeManager.cardStyle == .shadow ? .black.opacity(0.12) : .clear,
            radius: themeManager.cardStyle == .shadow ? 18 : 0,
            y: themeManager.cardStyle == .shadow ? 6 : 0
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .alert("确认删除项目「\(viewModel.project.name)」？", isPresented: $showDeleteConfirmation) {
            Button("删除", role: .destructive) {
                workspaceViewModel.deleteProject(viewModel.project)
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("该项目对应的 Markdown 文件也会被删除。")
        }
        .dropDestination(
            for: TodoDragData.self,
            action: { items, _ in
                guard let data = items.first else { return false }
                return handleColumnDrop(data)
            },
            isTargeted: { isTargeted in
                dropTargeted = isTargeted
            }
        )
        .dropDestination(
            for: ProjectDragData.self,
            action: { items, _ in
                guard let data = items.first else { return false }
                return handleProjectDrop(data)
            },
            isTargeted: { isTargeted in
                projectDropTargeted = isTargeted
            }
        )
    }

    @ViewBuilder
    private var columnBackgroundView: some View {
        if themeManager.useGlassMaterial {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(themeManager.columnBackground.opacity(themeManager.glassOverlayOpacity))
                )
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.columnBackground)
        }
    }

    private var archiveGroupTabs: some View {
        HStack(spacing: 0) {
            archiveTab("按周", mode: .week)
            archiveTab("按月", mode: .month)
            archiveTab("全部", mode: .all)
        }
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(themeManager.isDark ? Color.white.opacity(0.04) : Color.black.opacity(0.04))
        )
    }

    private func archiveTab(_ title: String, mode: ArchiveGroupBy) -> some View {
        let isSelected = viewModel.project.archiveGroupBy == mode
        return Button {
            viewModel.setArchiveGroupBy(mode)
        } label: {
            Text(title)
                .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? themeManager.textPrimary : themeManager.textSecondary.opacity(0.7))
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(isSelected ? (themeManager.isDark ? Color.white.opacity(0.1) : Color.white.opacity(0.8)) : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }

    private var header: some View {
        HStack(spacing: 6) {
            dragHandle

            // Project icon: colored circle with SF Symbol
            Button {
                showIconPicker = true
            } label: {
                projectIcon
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showIconPicker) {
                IconPickerView(currentIcon: viewModel.project.icon) { newIcon in
                    viewModel.updateIcon(newIcon)
                }
            }

            if isRenaming {
                TextField("项目名", text: $draftName)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        commitRename()
                    }
            } else {
                Text(viewModel.project.name)
                    .font(themeManager.font(size: themeManager.fontSize + 2, weight: .semibold))
                    .onTapGesture(count: 2) {
                        draftName = viewModel.project.name
                        isRenaming = true
                    }
            }

            Spacer()

            Text("\(viewModel.project.todoCount) 项待办")
                .font(.system(size: 11))
                .foregroundStyle(themeManager.textSecondary.opacity(0.7))

            Menu {
                Button("重命名") {
                    draftName = viewModel.project.name
                    isRenaming = true
                }
                Button("删除", role: .destructive) {
                    showDeleteConfirmation = true
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(themeManager.textSecondary)
                    .frame(width: 20, height: 20)
                    .contentShape(Rectangle())
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .frame(width: 20)
            .opacity(isHeaderHovered ? 1 : 0.3)
        }
        .contentShape(Rectangle())
        .onHover { isHeaderHovered = $0 }
    }

    private var dragHandle: some View {
        Image(systemName: "line.3.horizontal")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(themeManager.textSecondary.opacity(isHeaderHovered ? 0.7 : 0.25))
            .frame(width: 16, height: 20)
            .contentShape(Rectangle())
            .help("拖动以重新排序列")
            .onHover { hovering in
                if hovering {
                    NSCursor.openHand.push()
                } else {
                    NSCursor.pop()
                }
            }
            .draggable(ProjectDragData(projectId: viewModel.project.id.uuidString.lowercased())) {
                HStack(spacing: 6) {
                    projectIcon
                    Text(viewModel.project.name)
                        .font(themeManager.font(size: themeManager.fontSize, weight: .semibold))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                )
            }
    }

    private var projectIcon: some View {
        ZStack {
            Circle()
                .fill(Color(hex: viewModel.project.color))
                .frame(width: 26, height: 26)
            Image(systemName: viewModel.project.icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private func commitRename() {
        let name = draftName.trimmed
        guard !name.isEmpty else {
            isRenaming = false
            return
        }
        workspaceViewModel.renameProject(viewModel.project, to: name)
        isRenaming = false
    }

    private func reorderTodo(_ data: TodoDragData, before target: TodoItem) -> Bool {
        guard data.sourceProjectId == viewModel.project.id.uuidString.lowercased() else {
            return false
        }
        guard
            let fromIndex = viewModel.project.todos.firstIndex(where: { $0.id == data.todoId }),
            let targetIndex = viewModel.project.todos.firstIndex(where: { $0.id == target.id })
        else {
            return false
        }
        if fromIndex == targetIndex {
            return false
        }
        viewModel.reorderTodos(from: IndexSet(integer: fromIndex), to: targetIndex > fromIndex ? targetIndex + 1 : targetIndex)
        return true
    }

    private func handleColumnDrop(_ data: TodoDragData) -> Bool {
        guard let todo = workspaceViewModel.todo(sourceProjectId: data.sourceProjectId, todoId: data.todoId) else {
            return false
        }
        if data.sourceProjectId == viewModel.project.id.uuidString.lowercased() {
            return false
        }
        workspaceViewModel.moveTodo(todo, to: viewModel.project, at: 0)
        return true
    }

    private func handleProjectDrop(_ data: ProjectDragData) -> Bool {
        guard let sourceIdx = workspaceViewModel.projects.firstIndex(where: {
            $0.id.uuidString.lowercased() == data.projectId
        }),
        let targetIdx = workspaceViewModel.projects.firstIndex(where: {
            $0.id == viewModel.project.id
        }),
        sourceIdx != targetIdx else {
            return false
        }
        let destination = sourceIdx < targetIdx ? targetIdx + 1 : targetIdx
        workspaceViewModel.reorderProjects(from: IndexSet(integer: sourceIdx), to: destination)
        return true
    }

    private func todoCard(for todo: TodoItem) -> some View {
        TodoCardView(
            todo: todo,
            themeManager: themeManager,
            onToggleDone: {
                viewModel.toggleDone(todo)
            },
            onSave: {
                viewModel.saveTodo(todo)
            },
            availableTags: availableTags,
            onToggleTag: { tag in
                if todo.tags.contains(tag) {
                    viewModel.removeTag(tag, from: todo)
                } else {
                    viewModel.addTag(tag, to: todo)
                }
            },
            isHighlighted: workspaceViewModel.highlightedTodoId == todo.id
        )
        .dropDestination(for: TodoDragData.self) { items, _ in
            guard let data = items.first else { return false }
            return reorderTodo(data, before: todo)
        }
    }
}
