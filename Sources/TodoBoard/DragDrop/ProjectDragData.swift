import CoreTransferable
import UniformTypeIdentifiers

struct ProjectDragData: Codable, Transferable {
    let projectId: String

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .todoBoardProjectDrag)
    }
}

extension UTType {
    // Conform only to .data (not .json) so a dropDestination(for: TodoDragData.self)
    // sitting on the same view cannot consider this payload compatible.
    static let todoBoardProjectDrag = UTType(exportedAs: "com.todoboard.project-drag", conformingTo: .data)
}
