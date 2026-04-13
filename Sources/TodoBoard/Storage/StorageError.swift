import Foundation

enum StorageError: LocalizedError {
    case invalidFrontMatter
    case missingProjectTitle
    case missingTodoSection
    case missingDoneSection
    case invalidTodoLine(String)
    case invalidMetaComment
    case invalidUUID(String)
    case invalidEncoding
    case invalidSectionOrder

    var errorDescription: String? {
        switch self {
        case .invalidFrontMatter:
            "Front Matter 格式不正确。"
        case .missingProjectTitle:
            "缺少项目标题。"
        case .missingTodoSection:
            "缺少 Todo 分区。"
        case .missingDoneSection:
            "缺少 Done 分区。"
        case let .invalidTodoLine(line):
            "Todo 行格式不正确：\(line)"
        case .invalidMetaComment:
            "meta 注释格式不正确。"
        case let .invalidUUID(value):
            "UUID 无效：\(value)"
        case .invalidEncoding:
            "文件编码无效。"
        case .invalidSectionOrder:
            "Todo/Done 分区顺序不正确。"
        }
    }
}
