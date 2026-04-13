import Combine
import Foundation
import Testing
@testable import TodoBoard

struct ProjectColumnViewModelTests {
    @Test
    func toggleDoneMovesTodoIntoDoneSection() throws {
        let workspace = try TestDirectories.makeTemporaryDirectory()
        let storage = WorkspaceStorage(dataDirectory: workspace)
        let project = try MarkdownProjectParser.parse(SampleMarkdown.project)
        let fixedNow = try #require(DateFormatters.fromISO8601("2024-03-20T08:00:00Z"))
        let viewModel = ProjectColumnViewModel(project: project, storage: storage, now: { fixedNow })
        let todo = try #require(project.todos.first)

        viewModel.toggleDone(todo)

        #expect(!project.doneTodos.isEmpty)
        #expect(project.doneTodos.first?.id == todo.id)
        #expect(project.doneTodos.first?.doneAt == fixedNow)
        #expect(project.todos.count == 2)
    }

    @Test
    func toggleDoneOnDoneTodoMovesBackToTop() throws {
        let workspace = try TestDirectories.makeTemporaryDirectory()
        let storage = WorkspaceStorage(dataDirectory: workspace)
        let project = try MarkdownProjectParser.parse(SampleMarkdown.project)
        let viewModel = ProjectColumnViewModel(project: project, storage: storage, now: Date.init)
        let todo = try #require(project.doneTodos.first)

        viewModel.toggleDone(todo)

        #expect(project.todos.first?.id == todo.id)
        #expect(project.todos.first?.doneAt == nil)
        #expect(project.doneTodos.count == 1)
    }

    @Test
    func groupedDoneTodosRespectsWeekMode() throws {
        let workspace = try TestDirectories.makeTemporaryDirectory()
        let storage = WorkspaceStorage(dataDirectory: workspace)
        let project = try MarkdownProjectParser.parse(SampleMarkdown.project)
        let viewModel = ProjectColumnViewModel(project: project, storage: storage, now: Date.init)

        let groups = viewModel.groupedDoneTodos()

        #expect(groups.count == 2)
        #expect(groups.first?.title == "3月10日 - 3月16日 (2024) (1)")
        #expect(groups.first?.todos.count == 1)
        #expect(groups.first?.isExpanded == true)
        #expect(groups.last?.isExpanded == false)
    }

    @Test
    func groupedDoneTodosIncludeCountInTitles() throws {
        let workspace = try TestDirectories.makeTemporaryDirectory()
        let storage = WorkspaceStorage(dataDirectory: workspace)
        let project = try MarkdownProjectParser.parse(SampleMarkdown.project)
        project.archiveGroupBy = .week
        let viewModel = ProjectColumnViewModel(project: project, storage: storage, now: Date.init)

        let weekGroups = viewModel.groupedDoneTodos()

        #expect(weekGroups.first?.title == "3月10日 - 3月16日 (2024) (1)")

        project.archiveGroupBy = .month
        let monthGroups = viewModel.groupedDoneTodos()
        #expect(monthGroups.first?.title == "2024年3月 (2)")
    }

    @Test
    func addTodoPersistsToProjectFile() throws {
        let workspace = try TestDirectories.makeTemporaryDirectory()
        let storage = WorkspaceStorage(dataDirectory: workspace)
        let project = storage.createProject(name: "工作任务")
        let viewModel = ProjectColumnViewModel(project: project, storage: storage, now: Date.init)

        viewModel.addTodo(title: "补一条待办")
        storage.saveProjectImmediately(project)

        let saved = try storage.loadProject(from: workspace.appendingPathComponent("工作任务.md"))
        #expect(saved.todos.first?.title == "补一条待办")
    }

    @Test
    func addTodoPublishesObjectWillChange() throws {
        let workspace = try TestDirectories.makeTemporaryDirectory()
        let storage = WorkspaceStorage(dataDirectory: workspace)
        let project = storage.createProject(name: "工作任务")
        let viewModel = ProjectColumnViewModel(project: project, storage: storage, now: Date.init)
        var changeCount = 0
        let cancellable = viewModel.objectWillChange.sink {
            changeCount += 1
        }

        withExtendedLifetime(cancellable) {
            viewModel.addTodo(title: "应该刷新界面")
        }

        #expect(changeCount > 0)
    }
}
