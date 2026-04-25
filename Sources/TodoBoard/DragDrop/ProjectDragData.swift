import CoreTransferable
import UniformTypeIdentifiers

struct ProjectDragData: Codable, Transferable {
    let projectId: String

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .todoBoardProjectDrag)
    }
}

extension UTType {
    static let todoBoardProjectDrag = UTType(exportedAs: "com.todoboard.project-drag", conformingTo: .json)
}
