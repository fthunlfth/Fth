import SpriteKit

/// Uçan balık. Sudan fırlayıp yay çizerek iniyor, sonra tekrar sıçrıyor —
/// hem yatayda yaklaşıyor hem de yüksekliği sürekli değişiyor.
final class FlyingFishNode: ObstacleNode {

    private let length: CGFloat = 46
    private let bodyHeight: CGFloat = 20
    /// Sıçrama yayının tepesi.
    private let arcHeight: CGFloat = 118
    /// Bir sıçramanın süresi.
    private let hopDuration: CGFloat = 1.15
    private var time: CGFloat = 0
    private var closingSpeed: CGFloat = 60

    override var verticalOffset: CGFloat {
        // Ardışık yarım sinüsler: su üstünde yay, suya değince yeni sıçrama.
        let t = time.truncatingRemainder(dividingBy: hopDuration) / hopDuration
        return sin(t * .pi) * arcHeight
    }

    override var localCollisionShapes: [CollisionShape] {
        [.rect(CGRect(x: -length * 0.34, y: -bodyHeight * 0.4,
                      width: length * 0.68, height: bodyHeight * 0.8))]
    }

    func build(closingSpeed: CGFloat) {
        self.closingSpeed = closingSpeed
        time = .random(in: 0...hopDuration)
        visual.removeAllChildren()

        // Kanat gibi açılan geniş göğüs yüzgeçleri.
        for side in [CGFloat(-1), 1] {
            let fin = SKShapeNode(ellipseOf: CGSize(width: length * 0.62, height: bodyHeight * 0.42))
            fin.fillColor = Palette.flyingFin
            fin.strokeColor = Palette.flyingFish
            fin.lineWidth = 1
            fin.alpha = 0.9
            fin.position = CGPoint(x: -length * 0.04, y: side * bodyHeight * 0.36)
            fin.zRotation = side * 0.30
            visual.addChild(fin)
        }

        let body = SKShapeNode(ellipseOf: CGSize(width: length, height: bodyHeight))
        body.fillColor = Palette.flyingFish
        body.strokeColor = Palette.sharkDark
        body.lineWidth = 1.5
        visual.addChild(body)

        // Çatal kuyruk.
        let tail = CGMutablePath()
        tail.move(to: CGPoint(x: -length * 0.42, y: 0))
        tail.addLine(to: CGPoint(x: -length * 0.68, y: bodyHeight * 0.5))
        tail.addLine(to: CGPoint(x: -length * 0.56, y: 0))
        tail.addLine(to: CGPoint(x: -length * 0.68, y: -bodyHeight * 0.5))
        tail.closeSubpath()
        let tailNode = SKShapeNode(path: tail)
        tailNode.fillColor = Palette.flyingFish
        tailNode.strokeColor = Palette.sharkDark
        tailNode.lineWidth = 1
        visual.addChild(tailNode)

        let eye = SKShapeNode(circleOfRadius: 2.6)
        eye.fillColor = Palette.sharkDark
        eye.strokeColor = .white
        eye.lineWidth = 1
        eye.position = CGPoint(x: length * 0.30, y: bodyHeight * 0.16)
        visual.addChild(eye)
    }

    override func advance(deltaTime: TimeInterval) {
        time += CGFloat(deltaTime)
        worldX -= closingSpeed * CGFloat(deltaTime)

        // Yayın hangi kolundaysa burnu o yöne dönük olsun.
        let t = time.truncatingRemainder(dividingBy: hopDuration) / hopDuration
        let slope = cos(t * .pi)
        visual.zRotation = slope * 0.42
    }
}
