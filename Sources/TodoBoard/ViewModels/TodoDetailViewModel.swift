import Combine
import Foundation

enum EditorMode: String, CaseIterable {
    case edit
    case preview
    case split
}

@MainActor
final class TodoDetailViewModel: ObservableObject {
    @Published var title: String
    @Published var content: String
    @Published var editorMode: EditorMode = .edit
    @Published var tags: [String]

    let todo: TodoItem
    private let storage: WorkspaceStorage
    private let autoSaveDelay: DispatchQueue.SchedulerTimeType.Stride
    private var cancellables: Set<AnyCancellable> = []

    init(
        todo: TodoItem,
        storage: WorkspaceStorage,
        autoSaveDelay: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(500)
    ) {
        self.todo = todo
        self.storage = storage
        self.autoSaveDelay = autoSaveDelay
        self.title = todo.title
        self.content = todo.content
        self.tags = todo.tags
        configureAutoSave()
    }

    func save() {
        todo.title = title.trimmed
        todo.content = content
        todo.tags = tags
        todo.updatedAt = Date()
        if let project = todo.project {
            storage.saveProject(project)
        }
    }

    private func configureAutoSave() {
        Publishers.Merge3(
            $title.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $content.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $tags.dropFirst().map { _ in () }.eraseToAnyPublisher()
        )
        .debounce(for: autoSaveDelay, scheduler: DispatchQueue.main)
        .sink { [weak self] in
            self?.save()
        }
        .store(in: &cancellables)
    }
}
