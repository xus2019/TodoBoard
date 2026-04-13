import SwiftUI

enum DaylightTheme {
    static let palette = ThemePalette(
        name: "daylight",
        lightWindowBackground: Color(hex: "#F5F5F7"),
        lightColumnBackground: Color.white.opacity(0.9),
        lightCardBackground: Color(hex: "#FAFAFA"),
        lightCardHoverBackground: Color.white,
        lightDoneCardBackground: Color(hex: "#F0F1F3"),
        darkWindowBackground: Color(hex: "#2C2C2E"),
        darkColumnBackground: Color(hex: "#333336"),
        darkCardBackground: Color(hex: "#3A3A3C"),
        darkCardHoverBackground: Color(hex: "#444446"),
        darkDoneCardBackground: Color(hex: "#353538"),
        lightTextPrimary: Color.black.opacity(0.82),
        lightTextSecondary: Color.black.opacity(0.56),
        lightTextDone: Color.black.opacity(0.35),
        darkTextPrimary: Color.white.opacity(0.92),
        darkTextSecondary: Color.white.opacity(0.62),
        darkTextDone: Color.white.opacity(0.45),
        accentColor: Color(hex: "#4A90D9"),
        separatorColor: Color.black.opacity(0.08),
        doneCardOpacity: 0.5,
        cardCornerRadius: 12,
        useMaterial: false
    )
}
