import SwiftUI

struct TodoReorderDropDelegate: DropDelegate {
    let item: TodoItem
    let project: Project
    let draggedTodo: TodoItem?
    let onMove: (IndexSet, Int) -> Void

    func performDrop(info: DropInfo) -> Bool {
        true
    }

    func dropEntered(info: DropInfo) {
        guard
            let draggedTodo,
            draggedTodo.id != item.id,
            draggedTodo.project?.id == project.id,
            let fromIndex = project.todos.firstIndex(where: { $0.id == draggedTodo.id }),
            let toIndex = project.todos.firstIndex(where: { $0.id == item.id })
        else {
            return
        }

        if project.todos[toIndex].id != draggedTodo.id {
            onMove(IndexSet(integer: fromIndex), toIndex > fromIndex ? toIndex + 1 : toIndex)
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}
