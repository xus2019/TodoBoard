import Foundation

struct ThemeConfiguration: Codable, Equatable {
    var name: String
    var appearance: Appearance
    var accentColor: String
    var fontFamily: String
    var fontSize: Double
    var cardStyle: CardStyle
    var columnWidth: Double
    var materialOpacity: Double
    var ambience: AmbienceEffect
    var ambienceDensity: Double

    init(name: String, appearance: Appearance, accentColor: String, fontFamily: String,
         fontSize: Double, cardStyle: CardStyle, columnWidth: Double,
         materialOpacity: Double, ambience: AmbienceEffect, ambienceDensity: Double = 1.0) {
        self.name = name
        self.appearance = appearance
        self.accentColor = accentColor
        self.fontFamily = fontFamily
        self.fontSize = fontSize
        self.cardStyle = cardStyle
        self.columnWidth = columnWidth
        self.materialOpacity = materialOpacity
        self.ambience = ambience
        self.ambienceDensity = ambienceDensity
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        appearance = try container.decode(Appearance.self, forKey: .appearance)
        accentColor = try container.decode(String.self, forKey: .accentColor)
        fontFamily = try container.decode(String.self, forKey: .fontFamily)
        fontSize = try container.decode(Double.self, forKey: .fontSize)
        cardStyle = try container.decode(CardStyle.self, forKey: .cardStyle)
        columnWidth = try container.decode(Double.self, forKey: .columnWidth)
        materialOpacity = try container.decode(Double.self, forKey: .materialOpacity)
        ambience = try container.decode(AmbienceEffect.self, forKey: .ambience)
        ambienceDensity = try container.decodeIfPresent(Double.self, forKey: .ambienceDensity) ?? 1.0
    }
}

struct AppConfig: Codable, Equatable {
    var version: Int
    var projectOrder: [String]
    var theme: ThemeConfiguration
    var defaultArchiveGroupBy: ArchiveGroupBy
    var dataDirectory: String
    var tagColors: [String: String]

    static let `default` = AppConfig(
        version: 1,
        projectOrder: [],
        theme: ThemeConfiguration(
            name: "moonlight",
            appearance: .system,
            accentColor: "#4A90D9",
            fontFamily: "SF Pro",
            fontSize: 14,
            cardStyle: .glass,
            columnWidth: 300,
            materialOpacity: 0.7,
            ambience: .none,
            ambienceDensity: 1.0
        ),
        defaultArchiveGroupBy: .week,
        dataDirectory: NSString(string: "~/Documents/TodoBoard").expandingTildeInPath,
        tagColors: [
            "紧急": "#E74C3C",
            "想法": "#3498DB",
            "等待": "#F39C12",
            "重要": "#9B59B6",
        ]
    )
}
