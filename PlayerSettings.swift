import SwiftUI
import Combine

final class PlayerSettings: ObservableObject {
    @Published var bodyColor: Color { didSet { save(bodyColor, "theme.body") } }
    @Published var wheelColor: Color { didSet { save(wheelColor, "theme.wheel") } }
    @Published var screenColor: Color { didSet { save(screenColor, "theme.screen") } }
    @Published var textColor: Color { didSet { save(textColor, "theme.text") } }
    @Published var highlightColor: Color { didSet { save(highlightColor, "theme.highlight") } }
    @Published var hapticIntensity: Double { didSet { UserDefaults.standard.set(hapticIntensity, forKey: "theme.haptic") } }
    @Published var wheelSensitivity: Double { didSet { UserDefaults.standard.set(wheelSensitivity, forKey: "theme.sensitivity") } }

    init() {
        bodyColor = Self.load("theme.body") ?? .white
        wheelColor = Self.load("theme.wheel") ?? Color(hex: "#D7D7D7")
        screenColor = Self.load("theme.screen") ?? Color(hex: "#F2F2F2")
        textColor = Self.load("theme.text") ?? .black
        highlightColor = Self.load("theme.highlight") ?? Color(hex: "#C9C9C9")
        hapticIntensity = UserDefaults.standard.object(forKey: "theme.haptic") as? Double ?? 0.55
        wheelSensitivity = UserDefaults.standard.object(forKey: "theme.sensitivity") as? Double ?? 1.0
    }

    func apply(_ preset: ThemePreset) {
        bodyColor = preset.colors.body
        wheelColor = preset.colors.wheel
        screenColor = preset.colors.screen
        textColor = preset.colors.text
        highlightColor = preset.colors.highlight
    }

    private func save(_ color: Color, _ key: String) {
        UserDefaults.standard.set(color.hexString, forKey: key)
    }

    private static func load(_ key: String) -> Color? {
        guard let hex = UserDefaults.standard.string(forKey: key) else { return nil }
        return Color(hex: hex)
    }
}
