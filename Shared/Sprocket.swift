import CoreGraphics

struct Sprocket {
    let center: CGPoint
    let radius: CGFloat
    let teeth: Int
    
    var clockwise: Bool!
    var prevAngle: CGFloat!
    var nextAngle: CGFloat!
    var prevPoint: CGPoint!
    var nextPoint: CGPoint!
    
    init(center: CGPoint, radius: CGFloat) {
        self.center = center
        self.radius = radius
        self.teeth = Int((radius/2).rounded())
    }
    
    init(_ triplet: (x: CGFloat, y: CGFloat, r: CGFloat)) {
        self.init(center: CGPoint(x: triplet.x, y: triplet.y), radius: triplet.r)
    }
    
    // Normalize angles such that
    //     0 <= prevAngle < 2π
    // and
    //     prevAngle <= nextAngle < prevAngle + 2π  (if rotating counter-clockwise)
    //     prevAngle - 2π < nextAngle <= prevAngle  (if rotating clockwise)
    mutating func normalizeAngles() {
        prevAngle = prevAngle.truncatingRemainder(dividingBy: 2 * π)
        nextAngle = nextAngle.truncatingRemainder(dividingBy: 2 * π)
        while prevAngle < 0 {
            prevAngle = prevAngle + 2 * π
        }
        if clockwise {
            while nextAngle > prevAngle {
                nextAngle = nextAngle - 2 * π
            }
        } else {
            while nextAngle < prevAngle {
                nextAngle = nextAngle + 2 * π
            }
        }
    }
    
    mutating func computeTangentPoints() {
        prevPoint = CGPoint(x: center.x + radius * cos(prevAngle),
                            y: center.y + radius * sin(prevAngle))
        nextPoint = CGPoint(x: center.x + radius * cos(nextAngle),
                            y: center.y + radius * sin(nextAngle))
    }
}
