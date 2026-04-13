import Combine
import Foundation

@MainActor
final class WorkspaceViewModel: ObservableObject {
    @Published var projects: [Project]
    @Published var selectedTodoForEditor: TodoItem?
    @Published var isEditorVisible = false
    @Published var searchQuery = ""
    @Published var isSearching = false
    @Published var highlightedTodoId: String?
    @Published private(set) var appConfig: AppConfig

    let storage: WorkspaceStorage
    let themeManager: ThemeManager
    private var projectColumnViewModels: [UUID: ProjectColumnViewModel] = [:]
    private var projectCancellables: [UUID: AnyCancellable] = [:]

    init(
        projects: [Project]? = nil,
        storage: WorkspaceStorage,
        themeManager: ThemeManager
    ) {
        self.storage = storage
        self.themeManager = themeManager
        self.appConfig = storage.loadConfig()
        self.projects = projects ?? storage.loadAllProjects()
        storage.onProjectChanged = { [weak self] updatedProject in
            guard let self else { return }
            if let index = self.projects.firstIndex(where: { $0.id == updatedProject.id }) {
                self.projects[index] = updatedProject
            } else {
                self.projects.append(updatedProject)
            }
            self.projectColumnViewModels[updatedProject.id] = nil
            self.subscribeToProjects()
            self.appConfig = self.storage.loadConfig()
        }
        subscribeToProjects()
    }

    private func subscribeToProjects() {
        projectCancellables.removeAll()
        for project in projects {
            projectCancellables[project.id] = project.objectWillChange
                .sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
        }
    }

    func addProject(name: String, color: String? = nil) {
        let project = storage.createProject(name: name, color: color)
        projects.append(project)
        subscribeToProjects()
        appConfig = storage.loadConfig()
    }

    func deleteProject(_ project: Project) {
        projects.removeAll { $0.id == project.id }
        projectColumnViewModels[project.id] = nil
        projectCancellables[project.id] = nil
        storage.deleteProject(project)
        appConfig = storage.loadConfig()
    }

    func renameProject(_ project: Project, to newName: String) {
        storage.renameProject(project, to: newName)
        projectColumnViewModels[project.id] = nil
    }

    func reorderProjects(from source: IndexSet, to destination: Int) {
        projects.move(fromOffsets: source, toOffset: destination)
        var config = storage.loadConfig()
        config.projectOrder = projects.map { $0.id.uuidString.lowercased() }
        storage.saveConfig(config)
        appConfig = config
    }

    func moveTodo(_ todo: TodoItem, to targetProject: Project, at index: Int?) {
        guard let sourceProject = todo.project else { return }
        sourceProject.todos.removeAll { $0.id == todo.id }
        sourceProject.doneTodos.removeAll { $0.id == todo.id }

        let insertionIndex = min(index ?? targetProject.todos.count, targetProject.todos.count)
        todo.project = targetProject
        todo.updatedAt = Date()
        targetProject.todos.insert(todo, at: insertionIndex)

        storage.saveProject(sourceProject)
        storage.saveProject(targetProject)
    }

    func copyTodo(_ todo: TodoItem, to targetProject: Project) {
        let duplicate = todo.duplicate()
        duplicate.project = targetProject
        targetProject.todos.insert(duplicate, at: 0)
        storage.saveProject(targetProject)
    }

    func todo(sourceProjectId: String, todoId: String) -> TodoItem? {
        guard let project = projects.first(where: { $0.id.uuidString.lowercased() == sourceProjectId }) else {
            return nil
        }
        return (project.todos + project.doneTodos).first(where: { $0.id == todoId })
    }

    func quickAddTodo(to projectId: UUID, title: String, tags: [String]) {
        guard let project = projects.first(where: { $0.id == projectId }) else { return }
        let todo = TodoItem(
            id: UUID().uuidString.lowercased(),
            title: title.trimmed,
            content: "",
            isDone: false,
            doneAt: nil,
            createdAt: Date(),
            updatedAt: Date(),
            tags: tags
        )
        todo.project = project
        project.todos.insert(todo, at: 0)
        storage.saveProject(project)
    }

    func highlightTodo(_ todoId: String) {
        highlightedTodoId = todoId
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            if self?.highlightedTodoId == todoId {
                self?.highlightedTodoId = nil
            }
        }
    }

    func importProjects(_ importedProjects: [Project]) {
        storage.persistImportedProjects(importedProjects)
        projects = storage.loadAllProjects()
        appConfig = storage.loadConfig()
        projectColumnViewModels.removeAll()
        subscribeToProjects()
    }

    func updateAppConfig(_ config: AppConfig) {
        appConfig = config
    }

    func projectColumnViewModel(for project: Project) -> ProjectColumnViewModel {
        if let existing = projectColumnViewModels[project.id] {
            return existing
        }
        let created = ProjectColumnViewModel(project: project, storage: storage)
        projectColumnViewModels[project.id] = created
        return created
    }

    var availableTags: [TagDefinition] {
        appConfig.tagColors
            .map { TagDefinition(name: $0.key, color: $0.value) }
            .sorted { $0.name < $1.name }
    }

    var searchResults: [(project: Project, todo: TodoItem)] {
        let query = searchQuery.trimmed
        guard !query.isEmpty else { return [] }

        return projects.flatMap { project in
            (project.todos + project.doneTodos)
                .filter { item in
                    item.title.localizedCaseInsensitiveContains(query) ||
                        item.content.localizedCaseInsensitiveContains(query)
                }
                .map { (project: project, todo: $0) }
        }
    }

    var totalCount: Int {
        projects.reduce(0) { $0 + $1.totalCount }
    }

    var todoCount: Int {
        projects.reduce(0) { $0 + $1.todoCount }
    }

    var doneCount: Int {
        projects.reduce(0) { $0 + $1.doneCount }
    }

    var completionRate: Double {
        guard totalCount > 0 else { return 0 }
        return Double(doneCount) / Double(totalCount)
    }
}
