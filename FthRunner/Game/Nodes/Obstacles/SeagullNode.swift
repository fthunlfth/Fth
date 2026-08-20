import SpriteKit

/// Alçaktan süzülen martı. Tek "zıplama" değil "zıplamama" engeli:
/// yerinde kalırsan altından geçiyorsun, zıplarsan çarpıyorsun.
final class SeagullNode: ObstacleNode {

    private var flyHeight: CGFloat = 120
    private let span: CGFloat = 52

    override var ridesWave: Bool { false }
    override var verticalOffset: CGFloat { flyHeight }
    override var mustDuckUnder: Bool { true }

    override var localCollisionShapes: [CollisionShape] {
        [.rect(CGRect(x: -span * 0.28, y: -14, width: span * 0.56, height: 26))]
    }

    func build(flyHeight: CGFloat) {
        self.flyHeight = flyHeight
        visual.removeAllChildren()

        // Gövde.
        let body = SKShapeNode(ellipseOf: CGSize(width: span * 0.46, height: 17))
        body.fillColor = Palette.seagull
        body.strokeColor = Palette.rockDark
        body.lineWidth = 1.2
        visual.addChild(body)

        // Kuyruk.
        let tail = CGMutablePath()
        tail.move(to: CGPoint(x: -span * 0.20, y: 3))
        tail.addLine(to: CGPoint(x: -span * 0.42, y: 8))
        tail.addLine(to: CGPoint(x: -span * 0.40, y: -3))
        tail.closeSubpath()
        let tailNode = SKShapeNode(path: tail)
        tailNode.fillColor = Palette.seagull
        tailNode.strokeColor = Palette.rockDark
        tailNode.lineWidth = 1
        visual.addChild(tailNode)

        // Baş ve gaga.
        let head = SKShapeNode(circleOfRadius: 7)
        head.fillColor = Palette.seagull
        head.strokeColor = Palette.rockDark
        head.lineWidth = 1.2
        head.position = CGPoint(x: span * 0.24, y: 5)
        visual.addChild(head)

        let beak = CGMutablePath()
        beak.move(to: CGPoint(x: span * 0.29, y: 7))
        beak.addLine(to: CGPoint(x: span * 0.46, y: 3))
        beak.addLine(to: CGPoint(x: span * 0.29, y: 1))
        beak.closeSubpath()
        let beakNode = SKShapeNode(path: beak)
        beakNode.fillColor = Palette.seagullBeak
        beakNode.strokeColor = .clear
        visual.addChild(beakNode)

        let eye = SKShapeNode(circleOfRadius: 1.8)
        eye.fillColor = Palette.rockDark
        eye.strokeColor = .clear
        eye.position = CGPoint(x: span * 0.27, y: 7)
        visual.addChild(eye)

        // Çırpan kanat.
        let wing = SKShapeNode(path: {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -span * 0.06, y: 3))
            path.addQuadCurve(to: CGPoint(x: -span * 0.30, y: 26),
                              control: CGPoint(x: -span * 0.28, y: 12))
            path.addQuadCurve(to: CGPoint(x: span * 0.10, y: 4),
                              control: CGPoint(x: -span * 0.02, y: 16))
            path.closeSubpath()
            return path
        }())
        wing.fillColor = Palette.seagull
        wing.strokeColor = Palette.rockDark
        wing.lineWidth = 1.2
        wing.position = CGPoint(x: 0, y: 2)
        visual.addChild(wing)

        let flap = SKAction.sequence([
            .scaleY(to: 0.25, duration: 0.28),
            .scaleY(to: 1.0, duration: 0.28)
        ])
        flap.timingMode = .easeInEaseOut
        wing.run(.repeatForever(flap))

        // Süzülürken hafif alçalıp yükselme.
        visual.run(.repeatForever(.sequence([
            .moveBy(x: 0, y: 10, duration: 1.1),
            .moveBy(x: 0, y: -10, duration: 1.1)
        ])))
    }
}
