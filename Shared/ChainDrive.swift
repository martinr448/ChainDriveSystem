import CoreGraphics

struct ChainDrive {
    
    var sprockets: [Sprocket]
    
    var length: CGFloat!
    var period: CGFloat!
    var linkCount: Int!
    var accumLength: [(CGFloat, CGFloat)]!
    
    init(sprockets: [Sprocket]) {
        self.sprockets = sprockets
        
        computeSprocketData()
        computeChainLength()
    }
    
    init(_ triplets: [(CGFloat, CGFloat, CGFloat)]) {
        self.init(sprockets: triplets.map(Sprocket.init))
    }
    
    mutating func computeSprocketData() {
        
        // Compute rotation directions:
        for i in 0..<sprockets.count {
            let j = (i + 1) % sprockets.count
            let k = (j + 1) % sprockets.count
            
            let v1 = CGVector(from: sprockets[j].center, to: sprockets[i].center)
            let v2 = CGVector(from: sprockets[j].center, to: sprockets[k].center)
            sprockets[j].clockwise = v1.cross(v2) > 0
        }
        if !sprockets[0].clockwise {
            sprockets[1..<sprockets.count].reverse()
            for i in 0..<sprockets.count {
                sprockets[i].clockwise = !sprockets[i].clockwise
            }
        }
        
        // Compute tangent angles:
        for i in 0..<sprockets.count {
            let j = (i + 1) % sprockets.count
            
            let v = CGVector(from: sprockets[i].center, to: sprockets[j].center)
            let d = v.length
            let a = v.arg
            if sprockets[i].clockwise == sprockets[j].clockwise {
                var phi = acos((sprockets[i].radius - sprockets[j].radius)/d)
                if !sprockets[i].clockwise {
                    phi = -phi
                }
                sprockets[i].nextAngle = a + phi
                sprockets[j].prevAngle = a + phi
            } else {
                var phi = acos((sprockets[i].radius + sprockets[j].radius)/d)
                if !sprockets[i].clockwise {
                    phi = -phi
                }
                sprockets[i].nextAngle = a + phi
                sprockets[j].prevAngle = a + phi - π
            }
        }
        
        // Normalize angles and compute tangent points:
        for i in 0..<sprockets.count {
            sprockets[i].normalizeAngles()
            sprockets[i].computeTangentPoints()
        }
    }
    
    mutating func computeChainLength() {
        accumLength = []
        length = 0
        for i in 0..<sprockets.count {
            let j = (i + 1) % sprockets.count
            let l1 = length + abs(sprockets[i].nextAngle - sprockets[i].prevAngle) * sprockets[i].radius
            let l2 = l1 + CGVector(from: sprockets[i].nextPoint, to: sprockets[j].prevPoint).length
            accumLength.append((l1, l2))
            length = l2
        }
        
        let count = Int(length / (4 * π))
        let p1 = length / CGFloat(count)
        let p2 = length / CGFloat(count + 1)
        if abs(p1 - 4 * π) <= abs(p2 - 4 * π) {
            period = p1
            linkCount = count
        } else {
            period = p2
            linkCount = count + 1
        }
        
    }
    
    func linkCoordinatesAndPhases(offset: CGFloat) -> ([CGPoint], [CGFloat]) {
        var coords: [CGPoint] = []
        var phases: [CGFloat] = []
        var offset = offset
        var total = offset
        var i = 0
        
        repeat {
            let j = (i + 1) % sprockets.count
            let s: CGFloat = sprockets[i].clockwise ? -1 : 1
            
            var phi = sprockets[i].prevAngle + s*offset / sprockets[i].radius
            phases.append(phi)
            while total <= accumLength[i].0 && coords.count < linkCount {
                coords.append(CGPoint(x: sprockets[i].center.x + cos(phi) * sprockets[i].radius,
                                      y: sprockets[i].center.y + sin(phi) * sprockets[i].radius))
                phi += s * period / sprockets[i].radius
                total += period
            }
            
            var d = total - accumLength[i].0
            let v = CGVector(from: sprockets[i].nextPoint, to: sprockets[j].prevPoint)
            while total <= accumLength[i].1 && coords.count < linkCount {
                coords.append(CGPoint(x: sprockets[i].nextPoint.x + d * v.dx / v.length,
                                      y: sprockets[i].nextPoint.y + d * v.dy / v.length))
                d += period
                total += period
            }
            
            offset = total - accumLength[i].1
            i = j
        } while coords.count < linkCount
        
        return (coords, phases)
    }
    
}
