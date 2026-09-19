import Foundation

/// Converts circular finger movement into discrete, iPod-like wheel detents.
struct ClickWheelPhysics {
    let detents: Int
    var sensitivity: Double
    private(set) var accumulatedAngle: Double = 0

    init(detents: Int = 24, sensitivity: Double = 1.0) {
        self.detents = max(8, detents)
        self.sensitivity = max(0.1, sensitivity)
    }

    mutating func reset() {
        accumulatedAngle = 0
    }

    /// Returns the number of detents crossed by the supplied angular delta.
    mutating func consume(deltaAngle: Double) -> Int {
        accumulatedAngle += deltaAngle * sensitivity
        let step = (Double.pi * 2) / Double(detents)
        let count = Int(accumulatedAngle / step)

        if count != 0 {
            accumulatedAngle -= Double(count) * step
        }
        return count
    }
}
