import SpriteKit

/// Toplanabilir altın. Sürekli nabız gibi atar, toplanınca büyüyüp söner.
final class CoinNode: SKNode {

    let radius: CGFloat

    init(radius: CGFloat) {
        self.radius = radius
        super.init()

        let glowDiameter = radius * 5
        let glow = SKSpriteNode(texture: TextureFactory.softCircle(diameter: glowDiameter, color: Palette.coin))
        glow.size = CGSize(width: glowDiameter, height: glowDiameter)
        glow.alpha = 0.45
        glow.blendMode = .add
        glow.zPosition = -1
        addChild(glow)

        let disc = SKShapeNode(circleOfRadius: radius)
        disc.fillColor = Palette.coin
        disc.strokeColor = .white
        disc.lineWidth = 1.5
        addChild(disc)

        let pulse = SKAction.sequence([
            .scale(to: 1.12, duration: 0.5),
            .scale(to: 0.94, duration: 0.5)
        ])
        pulse.timingMode = .easeInEaseOut
        run(.repeatForever(pulse))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) kullanılmıyor") }

    func collect() {
        removeAllActions()
        run(.sequence([
            .group([.scale(to: 2.2, duration: 0.22), .fadeOut(withDuration: 0.22)]),
            .removeFromParent()
        ]))
    }
}
