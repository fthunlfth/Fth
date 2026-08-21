import SpriteKit

/// Zincirinden boşalmış deniz mayını. Dalgayla birlikte aşağı yukarı
/// süzülüyor, bu yüzden yüksekliği kestirmek zor: aynı yerde iki kez
/// aynı zıplama işe yaramıyor.
final class SeaMineNode: ObstacleNode {

    private let radius: CGFloat = 24
    private let floatAmplitude: CGFloat = 26
    private var phase: CGFloat = 0
    private var speed: CGFloat = 1.6

    override var verticalOffset: CGFloat {
        radius * 0.9 + sin(phase) * floatAmplitude
    }

    override var localCollisionShapes: [CollisionShape] {
        [.circle(center: .zero, radius: radius * 0.92)]
    }

    func build(bobSpeed: CGFloat) {
        speed = bobSpeed
        phase = .random(in: 0...(.pi * 2))
        visual.removeAllChildren()

        // Dikenler.
        for index in 0..<10 {
            let angle = CGFloat(index) / 10 * .pi * 2
            let spike = CGMutablePath()
            spike.move(to: CGPoint(x: cos(angle - 0.14) * radius, y: sin(angle - 0.14) * radius))
            spike.addLine(to: CGPoint(x: cos(angle) * radius * 1.42, y: sin(angle) * radius * 1.42))
            spike.addLine(to: CGPoint(x: cos(angle + 0.14) * radius, y: sin(angle + 0.14) * radius))
            spike.closeSubpath()
            let node = SKShapeNode(path: spike)
            node.fillColor = Palette.mineSpike
            node.strokeColor = Palette.mine
            node.lineWidth = 1
            visual.addChild(node)
        }

        let shell = SKShapeNode(circleOfRadius: radius)
        shell.fillColor = Palette.mine
        shell.strokeColor = Palette.mineSpike
        shell.lineWidth = 2
        visual.addChild(shell)

        // Gövdedeki ışık yansıması.
        let sheen = SKShapeNode(ellipseOf: CGSize(width: radius * 0.7, height: radius * 0.4))
        sheen.fillColor = Palette.mineSpike
        sheen.strokeColor = .clear
        sheen.alpha = 0.5
        sheen.position = CGPoint(x: -radius * 0.3, y: radius * 0.35)
        sheen.zRotation = 0.5
        visual.addChild(sheen)

        // Yanıp sönen kırmızı uyarı ışığı.
        let lamp = SKShapeNode(circleOfRadius: radius * 0.22)
        lamp.fillColor = Palette.mineLight
        lamp.strokeColor = .white
        lamp.lineWidth = 1
        lamp.position = CGPoint(x: 0, y: radius * 0.1)
        visual.addChild(lamp)

        let blink = SKAction.sequence([
            .fadeAlpha(to: 0.25, duration: 0.4),
            .fadeAlpha(to: 1.0, duration: 0.4)
        ])
        lamp.run(.repeatForever(blink))
    }

    override func advance(deltaTime: TimeInterval) {
        phase += speed * CGFloat(deltaTime)
    }
}
