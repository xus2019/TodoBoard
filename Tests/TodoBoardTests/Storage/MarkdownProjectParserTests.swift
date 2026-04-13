import Foundation
import Testing
@testable import TodoBoard

struct MarkdownProjectParserTests {
    @Test
    func parseProjectFixture() throws {
        let project = try MarkdownProjectParser.parse(SampleMarkdown.project)

        #expect(project.name == "工作任务")
        #expect(project.color == "#4A90D9")
        #expect(project.archiveGroupBy == .week)
        #expect(project.todos.count == 3)
        #expect(project.doneTodos.count == 2)
        #expect(project.todos.first?.title == "完成 API 设计")
        #expect(project.todos.first?.content.contains("/api/users") == true)
        #expect(project.todos.first?.tags == ["紧急", "重要"])
        #expect(project.doneTodos.first?.title == "搭建项目框架")
        #expect(project.doneTodos.first?.tags == ["重要"])
    }

    @Test
    func throwsWhenDoneSectionAppearsBeforeTodoSection() {
        let malformed = """
        ---
        id: 550e8400-e29b-41d4-a716-446655440000
        color: "#4A90D9"
        archiveGroupBy: week
        ---

        # 工作任务

        ## Done

        - [x] ~~已完成~~ <!-- meta:{"id":"abc","created":"2024-03-15T10:00:00Z","done":"2024-03-16T11:00:00Z"} -->

        ## Todo
        """

        #expect(throws: Error.self) {
            try MarkdownProjectParser.parse(malformed)
        }
    }

    @Test
    func parsesIndentedTodoLines() throws {
        let markdown = """
        ---
        id: 550e8400-e29b-41d4-a716-446655440000
        color: "#4A90D9"
        archiveGroupBy: week
        ---

        # 工作任务

        ## Todo

          - [ ] 缩进待办 <!-- meta:{"id":"a1b2c3d4-e5f6-4711-8222-1234567890ab","created":"2024-03-15T10:00:00Z"} -->

        ## Done
        """

        let project = try MarkdownProjectParser.parse(markdown)

        #expect(project.todos.count == 1)
        #expect(project.todos.first?.title == "缩进待办")
    }

    @Test
    func ignoresUnexpectedLinesAndContinuesParsingFollowingTodos() throws {
        let markdown = """
        ---
        id: 550e8400-e29b-41d4-a716-446655440000
        color: "#4A90D9"
        archiveGroupBy: week
        ---

        # 工作任务

        ## Todo

        - [ ] 第一条 <!-- meta:{"id":"a1b2c3d4-e5f6-4711-8222-1234567890ab","created":"2024-03-15T10:00:00Z"} -->
        这是一行不符合格式的说明
        - [ ] 第二条 <!-- meta:{"id":"d4e5f6a7-b8c9-4012-9333-abcdef123456","created":"2024-03-15T11:00:00Z"} -->

        ## Done
        """

        let project = try MarkdownProjectParser.parse(markdown)

        #expect(project.todos.map(\.title) == ["第一条", "第二条"])
    }
}
