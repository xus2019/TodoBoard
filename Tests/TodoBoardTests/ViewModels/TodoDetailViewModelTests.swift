import Foundation
import Testing
@testable import TodoBoard

@MainActor
struct TodoDetailViewModelTests {
    @Test
    func autoSavePersistsEditsWithoutExplicitSave() async throws {
        let workspace = try TestDirectories.makeTemporaryDirectory()
        let storage = WorkspaceStorage(dataDirectory: workspace)
        let project = storage.createProject(name: "工作任务")
        let todo = TodoItem(
            id: UUID().uuidString.lowercased(),
            title: "原始标题",
            content: "原始内容",
            isDone: false,
            doneAt: nil,
            createdAt: Date(),
            updatedAt: Date(),
            tags: ["等待"]
        )
        todo.project = project
        project.todos = [todo]
        storage.saveProjectImmediately(project)

        let viewModel = TodoDetailViewModel(todo: todo, storage: storage)
        viewModel.title = "更新后的标题"
        viewModel.content = "补充说明"
        viewModel.tags = ["重要", "紧急"]

        try await Task.sleep(for: .milliseconds(800))

        let saved = try storage.loadProject(from: workspace.appendingPathComponent("工作任务.md"))
        let savedTodo = try #require(saved.todos.first)
        #expect(savedTodo.title == "更新后的标题")
        #expect(savedTodo.content == "补充说明")
        #expect(savedTodo.tags == ["重要", "紧急"])
    }

    @Test
    func autoSaveWaitsHalfSecondBeforePersisting() async throws {
        let workspace = try TestDirectories.makeTemporaryDirectory()
        let storage = WorkspaceStorage(dataDirectory: workspace)
        let project = storage.createProject(name: "工作任务")
        let todo = TodoItem(
            id: UUID().uuidString.lowercased(),
            title: "原始标题",
            content: "原始内容",
            isDone: false,
            doneAt: nil,
            createdAt: Date(),
            updatedAt: Date(),
            tags: []
        )
        todo.project = project
        project.todos = [todo]
        storage.saveProjectImmediately(project)

        let viewModel = TodoDetailViewModel(todo: todo, storage: storage)
        viewModel.title = "500ms 后保存"

        try await Task.sleep(for: .milliseconds(300))
        let earlySaved = try storage.loadProject(from: workspace.appendingPathComponent("工作任务.md"))
        #expect(earlySaved.todos.first?.title == "原始标题")

        try await Task.sleep(for: .milliseconds(400))
        let finalSaved = try storage.loadProject(from: workspace.appendingPathComponent("工作任务.md"))
        #expect(finalSaved.todos.first?.title == "500ms 后保存")
    }
}
