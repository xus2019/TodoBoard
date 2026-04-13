import Combine
import Foundation

final class TodoItem: ObservableObject, Identifiable, Hashable {
    let id: String
    @Published var title: String
    @Published var content: String
    @Published var isDone: Bool
    @Published var doneAt: Date?
    let createdAt: Date
    @Published var updatedAt: Date
    @Published var tags: [String]
    weak var project: Project?

    init(
        id: String,
        title: String,
        content: String,
        isDone: Bool,
        doneAt: Date?,
        createdAt: Date,
        updatedAt: Date,
        tags: [String]
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.isDone = isDone
        self.doneAt = doneAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tags = tags
    }

    var hasContent: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func duplicate() -> TodoItem {
        TodoItem(
            id: UUID().uuidString.lowercased(),
            title: title,
            content: content,
            isDone: isDone,
            doneAt: doneAt,
            createdAt: Date(),
            updatedAt: Date(),
            tags: tags
        )
    }

    static func == (lhs: TodoItem, rhs: TodoItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
