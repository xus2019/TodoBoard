import SwiftUI

enum MoonlightTheme {
    static let palette = ThemePalette(
        name: "moonlight",
        lightWindowBackground: Color(hex: "#E8EAF0"),
        lightColumnBackground: Color.white.opacity(0.68),
        lightCardBackground: Color.white.opacity(0.92),
        lightCardHoverBackground: Color.white,
        lightDoneCardBackground: Color.white.opacity(0.72),
        darkWindowBackground: Color(hex: "#1E1E2E"),
        darkColumnBackground: Color.white.opacity(0.05),
        darkCardBackground: Color.white.opacity(0.07),
        darkCardHoverBackground: Color.white.opacity(0.12),
        darkDoneCardBackground: Color.white.opacity(0.05),
        lightTextPrimary: Color.black.opacity(0.84),
        lightTextSecondary: Color.black.opacity(0.56),
        lightTextDone: Color.black.opacity(0.4),
        darkTextPrimary: Color.white.opacity(0.92),
        darkTextSecondary: Color.white.opacity(0.62),
        darkTextDone: Color.white.opacity(0.45),
        accentColor: Color(hex: "#4A90D9"),
        separatorColor: Color.black.opacity(0.08),
        doneCardOpacity: 0.7,
        cardCornerRadius: 12,
        useMaterial: true
    )
}
