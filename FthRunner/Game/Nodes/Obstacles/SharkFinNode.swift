import SpriteKit

/// Suyu yaran sırt yüzgeci. Kayığa doğru yaklaştığı için zamanlaması zor.
final class SharkFinNode: ObstacleNode {

    private let finHeight: CGFloat = 46
    private let finWidth: CGFloat = 40
    /// Kaydırmanın üstüne eklenen yaklaşma hızı.
    private var closingSpeed: CGFloat = 70

    override var localCollisionShapes: [CollisionShape] {
        [.rect(CGRect(x: -finWidth * 0.30, y: 0, width: finWidth * 0.62, height: finHeight * 0.88))]
    }

    func build(closingSpeed: CGFloat) {
        self.closingSpeed = closingSpeed
        visual.removeAllChildren()

        // Su altındaki gövde gölgesi.
        let shadow = SKShapeNode(ellipseOf: CGSize(width: finWidth * 2.6, height: finHeight * 0.42))
        shadow.fillColor = Palette.sharkDark
        shadow.strokeColor = .clear
        shadow.alpha = 0.4
        shadow.position = CGPoint(x: -finWidth * 0.3, y: -finHeight * 0.16)
        visual.addChild(shadow)

        // Yüzgeç.
        let fin = CGMutablePath()
        fin.move(to: CGPoint(x: -finWidth * 0.5, y: 0))
        fin.addQuadCurve(to: CGPoint(x: finWidth * 0.16, y: finHeight),
                         control: CGPoint(x: -finWidth * 0.1, y: finHeight * 0.72))
        fin.addQuadCurve(to: CGPoint(x: finWidth * 0.42, y: 0),
                         control: CGPoint(x: finWidth * 0.40, y: finHeight * 0.42))
        fin.closeSubpath()
        let finNode = SKShapeNode(path: fin)
        finNode.fillColor = Palette.shark
        finNode.strokeColor = Palette.sharkDark
        finNode.lineWidth = 2
        finNode.lineJoin = .round
        visual.addChild(finNode)

        // Yüzgecin ardındaki köpük izi.
        let wake = SKShapeNode(path: {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -finWidth * 0.5, y: 2))
            path.addQuadCurve(to: CGPoint(x: -finWidth * 2.0, y: 6),
                              control: CGPoint(x: -finWidth * 1.2, y: 12))
            return path
        }())
        wake.strokeColor = Palette.foam
        wake.lineWidth = 2.5
        wake.alpha = 0.55
        wake.lineCap = .round
        visual.addChild(wake)

        // Yüzerken sağa sola kıvrılma.
        visual.run(.repeatForever(.sequence([
            .rotate(toAngle: 0.12, duration: 0.45),
            .rotate(toAngle: -0.12, duration: 0.45)
        ])))
    }

    override func advance(deltaTime: TimeInterval) {
        worldX -= closingSpeed * CGFloat(deltaTime)
    }
}
