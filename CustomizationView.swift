import SwiftUI

struct CustomizationView: View {
    @EnvironmentObject var settings: PlayerSettings

    var body: some View {
        NavigationStack {
            Form {
                Section("Theme Presets") {
                    ForEach(ThemePreset.allCases) { preset in
                        Button {
                            settings.apply(preset)
                        } label: {
                            HStack {
                                Circle()
                                    .fill(preset.colors.body)
                                    .frame(width: 28, height: 28)
                                    .overlay(Circle().stroke(.secondary.opacity(0.35)))
                                Text(preset.rawValue)
                                Spacer()
                                HStack(spacing: 3) {
                                    Circle().fill(preset.colors.screen).frame(width: 14, height: 14)
                                    Circle().fill(preset.colors.highlight).frame(width: 14, height: 14)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }

                Section("Colors") {
                    ColorPicker("iPod Body", selection: $settings.bodyColor)
                    ColorPicker("Click Wheel", selection: $settings.wheelColor)
                    ColorPicker("Screen", selection: $settings.screenColor)
                    ColorPicker("Text", selection: $settings.textColor)
                    ColorPicker("Highlight", selection: $settings.highlightColor)
                }

                Section("Wheel") {
                    VStack(alignment: .leading) {
                        Text("Haptic Clicks: \(Int(settings.hapticIntensity * 100))%")
                        Slider(value: $settings.hapticIntensity, in: 0...1)
                    }
                    VStack(alignment: .leading) {
                        Text("Wheel Sensitivity: \(settings.wheelSensitivity, specifier: "%.1f")×")
                        Slider(value: $settings.wheelSensitivity, in: 0.5...2.0, step: 0.1)
                    }
                }

                Section {
                    Text("Themes and wheel settings are saved automatically on this iPhone.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Customize")
        }
    }
}
