import Foundation
import Testing
@testable import TodoBoard

struct MetaParserTests {
    @Test
    func parseExtractsMetaFromComment() throws {
        let comment = #"<!-- meta:{"id":"550e8400-e29b-41d4-a716-446655440000","created":"2024-03-15T10:00:00Z","done":"2024-03-16T11:00:00Z","tags":["紧急","重要"]} -->"#

        let meta = try MetaParser.parse(comment: comment)

        #expect(meta.id.lowercased() == "550e8400-e29b-41d4-a716-446655440000")
        #expect(meta.createdAt == DateFormatters.fromISO8601("2024-03-15T10:00:00Z"))
        #expect(meta.doneAt == DateFormatters.fromISO8601("2024-03-16T11:00:00Z"))
        #expect(meta.tags == ["紧急", "重要"])
    }

    @Test
    func serializeProducesStableComment() throws {
        let meta = TodoMetadata(
            id: "550e8400-e29b-41d4-a716-446655440000",
            createdAt: DateFormatters.fromISO8601("2024-03-15T10:00:00Z") ?? Date(),
            doneAt: DateFormatters.fromISO8601("2024-03-16T11:00:00Z"),
            tags: ["紧急", "重要"]
        )

        #expect(
            MetaParser.serialize(meta) ==
                #"<!-- meta:{"created":"2024-03-15T10:00:00Z","done":"2024-03-16T11:00:00Z","id":"550e8400-e29b-41d4-a716-446655440000","tags":["紧急","重要"]} -->"#
        )
    }
}
