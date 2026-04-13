import Foundation

struct ArchiveGroup: Identifiable, Hashable {
    let id: String
    let title: String
    let todos: [TodoItem]
    var isExpanded: Bool
}
