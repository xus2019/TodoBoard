import SwiftUI

enum SolarizedTheme {
    static let palette = ThemePalette(
        name: "solarized",
        lightWindowBackground: Color(hex: "#FDF6E3"),
        lightColumnBackground: Color(hex: "#EEE8D5").opacity(0.92),
        lightCardBackground: Color(hex: "#EEE8D5"),
        lightCardHoverBackground: Color(hex: "#FDF6E3"),
        lightDoneCardBackground: Color(hex: "#EEE8D5").opacity(0.7),
        darkWindowBackground: Color(hex: "#002B36"),
        darkColumnBackground: Color(hex: "#073642").opacity(0.92),
        darkCardBackground: Color(hex: "#073642"),
        darkCardHoverBackground: Color(hex: "#0C4352"),
        darkDoneCardBackground: Color(hex: "#073642").opacity(0.7),
        lightTextPrimary: Color(hex: "#073642"),
        lightTextSecondary: Color(hex: "#586E75"),
        lightTextDone: Color(hex: "#93A1A1"),
        darkTextPrimary: Color(hex: "#EEE8D5"),
        darkTextSecondary: Color(hex: "#93A1A1"),
        darkTextDone: Color(hex: "#839496"),
        accentColor: Color(hex: "#268BD2"),
        separatorColor: Color(hex: "#93A1A1").opacity(0.2),
        doneCardOpacity: 0.52,
        cardCornerRadius: 12,
        useMaterial: false
    )
}
