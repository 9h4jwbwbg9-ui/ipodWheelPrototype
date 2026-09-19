import SwiftUI
import UIKit

enum ThemePreset: String, CaseIterable, Identifiable {
    case classicWhite = "Classic White"
    case classicBlack = "Classic Black"
    case blue = "Blue"
    case greenScreen = "Green Screen"
    case amber = "Amber"

    var id: String { rawValue }

    var colors: (body: Color, wheel: Color, screen: Color, text: Color, highlight: Color) {
        switch self {
        case .classicWhite:
            return (.white, Color(hex: "#D7D7D7"), Color(hex: "#F2F2F2"), .black, Color(hex: "#C9C9C9"))
        case .classicBlack:
            return (Color(hex: "#222222"), Color(hex: "#BDBDBD"), Color(hex: "#111111"), .white, Color(hex: "#444444"))
        case .blue:
            return (Color(hex: "#3B82F6"), Color(hex: "#D8E6FF"), Color(hex: "#0D1B2A"), .white, Color(hex: "#2563EB"))
        case .greenScreen:
            return (Color(hex: "#D5D8C8"), Color(hex: "#B8BBAA"), Color(hex: "#D8E6B8"), Color(hex: "#183018"), Color(hex: "#AFCB70"))
        case .amber:
            return (Color(hex: "#D8D0BE"), Color(hex: "#BEB5A3"), Color(hex: "#2B2116"), Color(hex: "#FFD78A"), Color(hex: "#9A6B2F"))
        }
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    var hexString: String {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return "#FFFFFF" }
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
