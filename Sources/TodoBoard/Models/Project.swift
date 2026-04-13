import Combine
import Foundation

final class Project: ObservableObject, Identifiable, Hashable {
    let id: UUID
    @Published var name: String
    @Published var color: String
    @Published var icon: String
    @Published var archiveGroupBy: ArchiveGroupBy
    @Published var todos: [TodoItem]
    @Published var doneTodos: [TodoItem]
    private var cancellables: Set<AnyCancellable> = []

    init(
        id: UUID,
        name: String,
        color: String,
        icon: String = "folder.fill",
        archiveGroupBy: ArchiveGroupBy,
        todos: [TodoItem],
        doneTodos: [TodoItem]
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
        self.archiveGroupBy = archiveGroupBy
        self.todos = todos
        self.doneTodos = doneTodos
        configureBindings()
        bindTodos()
    }

    var fileName: String {
        "\(FileNameSanitizer.sanitize(name)).md"
    }

    var todoCount: Int { todos.count }
    var doneCount: Int { doneTodos.count }
    var totalCount: Int { todoCount + doneCount }

    private func bindTodos() {
        todos.forEach { $0.project = self }
        doneTodos.forEach { $0.project = self }
    }

    private func configureBindings() {
        $todos
            .sink { [weak self] _ in
                self?.bindTodos()
            }
            .store(in: &cancellables)
        $doneTodos
            .sink { [weak self] _ in
                self?.bindTodos()
            }
            .store(in: &cancellables)
    }

    static func == (lhs: Project, rhs: Project) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
