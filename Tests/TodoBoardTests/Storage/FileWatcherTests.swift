import Foundation
import Testing
@testable import TodoBoard

struct FileWatcherTests {
    @Test
    func trackedURLsOnlyIncludeMarkdownFiles() throws {
        let watcher = FileWatcher()
        let directory = try TestDirectories.makeTemporaryDirectory()
        let markdown = directory.appendingPathComponent("项目.md")
        let json = directory.appendingPathComponent(".todoboard.json")
        let text = directory.appendingPathComponent("note.txt")
        try "# 标题".write(to: markdown, atomically: true, encoding: .utf8)
        try "{}".write(to: json, atomically: true, encoding: .utf8)
        try "hello".write(to: text, atomically: true, encoding: .utf8)

        let urls = watcher.trackedMarkdownURLs(in: directory)

        #expect(urls.map { $0.resolvingSymlinksInPath() } == [markdown.resolvingSymlinksInPath()])
    }

    @Test
    func contentHashIsStableForSameBytes() {
        let watcher = FileWatcher()
        let data = Data("abc".utf8)

        let first = watcher.contentHash(for: data)
        let second = watcher.contentHash(for: data)

        #expect(first == second)
        #expect(!first.isEmpty)
    }
}
