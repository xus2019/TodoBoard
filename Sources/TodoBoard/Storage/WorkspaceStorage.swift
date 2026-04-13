import Combine
import Foundation

final class WorkspaceStorage: ObservableObject {
    let dataDirectory: URL

    private let fileManager: FileManager
    private let writeQueue = DispatchQueue(label: "com.todoboard.filewrite")
    private let writeQueueKey = DispatchSpecificKey<UInt8>()
    private let writeQueueValue: UInt8 = 1
    private let debounceLock = NSLock()
    private let fileWatcher = FileWatcher()
    private var writeDebounceTimers: [UUID: DispatchWorkItem] = [:]

    var onProjectChanged: ((Project) -> Void)?

    init(dataDirectory: URL, fileManager: FileManager = .default) {
        self.dataDirectory = dataDirectory
        self.fileManager = fileManager
        self.writeQueue.setSpecific(key: writeQueueKey, value: writeQueueValue)
        try? fileManager.createDirectory(at: dataDirectory, withIntermediateDirectories: true)
        configureWatcher()
    }

    func loadAllProjects() -> [Project] {
        let config = loadConfig()
        let urls = (try? fileManager.contentsOfDirectory(at: dataDirectory, includingPropertiesForKeys: nil)) ?? []
        let projects = urls
            .filter { $0.pathExtension.lowercased() == "md" }
            .compactMap { try? loadProject(from: $0) }
        let order = Dictionary(uniqueKeysWithValues: config.projectOrder.enumerated().map { ($0.element, $0.offset) })
        return projects.sorted { lhs, rhs in
            let lhsOrder = order[lhs.id.uuidString.lowercased()] ?? .max
            let rhsOrder = order[rhs.id.uuidString.lowercased()] ?? .max
            if lhsOrder == rhsOrder {
                return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
            }
            return lhsOrder < rhsOrder
        }
    }

    func loadProject(from url: URL) throws -> Project {
        let data = try Data(contentsOf: url)
        guard let markdown = String(data: data, encoding: .utf8) else {
            throw StorageError.invalidEncoding
        }
        return try MarkdownProjectParser.parse(markdown)
    }

    func saveProject(_ project: Project) {
        let workItem = DispatchWorkItem { [weak self] in
            self?.saveProjectImmediately(project)
            self?.withDebounceLock {
                self?.writeDebounceTimers[project.id] = nil
            }
        }
        withDebounceLock {
            writeDebounceTimers[project.id]?.cancel()
            writeDebounceTimers[project.id] = workItem
        }
        writeQueue.asyncAfter(deadline: .now() + .milliseconds(200), execute: workItem)
    }

    func saveProjectImmediately(_ project: Project) {
        let markdown = MarkdownProjectSerializer.serialize(project)
        let url = projectURL(for: project)
        let tmpURL = dataDirectory.appendingPathComponent(".\(project.fileName).tmp")

        performWrite {
            do {
                try markdown.write(to: tmpURL, atomically: true, encoding: .utf8)
                if fileManager.fileExists(atPath: url.path) {
                    _ = try fileManager.replaceItemAt(url, withItemAt: tmpURL)
                } else {
                    try fileManager.moveItem(at: tmpURL, to: url)
                }
            } catch {
                try? fileManager.removeItem(at: tmpURL)
            }
        }

        updateProjectOrderIfNeeded(project)
    }

    func createProject(name: String, color: String? = nil) -> Project {
        let config = loadConfig()
        let project = Project(
            id: UUID(),
            name: name,
            color: color ?? config.theme.accentColor,
            archiveGroupBy: config.defaultArchiveGroupBy,
            todos: [],
            doneTodos: []
        )
        saveProjectImmediately(project)
        updateProjectOrderIfNeeded(project)
        return project
    }

    func deleteProject(_ project: Project) {
        try? fileManager.removeItem(at: projectURL(for: project))
        var config = loadConfig()
        config.projectOrder.removeAll { $0 == project.id.uuidString.lowercased() }
        saveConfig(config)
    }

    func renameProject(_ project: Project, to newName: String) {
        let oldURL = projectURL(for: project)
        project.name = newName
        let newURL = projectURL(for: project)
        if oldURL != newURL, fileManager.fileExists(atPath: oldURL.path) {
            try? fileManager.moveItem(at: oldURL, to: newURL)
        }
        saveProjectImmediately(project)
    }

    func startWatching() {
        fileWatcher.start(directory: dataDirectory)
    }

    func stopWatching() {
        fileWatcher.stop()
    }

    func loadConfig() -> AppConfig {
        let url = configURL
        guard
            let data = try? Data(contentsOf: url),
            let config = try? JSONDecoder().decode(AppConfig.self, from: data)
        else {
            let config = AppConfig.default
            saveConfig(config)
            return config
        }
        return config
    }

    func saveConfig(_ config: AppConfig) {
        guard let data = try? JSONEncoder.pretty.encode(config) else { return }
        try? data.write(to: configURL, options: .atomic)
    }

    func exportProjects(_ projects: [Project], to directory: URL) throws {
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        for project in projects {
            let targetURL = directory.appendingPathComponent(project.fileName)
            let markdown = MarkdownProjectSerializer.serialize(project)
            try markdown.write(to: targetURL, atomically: true, encoding: .utf8)
        }

        if projects.count > 1 {
            let combined = combinedExportMarkdown(for: projects)
            let combinedURL = directory.appendingPathComponent("TodoBoard_Export.md")
            try combined.write(to: combinedURL, atomically: true, encoding: .utf8)
        }
    }

    func importProjects(from url: URL) throws -> [Project] {
        let data = try Data(contentsOf: url)
        guard let content = String(data: data, encoding: .utf8) else {
            throw StorageError.invalidEncoding
        }

        if content.hasPrefix("---\n") {
            return [try MarkdownProjectParser.parse(content)]
        }

        return try parseCombinedImport(content)
    }

    func persistImportedProjects(_ projects: [Project]) {
        projects.forEach { project in
            let resolvedProject = resolveImportedProjectName(project)
            saveProjectImmediately(resolvedProject)
        }
    }

    private var configURL: URL {
        dataDirectory.appendingPathComponent(".todoboard.json")
    }

    private func projectURL(for project: Project) -> URL {
        dataDirectory.appendingPathComponent(project.fileName)
    }

    private func configureWatcher() {
        fileWatcher.onFileChanged = { [weak self] url in
            guard let self, let project = try? self.loadProject(from: url) else { return }
            self.onProjectChanged?(project)
        }
    }

    private func performWrite(_ operation: () -> Void) {
        if DispatchQueue.getSpecific(key: writeQueueKey) == writeQueueValue {
            operation()
            return
        }
        writeQueue.sync(execute: operation)
    }

    private func withDebounceLock(_ operation: () -> Void) {
        debounceLock.lock()
        defer { debounceLock.unlock() }
        operation()
    }

    private func resolveImportedProjectName(_ project: Project) -> Project {
        var resolvedName = project.name
        var suffix = 1
        while fileManager.fileExists(atPath: dataDirectory.appendingPathComponent("\(FileNameSanitizer.sanitize(resolvedName)).md").path) {
            suffix += 1
            resolvedName = "\(project.name)-\(suffix)"
        }
        if resolvedName == project.name {
            return project
        }
        return Project(
            id: project.id,
            name: resolvedName,
            color: project.color,
            archiveGroupBy: project.archiveGroupBy,
            todos: project.todos,
            doneTodos: project.doneTodos
        )
    }

    private func combinedExportMarkdown(for projects: [Project]) -> String {
        let projectSections = projects.map { project -> String in
            let todoBody = project.todos.map { "- [ ] \($0.title)" }.joined(separator: "\n")
            let doneBody = project.doneTodos.map { todo in
                let date = todo.doneAt.map { DateFormatters.iso8601(for: $0).prefix(10) } ?? ""
                return "- [x] ~~\(todo.title)~~ *(完成于 \(date))*"
            }.joined(separator: "\n")

            return """
            ## Project: \(project.name)

            ### 待办
            \(todoBody)

            ### 已完成
            \(doneBody)
            """
        }

        return """
        # TodoBoard 导出
        > 导出时间: \(DateFormatters.iso8601(for: Date()))

        ---

        \(projectSections.joined(separator: "\n\n---\n\n"))
        """
    }

    private func parseCombinedImport(_ content: String) throws -> [Project] {
        let sections = content.components(separatedBy: "\n## Project: ")
        guard !sections.isEmpty else { return [] }
        return sections.compactMap { section in
            let normalized = section.hasPrefix("# TodoBoard 导出") ? nil : section
            guard let normalized else { return nil }
            let lines = normalized.components(separatedBy: "\n")
            guard let firstLine = lines.first else { return nil }
            let name = firstLine.trimmed
            var todos: [TodoItem] = []
            var doneTodos: [TodoItem] = []
            var isDoneSection = false

            for line in lines.dropFirst() {
                if line.hasPrefix("### 已完成") {
                    isDoneSection = true
                    continue
                }
                if line.hasPrefix("### 待办") || line.trimmed.isEmpty {
                    continue
                }
                if line.hasPrefix("- [ ] ") {
                    todos.append(
                        TodoItem(
                            id: UUID().uuidString.lowercased(),
                            title: line.removingPrefix("- [ ] ").trimmed,
                            content: "",
                            isDone: false,
                            doneAt: nil,
                            createdAt: Date(),
                            updatedAt: Date(),
                            tags: []
                        )
                    )
                }
                if isDoneSection, line.hasPrefix("- [x] ~~") {
                    let title = line
                        .removingPrefix("- [x] ~~")
                        .components(separatedBy: "~~")
                        .first?
                        .trimmed ?? ""
                    let doneDate = line
                        .components(separatedBy: "完成于 ")
                        .last?
                        .replacingOccurrences(of: ")*", with: "")
                    let parsedDate = doneDate.flatMap { DateFormatters.fromISO8601("\($0)T00:00:00Z") }
                    doneTodos.append(
                        TodoItem(
                            id: UUID().uuidString.lowercased(),
                            title: title,
                            content: "",
                            isDone: true,
                            doneAt: parsedDate,
                            createdAt: Date(),
                            updatedAt: Date(),
                            tags: []
                        )
                    )
                }
            }

            return Project(
                id: UUID(),
                name: name,
                color: loadConfig().theme.accentColor,
                archiveGroupBy: .week,
                todos: todos,
                doneTodos: doneTodos
            )
        }
    }

    private func updateProjectOrderIfNeeded(_ project: Project) {
        var config = loadConfig()
        let identifier = project.id.uuidString.lowercased()
        if !config.projectOrder.contains(identifier) {
            config.projectOrder.append(identifier)
            saveConfig(config)
        }
    }
}

private extension JSONEncoder {
    static var pretty: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return encoder
    }
}
