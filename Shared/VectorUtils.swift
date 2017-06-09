import CoreGraphics

let π = CGFloat.pi

extension CGVector {
    
    init(from: CGPoint, to: CGPoint) {
        self.init(dx: to.x - from.x, dy: to.y - from.y)
    }
    
    func cross(_ other: CGVector) -> CGFloat {
        return dx * other.dy - dy * other.dx
    }
    
    var length: CGFloat {
        return hypot(dx, dy)
    }
    
    var arg: CGFloat {
        return atan2(dy, dx)
    }
}
