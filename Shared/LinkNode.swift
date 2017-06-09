import SpriteKit

class LinkNode: SKShapeNode {
    static let narrowWidth: CGFloat = 2
    static let wideWidth : CGFloat = 6
    
    let pitch: CGFloat
    
    init(pitch: CGFloat) {
        self.pitch = pitch
        super.init()
        
        let phi = asin(LinkNode.narrowWidth / LinkNode.wideWidth)
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: -pitch/2, y: 0), radius: LinkNode.wideWidth/2,
                    startAngle: phi, endAngle: 2 * π - phi, clockwise: false)
        path.addLine(to: CGPoint(x: pitch/2, y: -LinkNode.narrowWidth/2))
        path.addArc(center: CGPoint(x: pitch/2, y: 0), radius: LinkNode.narrowWidth/2,
                    startAngle: -π/2, endAngle: π/2, clockwise: false)
        path.closeSubpath()
        self.path = path
        self.fillColor = .black
        self.lineWidth = 0
        self.strokeColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveTo(leftPin: CGPoint, rightPin: CGPoint) {
        position = CGPoint(x: (leftPin.x + rightPin.x)/2,
                           y: (leftPin.y + rightPin.y)/2)
        zRotation = CGVector(from: leftPin, to: rightPin).arg
    }
    
}
