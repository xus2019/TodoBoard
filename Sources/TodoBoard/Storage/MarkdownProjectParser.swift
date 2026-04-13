import Foundation

enum MarkdownProjectParser {
    static func parse(_ markdown: String) throws -> Project {
        let (metadata, body) = try FrontMatterParser.split(markdown)
        guard let idString = metadata["id"], let projectId = UUID(uuidString: idString) else {
            throw StorageError.invalidUUID(metadata["id"] ?? "nil")
        }

        let lines = body.replacingOccurrences(of: "\r\n", with: "\n").components(separatedBy: "\n")
        guard let titleLine = lines.first(where: { $0.hasPrefix("# ") }) else {
            throw StorageError.missingProjectTitle
        }

        guard let todoIndex = lines.firstIndex(of: "## Todo") else {
            throw StorageError.missingTodoSection
        }
        guard let doneIndex = lines.firstIndex(of: "## Done") else {
            throw StorageError.missingDoneSection
        }
        guard todoIndex < doneIndex else {
            throw StorageError.invalidSectionOrder
        }

        let projectName = String(titleLine.dropFirst(2)).trimmed
        let todoSection = Array(lines[(todoIndex + 1)..<doneIndex])
        let doneSection = Array(lines[(doneIndex + 1)...])
        let todos = try parseSection(todoSection, isDone: false)
        let doneTodos = try parseSection(doneSection, isDone: true)
            .sorted { ($0.doneAt ?? .distantPast) > ($1.doneAt ?? .distantPast) }

        return Project(
            id: projectId,
            name: projectName,
            color: metadata["color"] ?? AppConfig.default.theme.accentColor,
            icon: metadata["icon"] ?? "folder.fill",
            archiveGroupBy: ArchiveGroupBy(rawValue: metadata["archiveGroupBy"] ?? "") ?? .week,
            todos: todos,
            doneTodos: doneTodos
        )
    }

    private static func parseSection(_ lines: [String], isDone: Bool) throws -> [TodoItem] {
        var index = 0
        var items: [TodoItem] = []

        while index < lines.count {
            let line = lines[index]
            let trimmedLine = line.trimmed
            if trimmedLine.isEmpty {
                index += 1
                continue
            }
            guard isTodoLine(trimmedLine) else {
                index += 1
                continue
            }

            let item = try parseTodoLine(trimmedLine, isDone: isDone)
            index += 1
            var contentLines: [String] = []

            while index < lines.count {
                let nextLine = lines[index]
                let trimmed = nextLine.trimmed
                if isTodoLine(trimmed) || trimmed == "## Done" {
                    break
                }
                if trimmed.hasPrefix(">") || nextLine.hasPrefix("  >") {
                    contentLines.append(parseBlockquoteLine(nextLine))
                } else if trimmed.isEmpty {
                    if index + 1 < lines.count {
                        let lookahead = lines[index + 1].trimmed
                        if lookahead.hasPrefix(">") || lines[index + 1].hasPrefix("  >") {
                            contentLines.append("")
                        }
                    }
                } else {
                    index += 1
                    continue
                }
                index += 1
            }

            item.content = contentLines.joined(separator: "\n").trimmed
            item.updatedAt = item.doneAt ?? item.createdAt
            items.append(item)
        }

        return items
    }

    private static func parseTodoLine(_ line: String, isDone: Bool) throws -> TodoItem {
        let prefix = isDone ? "- [x] ~~" : "- [ ] "
        let lineBody: String
        let title: String
        let metaComment: String

        if isDone {
            guard
                line.hasPrefix(prefix),
                let titleEnd = line.range(of: "~~ <!-- meta:")
            else {
                throw StorageError.invalidTodoLine(line)
            }
            title = String(line[line.index(line.startIndex, offsetBy: prefix.count)..<titleEnd.lowerBound])
            metaComment = "<!-- meta:" + line[titleEnd.upperBound...]
        } else {
            guard
                line.hasPrefix(prefix),
                let titleEnd = line.range(of: " <!-- meta:")
            else {
                throw StorageError.invalidTodoLine(line)
            }
            title = String(line[line.index(line.startIndex, offsetBy: prefix.count)..<titleEnd.lowerBound])
            metaComment = "<!-- meta:" + line[titleEnd.upperBound...]
        }

        lineBody = title.trimmed
        let meta = try MetaParser.parse(comment: metaComment)
        return TodoItem(
            id: meta.id,
            title: lineBody,
            content: "",
            isDone: isDone,
            doneAt: meta.doneAt,
            createdAt: meta.createdAt,
            updatedAt: meta.doneAt ?? meta.createdAt,
            tags: meta.tags
        )
    }

    private static func parseBlockquoteLine(_ line: String) -> String {
        if line.hasPrefix("  > ") {
            return String(line.dropFirst(4))
        }
        if line.hasPrefix("  >") {
            return ""
        }
        if line.hasPrefix("> ") {
            return String(line.dropFirst(2))
        }
        if line.hasPrefix(">") {
            return ""
        }
        return line
    }

    private static func isTodoLine(_ line: String) -> Bool {
        line.hasPrefix("- [ ]") || line.hasPrefix("- [x]")
    }
}
