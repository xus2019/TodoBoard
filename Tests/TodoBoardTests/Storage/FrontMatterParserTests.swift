import Foundation
import Testing
@testable import TodoBoard

struct FrontMatterParserTests {
    @Test
    func splitParsesMetadataAndBody() throws {
        let content = """
        ---
        id: 550e8400-e29b-41d4-a716-446655440000
        color: "#4A90D9"
        archiveGroupBy: week
        ---

        # 工作任务
        """

        let result = try FrontMatterParser.split(content)

        #expect(result.metadata["id"] == "550e8400-e29b-41d4-a716-446655440000")
        #expect(result.metadata["color"] == "#4A90D9")
        #expect(result.metadata["archiveGroupBy"] == "week")
        #expect(result.body.trimmingCharacters(in: .whitespacesAndNewlines) == "# 工作任务")
    }

    @Test
    func serializeProducesStableYamlBlock() {
        let block = FrontMatterParser.serialize([
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "color": "#4A90D9",
            "archiveGroupBy": "week",
        ])

        #expect(
            block == """
            ---
            id: 550e8400-e29b-41d4-a716-446655440000
            color: "#4A90D9"
            archiveGroupBy: week
            ---
            """
        )
    }
}
