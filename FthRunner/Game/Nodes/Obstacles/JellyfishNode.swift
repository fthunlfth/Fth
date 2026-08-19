import SpriteKit

/// Denizanası. Yavaş ama sağa sola salınıyor, bu yüzden yerini kestirmek zor.
final class JellyfishNode: ObstacleNode {

    private let radius = Tuning.jellyfishRadius
    private var originX: CGFloat = 0
    private var phase: CGFloat = 0

    override var localCollisionShapes: [CollisionShape] {
        // Şemsiye kısmı ve altındaki dokungaçlar iki ayrı alan.
        [
            .circle(center: .zero, radius: radius * 0.85),
            .rect(CGRect(x: -radius * 0.5, y: -radius * 2.1, width: radius, height: radius * 1.6))
        ]
    }

    func build(originX: CGFloat) {
        self.originX = originX
        self.phase = .random(in: 0...(.pi * 2))
        visual.removeAllChildren()

        // Işıldayan hale.
        let glow = SKSpriteNode(texture: TextureFactory.softCircle(
            diameter: radius * 5, color: Palette.jellyfish))
        glow.size = CGSize(width: radius * 5, height: radius * 5)
        glow.alpha = 0.35
        glow.blendMode = .add
        visual.addChild(glow)

        // Kubbe
        let dome = CGMutablePath()
        dome.addArc(center: .zero, radius: radius, startAngle: 0, endAngle: .pi, clockwise: false)
        dome.addQuadCurve(to: CGPoint(x: radius, y: 0), control: CGPoint(x: 0, y: -radius * 0.55))
        dome.closeSubpath()
        let domeNode = SKShapeNode(path: dome)
        domeNode.fillColor = Palette.jellyfish
        domeNode.strokeColor = .white
        domeNode.lineWidth = 1.5
        domeNode.alpha = 0.9
        visual.addChild(domeNode)

        // Dokungaçlar
        for index in 0..<5 {
            let x = (CGFloat(index) - 2) * radius * 0.34
            let tentacle = SKShapeNode(rectOf: CGSize(width: 2.5, height: radius * 1.7), cornerRadius: 1.25)
            tentacle.fillColor = Palette.jellyfish
            tentacle.strokeColor = .clear
            tentacle.alpha = 0.85
            tentacle.position = CGPoint(x: x, y: -radius * 1.0)
            visual.addChild(tentacle)

            // Her dokungaç farklı fazda dalgalansın.
            let sway = SKAction.sequence([
                .rotate(toAngle: 0.22, duration: 0.7 + Double(index) * 0.09),
                .rotate(toAngle: -0.22, duration: 0.7 + Double(index) * 0.09)
            ])
            sway.timingMode = .easeInEaseOut
            tentacle.run(.repeatForever(sway))
        }

        // Kubbenin nabız gibi büzülüp açılması.
        let pulse = SKAction.sequence([
            .scaleX(to: 1.12, y: 0.9, duration: 0.8),
            .scaleX(to: 0.94, y: 1.08, duration: 0.8)
        ])
        pulse.timingMode = .easeInEaseOut
        domeNode.run(.repeatForever(pulse))
    }

    override func advance(deltaTime: TimeInterval, sceneSize: CGSize) {
        phase += CGFloat(deltaTime) * Tuning.jellyfishSwaySpeed
        let target = originX + sin(phase) * Tuning.jellyfishSwayAmplitude
        position.x = min(max(target, radius), sceneSize.width - radius)
    }
}
