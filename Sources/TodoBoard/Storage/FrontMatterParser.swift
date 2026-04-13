import Foundation

enum FrontMatterParser {
    static func split(_ markdown: String) throws -> (metadata: [String: String], body: String) {
        let normalized = markdown.replacingOccurrences(of: "\r\n", with: "\n")
        guard normalized.hasPrefix("---\n") else {
            return ([:], normalized)
        }

        let content = normalized.dropFirst(4)
        guard let separatorRange = content.range(of: "\n---\n") else {
            throw StorageError.invalidFrontMatter
        }

        let metadataBlock = String(content[..<separatorRange.lowerBound])
        let body = String(content[separatorRange.upperBound...])
        return (parseLines(metadataBlock), body)
    }

    static func serialize(_ metadata: [String: String]) -> String {
        let orderedKeys = ["id", "color", "icon", "archiveGroupBy"] + metadata.keys
            .filter { !["id", "color", "icon", "archiveGroupBy"].contains($0) }
            .sorted()

        let body = orderedKeys.compactMap { key -> String? in
            guard let value = metadata[key] else { return nil }
            if value.contains("#") || value.contains(" ") {
                return "\(key): \"\(value)\""
            }
            return "\(key): \(value)"
        }.joined(separator: "\n")

        return """
        ---
        \(body)
        ---
        """
    }

    private static func parseLines(_ metadataBlock: String) -> [String: String] {
        metadataBlock
            .split(separator: "\n", omittingEmptySubsequences: true)
            .reduce(into: [String: String]()) { result, rawLine in
                let line = String(rawLine)
                guard let colonIndex = line.firstIndex(of: ":") else { return }
                let key = String(line[..<colonIndex]).trimmed
                let value = String(line[line.index(after: colonIndex)...])
                    .trimmed
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                result[key] = value
            }
    }
}
