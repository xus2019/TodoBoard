import SwiftUI

protocol AppTheme {
    var name: String { get }
    var lightWindowBackground: Color { get }
    var lightColumnBackground: Color { get }
    var lightCardBackground: Color { get }
    var lightCardHoverBackground: Color { get }
    var lightDoneCardBackground: Color { get }
    var darkWindowBackground: Color { get }
    var darkColumnBackground: Color { get }
    var darkCardBackground: Color { get }
    var darkCardHoverBackground: Color { get }
    var darkDoneCardBackground: Color { get }
    var lightTextPrimary: Color { get }
    var lightTextSecondary: Color { get }
    var lightTextDone: Color { get }
    var darkTextPrimary: Color { get }
    var darkTextSecondary: Color { get }
    var darkTextDone: Color { get }
    var accentColor: Color { get }
    var separatorColor: Color { get }
    var doneCardOpacity: Double { get }
    var cardCornerRadius: CGFloat { get }
    var useMaterial: Bool { get }
}

struct ThemePalette: AppTheme {
    let name: String
    let lightWindowBackground: Color
    let lightColumnBackground: Color
    let lightCardBackground: Color
    let lightCardHoverBackground: Color
    let lightDoneCardBackground: Color
    let darkWindowBackground: Color
    let darkColumnBackground: Color
    let darkCardBackground: Color
    let darkCardHoverBackground: Color
    let darkDoneCardBackground: Color
    let lightTextPrimary: Color
    let lightTextSecondary: Color
    let lightTextDone: Color
    let darkTextPrimary: Color
    let darkTextSecondary: Color
    let darkTextDone: Color
    let accentColor: Color
    let separatorColor: Color
    let doneCardOpacity: Double
    let cardCornerRadius: CGFloat
    let useMaterial: Bool
}
