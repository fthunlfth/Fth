import SpriteKit

/// Yüzeyde süzülen denizanası. Kubbesi suyun üstünde, dokungaçları altında.
final class JellyfishNode: ObstacleNode {

    private let radius: CGFloat = 26

    override var verticalOffset: CGFloat { radius * 0.55 }

    override var localCollisionShapes: [CollisionShape] {
        [.circle(center: CGPoint(x: 0, y: radius * 0.1), radius: radius * 0.82)]
    }

    func build() {
        visual.removeAllChildren()

        let glowDiameter = radius * 5
        let glow = SKSpriteNode(texture: TextureFactory.softCircle(diameter: glowDiameter, color: Palette.jellyfish))
        glow.size = CGSize(width: glowDiameter, height: glowDiameter)
        glow.alpha = 0.35
        glow.blendMode = .add
        visual.addChild(glow)

        for index in 0..<5 {
            let x = (CGFloat(index) - 2) * radius * 0.32
            let tentacle = SKShapeNode(rectOf: CGSize(width: 3, height: radius * 1.5), cornerRadius: 1.5)
            tentacle.fillColor = Palette.jellyfish
            tentacle.strokeColor = .clear
            tentacle.alpha = 0.8
            tentacle.position = CGPoint(x: x, y: -radius * 0.75)
            visual.addChild(tentacle)

            let sway = SKAction.sequence([
                .rotate(toAngle: 0.2, duration: 0.6 + Double(index) * 0.08),
                .rotate(toAngle: -0.2, duration: 0.6 + Double(index) * 0.08)
            ])
            sway.timingMode = .easeInEaseOut
            tentacle.run(.repeatForever(sway))
        }

        // Kubbe.
        let dome = CGMutablePath()
        dome.addArc(center: .zero, radius: radius, startAngle: 0, endAngle: .pi, clockwise: false)
        dome.addQuadCurve(to: CGPoint(x: radius, y: 0), control: CGPoint(x: 0, y: -radius * 0.5))
        dome.closeSubpath()
        let domeNode = SKShapeNode(path: dome)
        domeNode.fillColor = Palette.jellyfish
        domeNode.strokeColor = .white
        domeNode.lineWidth = 1.5
        domeNode.alpha = 0.92
        visual.addChild(domeNode)

        let pulse = SKAction.sequence([
            .scaleX(to: 1.1, y: 0.9, duration: 0.75),
            .scaleX(to: 0.95, y: 1.08, duration: 0.75)
        ])
        pulse.timingMode = .easeInEaseOut
        domeNode.run(.repeatForever(pulse))
    }
}
