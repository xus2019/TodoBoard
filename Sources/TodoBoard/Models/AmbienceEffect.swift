import Foundation

enum AmbienceEffect: String, Codable, CaseIterable {
    case none
    case rain
    case snow
    case firefly
    case sakura
    case stardust

    var displayName: String {
        switch self {
        case .none:
            "无"
        case .rain:
            "雨滴"
        case .snow:
            "雪花"
        case .firefly:
            "萤火虫"
        case .sakura:
            "樱花"
        case .stardust:
            "星尘"
        }
    }
}
