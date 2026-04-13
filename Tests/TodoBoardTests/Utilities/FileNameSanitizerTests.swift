import Foundation
import Testing
@testable import TodoBoard

struct FileNameSanitizerTests {
    @Test
    func sanitizeReplacesIllegalCharacters() {
        #expect(
            FileNameSanitizer.sanitize(#"工作/任务:计划*草稿?"#) ==
                "工作_任务_计划_草稿_"
        )
    }
}
