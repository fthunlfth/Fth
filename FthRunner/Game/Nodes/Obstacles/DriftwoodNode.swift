import SpriteKit

/// Suda sürüklenen kütük. Geniş ve yatay; etrafından dolaşmak gerekiyor.
final class DriftwoodNode: ObstacleNode {

    private var length: CGFloat = Tuning.logLength
    private var thickness: CGFloat = Tuning.logThickness

    override var localCollisionShapes: [CollisionShape] {
        [.rect(CGRect(x: -length / 2, y: -thickness / 2, width: length, height: thickness))]
    }

    func build(length: CGFloat) {
        self.length = length
        visual.removeAllChildren()

        let log = SKShapeNode(rectOf: CGSize(width: length, height: thickness),
                              cornerRadius: thickness / 2)
        log.fillColor = Palette.driftwood
        log.strokeColor = Palette.deepShadow
        log.lineWidth = 2
        visual.addChild(log)

        // Boyuna damar çizgileri.
        for offset in [-thickness * 0.22, thickness * 0.18] {
            let grain = SKShapeNode(rectOf: CGSize(width: length * 0.82, height: 1.5), cornerRadius: 1)
            grain.fillColor = Palette.hullDark
            grain.strokeColor = .clear
            grain.alpha = 0.5
            grain.position = CGPoint(x: 0, y: offset)
            visual.addChild(grain)
        }

        // Uçlardaki kesit halkaları.
        for side in [CGFloat(-1), 1] {
            let ring = SKShapeNode(ellipseOf: CGSize(width: thickness * 0.35, height: thickness * 0.8))
            ring.fillColor = Palette.hullLight
            ring.strokeColor = Palette.deepShadow
            ring.lineWidth = 1
            ring.position = CGPoint(x: side * (length / 2 - thickness * 0.18), y: 0)
            visual.addChild(ring)
        }

        // Kütüğün önünde biriken köpük.
        let foam = SKShapeNode(rectOf: CGSize(width: length * 0.92, height: 4), cornerRadius: 2)
        foam.fillColor = Palette.foam
        foam.strokeColor = .clear
        foam.alpha = 0.45
        foam.position = CGPoint(x: 0, y: -thickness * 0.62)
        visual.addChild(foam)

        // Hafif salınım — suda yüzdüğü hissi.
        visual.run(.repeatForever(.sequence([
            .rotate(toAngle: 0.06, duration: 1.6),
            .rotate(toAngle: -0.06, duration: 1.6)
        ])))
    }
}
