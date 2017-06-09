import SpriteKit

class SprocketNode: SKShapeNode {
    let radius: CGFloat
    let clockwise: Bool
    let teeth: Int
    
    init(sprocket: Sprocket) {
        self.radius = sprocket.radius
        self.clockwise = sprocket.clockwise
        self.teeth = sprocket.teeth
        super.init()
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: radius - 2, y: 0))
        for i in 0..<teeth {
            let a1 = π * CGFloat(4 * i - 1)/CGFloat(2 * teeth)
            let a2 = π * CGFloat(4 * i + 1)/CGFloat(2 * teeth)
            let a3 = π * CGFloat(4 * i + 3)/CGFloat(2 * teeth)
            path.addArc(center: CGPoint.zero, radius: radius - 2,
                        startAngle: a1, endAngle: a2, clockwise: false)
            path.addArc(center: CGPoint.zero, radius: radius + 2,
                        startAngle: a2, endAngle: a3, clockwise: false)
        }
        path.closeSubpath()
        self.path = path
        
        self.lineWidth = 0
        self.fillColor = SKColor(red: 0x86/255, green: 0x84/255, blue: 0x81/255, alpha: 1) // #868481
        self.strokeColor = .clear
        self.position = sprocket.center
        
        do {
            let path = CGMutablePath()
            path.addEllipse(in: CGRect(x: -3, y: -3, width: 6, height: 6))
            path.addEllipse(in: CGRect(x: -radius + 4.5, y: -radius + 4.5,
                                       width: 2 * radius - 9, height: 2 * radius - 9))
            let node = SKShapeNode(path: path)
            node.fillColor = SKColor(red: 0x64/255, green: 0x63/255, blue: 0x61/255, alpha: 1) // #646361
            node.lineWidth = 0
            node.strokeColor = .clear
            self.addChild(node)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
