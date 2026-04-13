import Combine
import Foundation

final class ProjectColumnViewModel: ObservableObject {
    let project: Project
    private let storage: WorkspaceStorage
    private let now: () -> Date
    private var cancellables: Set<AnyCancellable> = []

    init(project: Project, storage: WorkspaceStorage, now: @escaping () -> Date = Date.init) {
        self.project = project
        self.storage = storage
        self.now = now
        bindProjectChanges()
    }

    func addTodo(title: String) {
        let todo = TodoItem(
            id: UUID().uuidString.lowercased(),
            title: title.trimmed,
            content: "",
            isDone: false,
            doneAt: nil,
            createdAt: now(),
            updatedAt: now(),
            tags: []
        )
        todo.project = project
        project.todos.insert(todo, at: 0)
        storage.saveProject(project)
    }

    func deleteTodo(_ todo: TodoItem) {
        project.todos.removeAll { $0.id == todo.id }
        project.doneTodos.removeAll { $0.id == todo.id }
        storage.saveProject(project)
    }

    func updateTodoTitle(_ todo: TodoItem, newTitle: String) {
        todo.title = newTitle.trimmed
        todo.updatedAt = now()
        storage.saveProject(project)
    }

    func toggleDone(_ todo: TodoItem) {
        if todo.isDone {
            project.doneTodos.removeAll { $0.id == todo.id }
            todo.isDone = false
            todo.doneAt = nil
            todo.updatedAt = now()
            project.todos.insert(todo, at: 0)
        } else {
            project.todos.removeAll { $0.id == todo.id }
            todo.isDone = true
            todo.doneAt = now()
            todo.updatedAt = now()
            project.doneTodos.insert(todo, at: 0)
            project.doneTodos.sort { ($0.doneAt ?? .distantPast) > ($1.doneAt ?? .distantPast) }
        }

        storage.saveProject(project)
    }

    func reorderTodos(from source: IndexSet, to destination: Int) {
        project.todos.move(fromOffsets: source, toOffset: destination)
        storage.saveProject(project)
    }

    func addTag(_ tag: String, to todo: TodoItem) {
        guard !todo.tags.contains(tag) else { return }
        todo.tags.append(tag)
        todo.updatedAt = now()
        storage.saveProject(project)
    }

    func removeTag(_ tag: String, from todo: TodoItem) {
        todo.tags.removeAll { $0 == tag }
        todo.updatedAt = now()
        storage.saveProject(project)
    }

    func updateIcon(_ icon: String) {
        project.icon = icon
        storage.saveProject(project)
    }

    func saveTodo(_ todo: TodoItem) {
        todo.updatedAt = now()
        storage.saveProject(project)
    }

    func setArchiveGroupBy(_ mode: ArchiveGroupBy) {
        project.archiveGroupBy = mode
        storage.saveProject(project)
    }

    func groupedDoneTodos() -> [ArchiveGroup] {
        let sorted = project.doneTodos.sorted { ($0.doneAt ?? .distantPast) > ($1.doneAt ?? .distantPast) }
        switch project.archiveGroupBy {
        case .all:
            return [
                ArchiveGroup(id: "all", title: "全部", todos: sorted, isExpanded: true),
            ]
        case .week:
            return makeGroups(from: sorted) { todo in
                guard let doneAt = todo.doneAt else { return ("unknown", "未知") }
                let title = DateFormatters.weekRange(for: doneAt)
                guard let interval = DateFormatters.calendar.dateInterval(of: .weekOfYear, for: doneAt) else {
                    return ("unknown", title)
                }
                return ("\(DateFormatters.iso8601(for: interval.start))", title)
            }
        case .month:
            return makeGroups(from: sorted) { todo in
                guard let doneAt = todo.doneAt else { return ("unknown", "未知") }
                let title = DateFormatters.monthTitle(for: doneAt)
                let year = DateFormatters.calendar.component(.year, from: doneAt)
                let month = DateFormatters.calendar.component(.month, from: doneAt)
                return ("\(year)-\(month)", title)
            }
        }
    }

    private func makeGroups(
        from todos: [TodoItem],
        keyBuilder: (TodoItem) -> (id: String, title: String)
    ) -> [ArchiveGroup] {
        var grouped: [(id: String, title: String, todos: [TodoItem])] = []
        for todo in todos {
            let key = keyBuilder(todo)
            if let index = grouped.firstIndex(where: { $0.id == key.id }) {
                grouped[index].todos.append(todo)
            } else {
                grouped.append((key.id, key.title, [todo]))
            }
        }

        return grouped.enumerated().map { index, group in
            let countedTitle = group.title.isEmpty ? group.title : "\(group.title) (\(group.todos.count))"
            return ArchiveGroup(id: group.id, title: countedTitle, todos: group.todos, isExpanded: index == 0)
        }
    }

    private func bindProjectChanges() {
        project.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}
