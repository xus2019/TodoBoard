import SwiftUI

private struct ThemePaletteKey: EnvironmentKey {
    static let defaultValue = MoonlightTheme.palette
}

extension EnvironmentValues {
    var appTheme: ThemePalette {
        get { self[ThemePaletteKey.self] }
        set { self[ThemePaletteKey.self] = newValue }
    }
}
