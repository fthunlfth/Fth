import SpriteKit

/// Girdap. Dokunmak öldürmez — asıl tehlike, seni yavaşça gözüne doğru çekmesi.
/// Çekim yarıçapı içinde kaldıkça kayık merkeze kayar ve dönmeye başlar;
/// gözüne girersen devrilirsin.
final class WhirlpoolNode: ObstacleNode {

    private let pullRadius = Tuning.whirlpoolPullRadius
    private let coreRadius = Tuning.whirlpoolCoreRadius

    /// Girdabın gövdesi çarpışma yapmaz; sadece çekirdeği öldürür.
    override var localCollisionShapes: [CollisionShape] { [] }

    override var lethalCore: CollisionShape? {
        .circle(center: .zero, radius: coreRadius)
    }

    func build() {
        visual.removeAllChildren()

        // Dışa doğru sönümlenen karanlık çukur.
        let well = SKSpriteNode(texture: TextureFactory.softCircle(
            diameter: pullRadius * 2, color: Palette.whirlpool))
        well.size = CGSize(width: pullRadius * 2, height: pullRadius * 2)
        well.alpha = 0.75
        visual.addChild(well)

        // İç içe dönen köpük halkaları.
        let ringCount = 4
        for index in 0..<ringCount {
            let ratio = 1 - CGFloat(index) / CGFloat(ringCount)
            let ring = SKShapeNode(path: WhirlpoolNode.spiralPath(
                maxRadius: pullRadius * 0.85 * ratio,
                turns: 1.35))
            ring.strokeColor = Palette.foam
            ring.lineWidth = 2.5 - CGFloat(index) * 0.4
            ring.fillColor = .clear
            ring.alpha = 0.20 + ratio * 0.35
            ring.lineCap = .round
            visual.addChild(ring)

            let duration = 1.4 + Double(index) * 0.5
            ring.run(.repeatForever(.rotate(byAngle: -.pi * 2, duration: duration)))
        }

        // Ölümcül göz.
        let eye = SKShapeNode(circleOfRadius: coreRadius)
        eye.fillColor = Palette.deepShadow
        eye.strokeColor = Palette.foam
        eye.lineWidth = 2
        eye.alpha = 0.9
        visual.addChild(eye)

        visual.run(.repeatForever(.rotate(byAngle: -.pi * 2, duration: 2.6)))
    }

    override func horizontalPull(towards point: CGPoint) -> CGFloat {
        let dx = position.x - point.x
        let dy = position.y - point.y
        let distance = sqrt(dx * dx + dy * dy)
        guard distance < pullRadius, distance > 0.001 else { return 0 }

        // Merkeze yaklaştıkça kuvvetlenir; kenarda sıfıra iner.
        let falloff = 1 - distance / pullRadius
        return (dx / distance) * Tuning.whirlpoolPullStrength * falloff * falloff
    }

    /// Kayığın girdabın etkisinde ne kadar olduğunu 0...1 arasında verir.
    func influence(at point: CGPoint) -> CGFloat {
        let dx = position.x - point.x
        let dy = position.y - point.y
        let distance = sqrt(dx * dx + dy * dy)
        guard distance < pullRadius else { return 0 }
        return 1 - distance / pullRadius
    }

    private static func spiralPath(maxRadius: CGFloat, turns: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let steps = 90
        for step in 0...steps {
            let t = CGFloat(step) / CGFloat(steps)
            let angle = t * .pi * 2 * turns
            let radius = maxRadius * t
            let point = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            if step == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        return path
    }
}
