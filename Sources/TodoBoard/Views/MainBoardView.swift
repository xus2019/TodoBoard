import AppKit
import SwiftUI

struct MainBoardView: View {
    @ObservedObject var viewModel: WorkspaceViewModel
    @ObservedObject var themeManager: ThemeManager

    @State private var showNewProjectSheet = false
    @State private var showQuickInput = false
    @State private var window: NSWindow?
    @State private var errorMessage: String?
    @State private var newProjectDropTargeted = false

    var body: some View {
        ZStack {
            // Full-window background layer (behind everything including toolbar/statusbar)
            backgroundLayer

            // Ambience particles above background, below content
            AmbienceBackgroundView(themeManager: themeManager)

            // Main layout
            VStack(spacing: 0) {
                toolbar
                    .background(WindowDragArea())
                content
                statusBar
            }
            .ignoresSafeArea(.container, edges: .top)

            // Search dropdown floating above everything
            if showSearchDropdown {
                searchDropdownOverlay
            }
        }
        .preferredColorScheme(colorScheme)
        .tint(themeManager.accentColor)
        .background(
            WindowAccessor { resolvedWindow in
                window = resolvedWindow
                configureWindow(resolvedWindow)
            }
        )
        .sheet(isPresented: $showNewProjectSheet) {
            NewProjectSheet { name, color in
                let finalName = name.isEmpty ? "项目 \(viewModel.projects.count + 1)" : name
                viewModel.addProject(name: finalName, color: color)
            }
        }
        .sheet(isPresented: $showQuickInput) {
            QuickInputWindow(
                projects: viewModel.projects,
                availableTags: viewModel.availableTags
            ) { projectId, title, tags in
                viewModel.quickAddTodo(to: projectId, title: title, tags: tags)
            }
        }
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
            window?.makeKeyAndOrderFront(nil)
        }
        .onTapGesture {
            NSApp.activate(ignoringOtherApps: true)
            window?.makeKeyAndOrderFront(nil)
        }
        .alert("操作失败", isPresented: Binding(
            get: { errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    errorMessage = nil
                }
            }
        )) {
            Button("知道了", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var showSearchDropdown: Bool {
        !viewModel.searchQuery.trimmed.isEmpty
    }

    private var toolbar: some View {
        HStack(spacing: 8) {
            Spacer()

            searchFieldWithDropdown

            toolbarButton(icon: "plus.rectangle.on.rectangle", tooltip: "快速添加 Todo") {
                showQuickInput = true
            }
            .keyboardShortcut("t", modifiers: [.command, .shift])

            Divider()
                .frame(height: 16)
                .opacity(0.4)

            toolbarButton(icon: "square.and.arrow.down", tooltip: "导出") {
                exportProjects()
            }

            toolbarButton(icon: "square.and.arrow.up", tooltip: "导入") {
                importProjects()
            }
        }
        .padding(.leading, 76)
        .padding(.trailing, 20)
        .padding(.top, 6)
        .padding(.bottom, 6)
    }

    @ViewBuilder
    private func toolbarButton(icon: String, tooltip: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(themeManager.textSecondary)
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
                .help(tooltip)
                .accessibilityLabel(tooltip)
        }
        .buttonStyle(.plain)
    }

    private var searchFieldWithDropdown: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(themeManager.textSecondary.opacity(0.6))
            TextField("搜索...", text: $viewModel.searchQuery)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
            if !viewModel.searchQuery.isEmpty {
                Button {
                    viewModel.searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(themeManager.textSecondary.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(themeManager.isDark ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    themeManager.isDark ? Color.white.opacity(0.08) : Color.black.opacity(0.06),
                    lineWidth: 0.5
                )
        )
        .frame(maxWidth: 240)
    }

    private var searchDropdownOverlay: some View {
        VStack {
            HStack {
                Spacer()
                searchDropdownPanel
                    .padding(.trailing, 148)
                    .padding(.top, 38)
            }
            Spacer()
        }
        .ignoresSafeArea(.container, edges: .top)
    }

    private var searchDropdownPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            let results = viewModel.searchResults
            Text("找到 \(results.count) 条结果")
                .font(.system(size: 11))
                .foregroundStyle(themeManager.textSecondary.opacity(0.6))
                .padding(.horizontal, 10)
                .padding(.top, 6)

            if results.isEmpty {
                Text("无匹配结果")
                    .font(.system(size: 12))
                    .foregroundStyle(themeManager.textSecondary.opacity(0.5))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(results, id: \.todo.id) { result in
                            SearchDropdownRow(
                                projectName: result.project.name,
                                todoTitle: result.todo.title,
                                isDone: result.todo.isDone,
                                themeManager: themeManager
                            ) {
                                viewModel.highlightTodo(result.todo.id)
                                viewModel.searchQuery = ""
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding(.bottom, 6)
        .frame(idealWidth: 360, maxHeight: 360)
        .fixedSize(horizontal: true, vertical: false)
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    themeManager.isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.08),
                    lineWidth: 0.5
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 16, y: 6)
    }

    private var content: some View {
        HSplitView {
            ScrollViewReader { hProxy in
                ScrollView(.horizontal) {
                    LazyHStack(alignment: .top, spacing: 16) {
                        ForEach(viewModel.projects) { project in
                            ProjectColumnView(
                                viewModel: viewModel.projectColumnViewModel(for: project),
                                workspaceViewModel: viewModel,
                                themeManager: themeManager,
                                availableTags: viewModel.availableTags
                            )
                            .id(project.id)
                        }
                        newProjectColumn
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .background(.clear)
                .onChange(of: viewModel.highlightedTodoId) { _, todoId in
                    guard let todoId else { return }
                    if let project = viewModel.projects.first(where: { p in
                        (p.todos + p.doneTodos).contains(where: { $0.id == todoId })
                    }) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            hProxy.scrollTo(project.id, anchor: .center)
                        }
                    }
                }
            }

            if viewModel.isEditorVisible, let todo = viewModel.selectedTodoForEditor {
                TodoEditorView(
                    viewModel: TodoDetailViewModel(todo: todo, storage: viewModel.storage),
                    themeManager: themeManager
                ) {
                    viewModel.isEditorVisible = false
                }
                .frame(width: 400)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.isEditorVisible)
    }

    private var statusBar: some View {
        StatusBarView(viewModel: viewModel, themeManager: themeManager)
    }

    private var newProjectColumn: some View {
        Button {
            showNewProjectSheet = true
        } label: {
            VStack(spacing: 12) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(themeManager.textSecondary.opacity(0.4))
                Text("新建项目")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(themeManager.textSecondary.opacity(0.4))
            }
            .frame(width: themeManager.columnWidth, height: 120)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 1.5, dash: [8, 6])
                    )
                    .foregroundStyle(
                        newProjectDropTargeted
                            ? themeManager.accentColor
                            : themeManager.textSecondary.opacity(0.15)
                    )
            )
        }
        .buttonStyle(.plain)
        .dropDestination(
            for: ProjectDragData.self,
            action: { items, _ in
                guard let data = items.first,
                      let sourceIdx = viewModel.projects.firstIndex(where: {
                          $0.id.uuidString.lowercased() == data.projectId
                      }),
                      sourceIdx < viewModel.projects.count - 1 else {
                    return false
                }
                viewModel.reorderProjects(from: IndexSet(integer: sourceIdx), to: viewModel.projects.count)
                return true
            },
            isTargeted: { newProjectDropTargeted = $0 }
        )
    }

    private func exportProjects() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "导出"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try viewModel.storage.exportProjects(viewModel.projects, to: url)
        } catch {
            errorMessage = "导出失败：\(error.localizedDescription)"
        }
    }

    private func importProjects() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.plainText]
        panel.allowsMultipleSelection = false
        panel.prompt = "导入"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            let projects = try viewModel.storage.importProjects(from: url)
            viewModel.importProjects(projects)
        } catch {
            errorMessage = "导入失败：\(error.localizedDescription)"
        }
    }

    private var colorScheme: ColorScheme? {
        switch themeManager.appearance {
        case .light:
            .light
        case .dark:
            .dark
        case .system:
            nil
        }
    }

    @ViewBuilder
    private var backgroundLayer: some View {
        ZStack {
            if themeManager.useGlassMaterial {
                VisualEffectBackgroundView(material: .hudWindow, blendingMode: .behindWindow)
                    .ignoresSafeArea()
                themeManager.windowBackground
                    .opacity(themeManager.glassOverlayOpacity)
                    .ignoresSafeArea()
            } else {
                themeManager.windowBackground
                    .ignoresSafeArea()
            }
        }
    }

    private func configureWindow(_ window: NSWindow) {
        window.isOpaque = false
        window.backgroundColor = .clear
        window.titlebarSeparatorStyle = .none
        window.styleMask.insert(.fullSizeContentView)
        window.setFrameAutosaveName("TodoBoardMainWindow")

        // Move traffic light buttons down to vertically align with toolbar
        if let closeButton = window.standardWindowButton(.closeButton),
           let containerView = closeButton.superview {
            // Shift the entire titlebar button container down
            containerView.frame.origin.y -= 4
        }
    }
}

private struct WindowDragArea: NSViewRepresentable {
    func makeNSView(context: Context) -> WindowDragNSView {
        WindowDragNSView()
    }
    func updateNSView(_ nsView: WindowDragNSView, context: Context) {}
}

private class WindowDragNSView: NSView {
    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2 {
            window?.zoom(nil)
        } else {
            window?.performDrag(with: event)
        }
    }
}

private struct SearchDropdownRow: View {
    let projectName: String
    let todoTitle: String
    let isDone: Bool
    let themeManager: ThemeManager
    let onTap: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 6) {
            if isDone {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.green.opacity(0.6))
            }
            Text(projectName)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(themeManager.accentColor)
            Text("/")
                .font(.system(size: 11))
                .foregroundStyle(themeManager.textSecondary.opacity(0.4))
            Text(todoTitle)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(isDone ? themeManager.textDone : themeManager.textPrimary)
                .lineLimit(1)
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovered
                    ? (themeManager.isDark ? Color.white.opacity(0.08) : Color.black.opacity(0.04))
                    : Color.clear)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .onHover { isHovered = $0 }
    }
}
