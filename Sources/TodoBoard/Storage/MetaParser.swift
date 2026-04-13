import Foundation

struct TodoMetadata: Codable, Equatable {
    let id: String
    let createdAt: Date
    let doneAt: Date?
    let tags: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created"
        case doneAt = "done"
        case tags
    }

    init(id: String, createdAt: Date, doneAt: Date?, tags: [String]) {
        self.id = id
        self.createdAt = createdAt
        self.doneAt = doneAt
        self.tags = tags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.doneAt = try container.decodeIfPresent(Date.self, forKey: .doneAt)
        self.tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.lowercased(), forKey: .id)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(doneAt, forKey: .doneAt)
        if !tags.isEmpty {
            try container.encode(tags, forKey: .tags)
        }
    }
}

enum MetaParser {
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            guard let date = DateFormatters.fromISO8601(string) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO8601 date")
            }
            return date
        }
        return decoder
    }()

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(DateFormatters.iso8601(for: date))
        }
        return encoder
    }()

    static func parse(comment: String) throws -> TodoMetadata {
        guard
            let startRange = comment.range(of: "<!-- meta:"),
            let endRange = comment.range(of: "-->", options: .backwards)
        else {
            throw StorageError.invalidMetaComment
        }

        let json = String(comment[startRange.upperBound..<endRange.lowerBound]).trimmed
        guard let data = json.data(using: String.Encoding.utf8) else {
            throw StorageError.invalidEncoding
        }
        return try decoder.decode(TodoMetadata.self, from: data)
    }

    static func serialize(_ meta: TodoMetadata) -> String {
        let data = (try? encoder.encode(meta)) ?? Data()
        let json = String(data: data, encoding: .utf8) ?? "{}"
        return "<!-- meta:\(json) -->"
    }
}
