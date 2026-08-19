import SpriteKit

/// Köpek balığı: sırt yüzgeci suyun üstünde, gövdesi altında.
/// Doğduğu noktanın etrafında sağa sola gezinir, bu yüzden koridora dalabilir.
final class SharkNode: ObstacleNode {

    private var length: CGFloat = Tuning.sharkLength
    private var bodyWidth: CGFloat = Tuning.sharkWidth
    private var originX: CGFloat = 0
    private var direction: CGFloat = 1

    override var localCollisionShapes: [CollisionShape] {
        [.rect(CGRect(x: -bodyWidth / 2, y: -length / 2, width: bodyWidth, height: length))]
    }

    func build(originX: CGFloat, direction: CGFloat) {
        self.originX = originX
        self.direction = direction
        visual.removeAllChildren()

        // Suyun altındaki gövde silueti.
        let body = SKShapeNode(ellipseOf: CGSize(width: bodyWidth, height: length))
        body.fillColor = Palette.shark
        body.strokeColor = Palette.deepShadow
        body.lineWidth = 1.5
        body.alpha = 0.9
        visual.addChild(body)

        // Kuyruk
        let tail = CGMutablePath()
        tail.move(to: CGPoint(x: 0, y: -length * 0.45))
        tail.addLine(to: CGPoint(x: -bodyWidth * 0.62, y: -length * 0.72))
        tail.addLine(to: CGPoint(x: 0, y: -length * 0.56))
        tail.addLine(to: CGPoint(x: bodyWidth * 0.62, y: -length * 0.72))
        tail.closeSubpath()
        let tailNode = SKShapeNode(path: tail)
        tailNode.fillColor = Palette.shark
        tailNode.strokeColor = Palette.deepShadow
        tailNode.lineWidth = 1.2
        visual.addChild(tailNode)

        // Yan yüzgeçler
        for side in [CGFloat(-1), 1] {
            let fin = SKShapeNode(ellipseOf: CGSize(width: bodyWidth * 0.8, height: bodyWidth * 0.3))
            fin.fillColor = Palette.shark
            fin.strokeColor = .clear
            fin.position = CGPoint(x: side * bodyWidth * 0.55, y: -length * 0.05)
            fin.zRotation = side * -0.5
            visual.addChild(fin)
        }

        // Açık karın
        let belly = SKShapeNode(ellipseOf: CGSize(width: bodyWidth * 0.45, height: length * 0.6))
        belly.fillColor = Palette.sharkBelly
        belly.strokeColor = .clear
        belly.alpha = 0.55
        belly.position = CGPoint(x: 0, y: -length * 0.05)
        visual.addChild(belly)

        // Sırt yüzgeci — suyun üstünde görünen tek parça, asıl uyarı işareti.
        let fin = CGMutablePath()
        fin.move(to: CGPoint(x: -bodyWidth * 0.42, y: -bodyWidth * 0.1))
        fin.addLine(to: CGPoint(x: bodyWidth * 0.10, y: bodyWidth * 0.95))
        fin.addLine(to: CGPoint(x: bodyWidth * 0.34, y: -bodyWidth * 0.1))
        fin.closeSubpath()
        let finNode = SKShapeNode(path: fin)
        finNode.fillColor = Palette.shark
        finNode.strokeColor = Palette.deepShadow
        finNode.lineWidth = 2
        finNode.position = CGPoint(x: 0, y: length * 0.02)
        visual.addChild(finNode)

        // Yüzgecin dibindeki köpük.
        let splash = SKShapeNode(ellipseOf: CGSize(width: bodyWidth * 1.5, height: bodyWidth * 0.5))
        splash.fillColor = .clear
        splash.strokeColor = Palette.foam
        splash.lineWidth = 2
        splash.alpha = 0.55
        splash.position = CGPoint(x: 0, y: -bodyWidth * 0.1)
        visual.addChild(splash)

        // Gövde kıvrılarak yüzüyormuş gibi.
        visual.run(.repeatForever(.sequence([
            .rotate(toAngle: 0.10, duration: 0.55),
            .rotate(toAngle: -0.10, duration: 0.55)
        ])))
    }

    override func advance(deltaTime: TimeInterval, sceneSize: CGSize) {
        position.x += direction * Tuning.sharkSwimSpeed * CGFloat(deltaTime)

        let leftLimit = max(bodyWidth, originX - Tuning.sharkSwimRange)
        let rightLimit = min(sceneSize.width - bodyWidth, originX + Tuning.sharkSwimRange)
        if position.x <= leftLimit {
            position.x = leftLimit
            direction = 1
        } else if position.x >= rightLimit {
            position.x = rightLimit
            direction = -1
        }
    }
}
