import Foundation

struct TagDefinition: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let color: String
}
