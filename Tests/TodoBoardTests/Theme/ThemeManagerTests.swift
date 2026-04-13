import Foundation
import SwiftUI
import Testing
@testable import TodoBoard

@MainActor
struct ThemeManagerTests {
    @Test
    func saveToConfigPersistsCustomAccentColor() {
        let manager = ThemeManager(config: .default)
        manager.customAccentColor = Color(hex: "#FF3366")

        let saved = manager.saveToConfig()

        #expect(saved.theme.accentColor == "#FF3366")
    }
}
