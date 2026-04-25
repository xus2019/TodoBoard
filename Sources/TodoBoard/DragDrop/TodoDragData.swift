import CoreTransferable
import UniformTypeIdentifiers

struct TodoDragData: Codable, Transferable {
    let todoId: String
    let sourceProjectId: String

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .todoBoardTodoDrag)
    }
}

extension UTType {
    static let todoBoardTodoDrag = UTType(exportedAs: "com.todoboard.todo-drag", conformingTo: .json)
}
