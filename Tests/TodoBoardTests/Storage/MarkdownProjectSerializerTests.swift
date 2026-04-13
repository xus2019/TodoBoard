import Foundation
import Testing
@testable import TodoBoard

struct MarkdownProjectSerializerTests {
    @Test
    func serializeRoundTripsProjectData() throws {
        let original = try MarkdownProjectParser.parse(SampleMarkdown.project)

        let markdown = MarkdownProjectSerializer.serialize(original)
        let reparsed = try MarkdownProjectParser.parse(markdown)

        #expect(reparsed.id == original.id)
        #expect(reparsed.name == original.name)
        #expect(reparsed.color == original.color)
        #expect(reparsed.archiveGroupBy == original.archiveGroupBy)
        #expect(reparsed.todos.map(\.title) == original.todos.map(\.title))
        #expect(reparsed.doneTodos.map(\.title) == original.doneTodos.map(\.title))
        #expect(reparsed.todos.first?.content == original.todos.first?.content)
        #expect(reparsed.doneTodos.first?.doneAt == original.doneTodos.first?.doneAt)
    }

    @Test
    func serializeKeepsSectionHeadings() throws {
        let project = try MarkdownProjectParser.parse(SampleMarkdown.project)
        let markdown = MarkdownProjectSerializer.serialize(project)

        #expect(markdown.contains("## Todo"))
        #expect(markdown.contains("## Done"))
        #expect(markdown.contains("- [ ] 完成 API 设计"))
        #expect(markdown.contains("- [x] ~~搭建项目框架~~"))
    }
}
