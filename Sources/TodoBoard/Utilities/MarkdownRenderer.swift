import Foundation

enum MarkdownRenderer {
    static func render(_ markdown: String) -> AttributedString {
        do {
            return try AttributedString(
                markdown: markdown,
                options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .full)
            )
        } catch {
            return AttributedString(markdown)
        }
    }
}
