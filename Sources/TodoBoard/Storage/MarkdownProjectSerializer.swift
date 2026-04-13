import Foundation

enum MarkdownProjectSerializer {
    static func serialize(_ project: Project) -> String {
        let frontMatter = FrontMatterParser.serialize([
            "id": project.id.uuidString.lowercased(),
            "color": project.color,
            "icon": project.icon,
            "archiveGroupBy": project.archiveGroupBy.rawValue,
        ])

        let todoSection = serialize(items: project.todos, isDone: false)
        let doneItems = project.doneTodos.sorted { ($0.doneAt ?? .distantPast) > ($1.doneAt ?? .distantPast) }
        let doneSection = serialize(items: doneItems, isDone: true)

        return [
            frontMatter,
            "",
            "# \(project.name)",
            "",
            "## Todo",
            "",
            todoSection,
            "## Done",
            "",
            doneSection,
        ]
        .joined(separator: "\n")
        .trimmingCharacters(in: .whitespacesAndNewlines) + "\n"
    }

    private static func serialize(items: [TodoItem], isDone: Bool) -> String {
        guard !items.isEmpty else { return "" }

        return items.map { item in
            let meta = TodoMetadata(
                id: item.id,
                createdAt: item.createdAt,
                doneAt: item.doneAt,
                tags: item.tags
            )
            let titleLine = isDone
                ? "- [x] ~~\(item.title)~~ \(MetaParser.serialize(meta))"
                : "- [ ] \(item.title) \(MetaParser.serialize(meta))"
            let blockquote = serializeContent(item.content)
            if blockquote.isEmpty {
                return titleLine
            }
            return [titleLine, blockquote].joined(separator: "\n")
        }
        .joined(separator: "\n\n") + "\n"
    }

    private static func serializeContent(_ content: String) -> String {
        let trimmed = content.trimmingCharacters(in: .newlines)
        guard !trimmed.isEmpty else { return "" }
        return trimmed
            .components(separatedBy: "\n")
            .map { line in
                line.isEmpty ? "  >" : "  > \(line)"
            }
            .joined(separator: "\n")
    }
}
