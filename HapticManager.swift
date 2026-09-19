import Foundation
import CoreHaptics
import UIKit

final class HapticManager {
    private var engine: CHHapticEngine?

    init() { prepare() }

    private func prepare() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            engine = nil
        }
    }

    func click(intensity: Float = 0.5) {
        let value = max(0.05, min(1, intensity))
        guard let engine else {
            UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: CGFloat(value))
            return
        }
        do {
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: value),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.75)
                ],
                relativeTime: 0
            )
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            try engine.makePlayer(with: pattern).start(atTime: 0)
        } catch {}
    }

    func softClick(intensity: Float = 0.25) {
        click(intensity: intensity)
    }
}
