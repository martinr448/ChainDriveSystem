import SpriteKit

typealias Triples = [(CGFloat, CGFloat, CGFloat)]

// The system from the challenge: https://codereview.meta.stackexchange.com/a/7264 :
let system0: Triples = [(0, 0, 16), (100, 0, 16), (100, 100, 12), (50, 50, 24), (0, 100, 12)]

// Other systems from https://codegolf.stackexchange.com/q/64764:
let system1: Triples = [(0, 0, 26), (120, 0, 26)]
let system2: Triples = [(100, 100, 60), (220, 100, 14)]
let system3: Triples = [(100, 100, 16), (100, 0, 24), (0, 100, 24), (0, 0, 16)]
let system4: Triples = [(0, 0, 60), (44, 140, 16), (-204, 140, 16), (-160, 0, 60), (-112, 188, 12),
                        (-190, 300, 30), (30, 300, 30), (-48, 188, 12)]
let system5: Triples = [(0, 128, 14), (46.17, 63.55, 10), (121.74, 39.55, 14), (74.71, -24.28, 10),
                        (75.24, -103.55, 14), (0, -78.56, 10), (-75.24, -103.55, 14),
                        (-74.71, -24.28, 10), (-121.74, 39.55, 14), (-46.17, 63.55, 10)]
let system6: Triples = [(367, 151, 12), (210, 75, 36), (57, 286, 38), (14, 181, 32), (91, 124, 18),
                        (298, 366, 38), (141, 3, 52), (80, 179, 26), (313, 32, 26), (146, 280, 10),
                        (126, 253, 8), (220, 184, 24), (135, 332, 8), (365, 296, 50), (248, 217, 8),
                        (218, 392, 30)]

class ChainDriveScene: SKScene {
    
    let chainDrive: ChainDrive
    let chainSpeed = 16 * π // speed (points/sec)
    
    var initialTime: TimeInterval!
    var sprocketNodes: [SprocketNode] = []
    var linkNodes: [LinkNode] = []
    
    class func newScene() -> ChainDriveScene {
        let system = ChainDrive(system0)
        return ChainDriveScene(system: system)
    }
    
    init(system: ChainDrive) {
        self.chainDrive = system
        
        let minx = system.sprockets.map { $0.center.x - $0.radius }.min()! - 15
        let miny = system.sprockets.map { $0.center.y - $0.radius }.min()! - 15
        let maxx = system.sprockets.map { $0.center.x + $0.radius }.max()! + 15
        let maxy = system.sprockets.map { $0.center.y + $0.radius }.max()! + 15
        
        super.init(size: CGSize(width: maxx - minx, height: maxy - miny))
        self.anchorPoint = CGPoint(x: -minx/(maxx - minx), y: -miny/(maxy - miny))
        self.scaleMode = .aspectFit
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpScene() {
        
        backgroundColor = .white
        sprocketNodes = chainDrive.sprockets.map(SprocketNode.init)
        for node in sprocketNodes {
            self.addChild(node)
        }
        
        let (coords, _) = chainDrive.linkCoordinatesAndPhases(offset: 0)
        for i in 0..<coords.count {
            let j = (i + 1) % coords.count
            let node = LinkNode(pitch: chainDrive.period)
            node.moveTo(leftPin: coords[i], rightPin: coords[j])
            self.addChild(node)
            linkNodes.append(node)
        }
    }
    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if initialTime == nil {
            initialTime = currentTime
        }
        
        let distance = CGFloat(currentTime - initialTime) * chainSpeed * speed
        let k = Int(distance/chainDrive.period) % linkNodes.count
        let offset = distance.truncatingRemainder(dividingBy: chainDrive.period)
        
        let (coords, phases) = chainDrive.linkCoordinatesAndPhases(offset: offset)
        for i in 0..<linkNodes.count {
            let p1 = coords[i % coords.count]
            let p2 = coords[(i + 1) % coords.count]
            linkNodes[(i + linkNodes.count - k) % linkNodes.count].moveTo(leftPin: p1, rightPin: p2)
        }
        for i in 0..<phases.count {
            sprocketNodes[i].zRotation = phases[i]
        }
    }
}
