import Foundation
import Testing
@testable import TodoBoard

struct DateFormattersTests {
    @Test
    func iso8601RoundTrip() throws {
        let date = try #require(DateFormatters.fromISO8601("2024-03-15T10:00:00Z"))
        #expect(DateFormatters.iso8601(for: date) == "2024-03-15T10:00:00Z")
    }

    @Test
    func weekRangeUsesSundayStart() throws {
        let date = try #require(DateFormatters.fromISO8601("2024-03-12T12:00:00Z"))
        #expect(DateFormatters.weekRange(for: date) == "3月10日 - 3月16日 (2024)")
    }

    @Test
    func monthTitleUsesChineseFormat() throws {
        let date = try #require(DateFormatters.fromISO8601("2024-03-12T12:00:00Z"))
        #expect(DateFormatters.monthTitle(for: date) == "2024年3月")
    }
}
