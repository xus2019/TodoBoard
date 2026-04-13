import SwiftUI

struct SearchOverlayView: View {
    @ObservedObject var viewModel: WorkspaceViewModel
    @ObservedObject var themeManager: ThemeManager

    var body: some View {
        ZStack {
            // Backdrop dimming
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.isSearching = false
                }

            searchPanel
        }
    }

    private var searchPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            searchHeader

            Text("共找到 \(viewModel.searchResults.count) 条结果")
                .font(.system(size: 12))
                .foregroundStyle(themeManager.textSecondary.opacity(0.7))

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.searchResults, id: \.todo.id) { result in
                        searchResultRow(project: result.project, todo: result.todo)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: 640, maxHeight: 420)
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.3), radius: 30, y: 10)
    }

    private var searchHeader: some View {
        HStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(themeManager.textSecondary.opacity(0.6))
                TextField("搜索关键词...", text: $viewModel.searchQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(themeManager.isDark ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
            )

            Button {
                viewModel.isSearching = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(themeManager.textSecondary.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
    }

    private func searchResultRow(project: Project, todo: TodoItem) -> some View {
        SearchResultCardView(
            projectName: project.name,
            todoTitle: todo.title,
            todoContent: todo.hasContent ? todo.content : nil,
            themeManager: themeManager
        ) {
            viewModel.highlightTodo(todo.id)
            viewModel.isSearching = false
        }
    }
}

private struct SearchResultCardView: View {
    let projectName: String
    let todoTitle: String
    let todoContent: String?
    let themeManager: ThemeManager
    let onTap: () -> Void

    @State private var isHovered = false

    private var bgColor: Color {
        if isHovered {
            return themeManager.isDark ? Color.white.opacity(0.08) : Color.black.opacity(0.04)
        }
        return themeManager.isDark ? Color.white.opacity(0.04) : Color.black.opacity(0.02)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            resultHeader
            resultContent
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 8).fill(bgColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onTapGesture(perform: onTap)
        .onHover { isHovered = $0 }
        .animation(.easeOut(duration: 0.12), value: isHovered)
    }

    private var resultHeader: some View {
        HStack(spacing: 6) {
            Text(projectName)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(themeManager.accentColor)
            Text("/")
                .font(.system(size: 11))
                .foregroundStyle(themeManager.textSecondary.opacity(0.4))
            Text(todoTitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(themeManager.textPrimary)
        }
    }

    @ViewBuilder
    private var resultContent: some View {
        if let content = todoContent {
            Text(content)
                .lineLimit(2)
                .font(.system(size: 12))
                .foregroundStyle(themeManager.textSecondary)
        }
    }
}
