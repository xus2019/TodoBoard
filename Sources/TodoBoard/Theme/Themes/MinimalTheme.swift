import SwiftUI

enum MinimalTheme {
    static let palette = ThemePalette(
        name: "minimal",
        lightWindowBackground: .white,
        lightColumnBackground: .white,
        lightCardBackground: .clear,
        lightCardHoverBackground: Color.black.opacity(0.02),
        lightDoneCardBackground: Color.black.opacity(0.02),
        darkWindowBackground: Color(hex: "#1C1C1E"),
        darkColumnBackground: Color(hex: "#1C1C1E"),
        darkCardBackground: .clear,
        darkCardHoverBackground: Color.white.opacity(0.04),
        darkDoneCardBackground: Color.white.opacity(0.02),
        lightTextPrimary: .black,
        lightTextSecondary: Color.black.opacity(0.56),
        lightTextDone: Color.black.opacity(0.35),
        darkTextPrimary: .white,
        darkTextSecondary: Color.white.opacity(0.62),
        darkTextDone: Color.white.opacity(0.45),
        accentColor: Color(hex: "#4A90D9"),
        separatorColor: Color.black.opacity(0.12),
        doneCardOpacity: 0.5,
        cardCornerRadius: 8,
        useMaterial: false
    )
}
