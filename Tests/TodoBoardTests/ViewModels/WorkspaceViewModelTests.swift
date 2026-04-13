import Foundation
import Testing
@testable import TodoBoard

@MainActor
struct WorkspaceViewModelTests {
    @Test
    func searchFindsTitleAndContentAcrossProjects() throws {
        let workspace = try TestDirectories.makeTemporaryDirectory()
        let storage = WorkspaceStorage(dataDirectory: workspace)
        let primary = try MarkdownProjectParser.parse(SampleMarkdown.project)
        let secondary = Project(
            id: UUID(),
            name: "个人学习",
            color: "#3498DB",
            archiveGroupBy: .week,
            todos: [
                TodoItem(
                    id: UUID().uuidString.lowercased(),
                    title: "阅读接口设计文章",
                    content: "整理接口设计与错误码策略",
                    isDone: false,
                    doneAt: nil,
                    createdAt: Date(),
                    updatedAt: Date(),
                    tags: ["想法"]
                ),
            ],
            doneTodos: []
        )
        let themeManager = ThemeManager(config: .default)
        let viewModel = WorkspaceViewModel(
            projects: [primary, secondary],
            storage: storage,
            themeManager: themeManager
        )

        viewModel.searchQuery = "接口"

        #expect(viewModel.searchResults.count == 2)
        #expect(viewModel.searchResults.map { $0.project.name } == ["工作任务", "个人学习"])
    }

    @Test
    func moveTodoTransfersItemBetweenProjects() throws {
        let workspace = try TestDirectories.makeTemporaryDirectory()
        let storage = WorkspaceStorage(dataDirectory: workspace)
        let source = try MarkdownProjectParser.parse(SampleMarkdown.project)
        let target = Project(
            id: UUID(),
            name: "副业规划",
            color: "#9B59B6",
            archiveGroupBy: .week,
            todos: [],
            doneTodos: []
        )
        let viewModel = WorkspaceViewModel(
            projects: [source, target],
            storage: storage,
            themeManager: ThemeManager(config: .default)
        )
        let todo = try #require(source.todos.first)

        viewModel.moveTodo(todo, to: target, at: 0)

        #expect(source.todos.count == 2)
        #expect(target.todos.first?.id == todo.id)
        #expect(todo.project?.id == target.id)
    }

    @Test
    func completionRateUsesAllProjects() throws {
        let workspace = try TestDirectories.makeTemporaryDirectory()
        let storage = WorkspaceStorage(dataDirectory: workspace)
        let project = try MarkdownProjectParser.parse(SampleMarkdown.project)
        let viewModel = WorkspaceViewModel(
            projects: [project],
            storage: storage,
            themeManager: ThemeManager(config: .default)
        )

        #expect(viewModel.totalCount == 5)
        #expect(viewModel.todoCount == 3)
        #expect(viewModel.doneCount == 2)
        #expect(abs(viewModel.completionRate - 0.4) < 0.0001)
    }

    @Test
    func reusesProjectColumnViewModelInstances() throws {
        let workspace = try TestDirectories.makeTemporaryDirectory()
        let storage = WorkspaceStorage(dataDirectory: workspace)
        let project = try MarkdownProjectParser.parse(SampleMarkdown.project)
        let viewModel = WorkspaceViewModel(
            projects: [project],
            storage: storage,
            themeManager: ThemeManager(config: .default)
        )

        let first = viewModel.projectColumnViewModel(for: project)
        let second = viewModel.projectColumnViewModel(for: project)

        #expect(first === second)
    }
}
