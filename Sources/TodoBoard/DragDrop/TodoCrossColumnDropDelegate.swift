import SwiftUI
import UniformTypeIdentifiers

struct TodoCrossColumnDropDelegate: DropDelegate {
    let targetProject: Project
    let onDropTodo: (String, Project) -> Void

    func performDrop(info: DropInfo) -> Bool {
        let providers = info.itemProviders(for: [UTType.json])
        guard let provider = providers.first else { return false }
        provider.loadDataRepresentation(forTypeIdentifier: UTType.json.identifier) { data, _ in
            guard let data, let dragData = try? JSONDecoder().decode(TodoDragData.self, from: data) else {
                return
            }
            DispatchQueue.main.async {
                onDropTodo(dragData.todoId, targetProject)
            }
        }
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}
