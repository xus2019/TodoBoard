import Foundation

enum FileNameSanitizer {
    private static let invalidCharacters = CharacterSet(charactersIn: "/\\:*?\"<>|")

    static func sanitize(_ name: String) -> String {
        let scalars = name.unicodeScalars.map { scalar -> Character in
            invalidCharacters.contains(scalar) ? "_" : Character(scalar)
        }
        return String(scalars)
    }
}
