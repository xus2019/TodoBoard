import AppKit
import Combine
import SwiftUI

@MainActor
final class ThemeManager: ObservableObject {
    @Published private(set) var currentTheme: ThemePalette
    @Published var appearance: Appearance
    @Published var customAccentColor: Color
    @Published var fontFamily: String
    @Published var fontSize: CGFloat
    @Published var cardStyle: CardStyle
    @Published var columnWidth: CGFloat
    @Published var materialOpacity: Double
    @Published var ambience: AmbienceEffect
    @Published var ambienceDensity: Double
    @Published private(set) var config: AppConfig

    init(config: AppConfig) {
        self.config = config
        self.currentTheme = ThemeManager.palette(named: config.theme.name)
        self.appearance = config.theme.appearance
        self.customAccentColor = Color(hex: config.theme.accentColor)
        self.fontFamily = config.theme.fontFamily
        self.fontSize = config.theme.fontSize
        self.cardStyle = config.theme.cardStyle
        self.columnWidth = config.theme.columnWidth
        self.materialOpacity = config.theme.materialOpacity
        self.ambience = config.theme.ambience
        self.ambienceDensity = config.theme.ambienceDensity
    }

    var resolvedAppearance: NSAppearance.Name {
        switch appearance {
        case .light:
            return NSAppearance.Name.aqua
        case .dark:
            return NSAppearance.Name.darkAqua
        case .system:
            return NSApp.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) ?? .aqua
        }
    }

    var isDark: Bool {
        resolvedAppearance == .darkAqua
    }

    var windowBackground: Color {
        isDark ? currentTheme.darkWindowBackground : currentTheme.lightWindowBackground
    }

    var accentColor: Color {
        customAccentColor
    }

    var columnBackground: Color {
        isDark ? currentTheme.darkColumnBackground : currentTheme.lightColumnBackground
    }

    var cardBackground: Color {
        isDark ? currentTheme.darkCardBackground : currentTheme.lightCardBackground
    }

    var cardHoverBackground: Color {
        isDark ? currentTheme.darkCardHoverBackground : currentTheme.lightCardHoverBackground
    }

    var doneCardBackground: Color {
        isDark ? currentTheme.darkDoneCardBackground : currentTheme.lightDoneCardBackground
    }

    var textPrimary: Color {
        isDark ? currentTheme.darkTextPrimary : currentTheme.lightTextPrimary
    }

    var textSecondary: Color {
        isDark ? currentTheme.darkTextSecondary : currentTheme.lightTextSecondary
    }

    var textDone: Color {
        isDark ? currentTheme.darkTextDone : currentTheme.lightTextDone
    }

    func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch fontFamily {
        case "SF Mono":
            .system(size: size, weight: weight, design: .monospaced)
        case "Menlo":
            .custom("Menlo", size: size).weight(weight)
        default:
            .system(size: size, weight: weight)
        }
    }

    func nsFont(size: CGFloat, weight: NSFont.Weight = .regular) -> NSFont {
        switch fontFamily {
        case "SF Mono":
            return .monospacedSystemFont(ofSize: size, weight: weight)
        case "Menlo":
            return NSFont(name: "Menlo", size: size) ?? .systemFont(ofSize: size, weight: weight)
        default:
            return .systemFont(ofSize: size, weight: weight)
        }
    }

    var useGlassMaterial: Bool {
        currentTheme.useMaterial && cardStyle == .glass
    }

    // materialOpacity 0~1: 0=纯色不透明, 1=接近全透明
    // glassOverlayOpacity: material 上叠加底色的不透明度（连续平滑，无断档）
    var glassOverlayOpacity: Double {
        guard useGlassMaterial else { return 1.0 }
        return max(0.03, (1.0 - materialOpacity) * 0.95)
    }

    func tagColor(for tag: String) -> Color {
        Color(hex: config.tagColors[tag] ?? (customAccentColor.hexString ?? config.theme.accentColor))
    }

    func applyTheme(_ name: String) {
        currentTheme = ThemeManager.palette(named: name)
        config.theme.name = currentTheme.name
    }

    func saveToConfig() -> AppConfig {
        config.theme = ThemeConfiguration(
            name: currentTheme.name,
            appearance: appearance,
            accentColor: customAccentColor.hexString ?? config.theme.accentColor,
            fontFamily: fontFamily,
            fontSize: fontSize,
            cardStyle: cardStyle,
            columnWidth: columnWidth,
            materialOpacity: materialOpacity,
            ambience: ambience,
            ambienceDensity: ambienceDensity
        )
        return config
    }

    func applySavedConfig(_ config: AppConfig) {
        self.config = config
        currentTheme = ThemeManager.palette(named: config.theme.name)
        appearance = config.theme.appearance
        customAccentColor = Color(hex: config.theme.accentColor)
        fontFamily = config.theme.fontFamily
        fontSize = config.theme.fontSize
        cardStyle = config.theme.cardStyle
        columnWidth = config.theme.columnWidth
        materialOpacity = config.theme.materialOpacity
        ambience = config.theme.ambience
        ambienceDensity = config.theme.ambienceDensity
    }

    static func palette(named name: String) -> ThemePalette {
        switch name.lowercased() {
        case "daylight":
            DaylightTheme.palette
        case "solarized":
            SolarizedTheme.palette
        case "minimal":
            MinimalTheme.palette
        default:
            MoonlightTheme.palette
        }
    }
}
