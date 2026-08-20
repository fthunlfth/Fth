import SpriteKit

/// Toplanabilir deniz yıldızı. Dönerek yüzer, toplanınca büyüyüp söner.
final class StarfishNode: SKNode {

    let radius: CGFloat
    /// Dünya koordinatındaki yeri; ekran konumu kameradan hesaplanıyor.
    var worldX: CGFloat = 0

    init(radius: CGFloat) {
        self.radius = radius
        super.init()

        let glow = SKSpriteNode(texture: TextureFactory.softCircle(
            diameter: radius * 4.5, color: Palette.starfish))
        glow.size = CGSize(width: radius * 4.5, height: radius * 4.5)
        glow.alpha = 0.4
        glow.blendMode = .add
        addChild(glow)

        let star = SKShapeNode(path: StarfishNode.starPath(radius: radius))
        star.fillColor = Palette.starfish
        star.strokeColor = .white
        star.lineWidth = 1.5
        star.lineJoin = .round
        addChild(star)

        run(.repeatForever(.rotate(byAngle: .pi * 2, duration: 4.5)))

        let pulse = SKAction.sequence([
            .scale(to: 1.12, duration: 0.55),
            .scale(to: 0.92, duration: 0.55)
        ])
        pulse.timingMode = .easeInEaseOut
        run(.repeatForever(pulse))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) kullanılmıyor") }

    func collect() {
        removeAllActions()
        run(.sequence([
            .group([.scale(to: 2.3, duration: 0.24), .fadeOut(withDuration: 0.24)]),
            .removeFromParent()
        ]))
    }

    /// Beş kollu, kolları yuvarlatılmış deniz yıldızı silueti.
    private static func starPath(radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let points = 5
        let innerRadius = radius * 0.46
        for index in 0..<(points * 2) {
            let angle = -.pi / 2 + (CGFloat(index) / CGFloat(points * 2)) * .pi * 2
            let distance = index.isMultiple(of: 2) ? radius : innerRadius
            let point = CGPoint(x: cos(angle) * distance, y: sin(angle) * distance)
            if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}
