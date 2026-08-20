import SpriteKit

/// Suda yüzen kütük. Alçak ve geniş — kolay bir zıplama.
final class DriftwoodNode: ObstacleNode {

    private var length: CGFloat = 0
    private let thickness: CGFloat = 24

    override var verticalOffset: CGFloat { thickness * 0.15 }

    override var localCollisionShapes: [CollisionShape] {
        [.rect(CGRect(x: -length / 2, y: -thickness * 0.30, width: length, height: thickness * 0.85))]
    }

    func build(length: CGFloat) {
        self.length = length
        visual.removeAllChildren()

        let log = SKShapeNode(rectOf: CGSize(width: length, height: thickness), cornerRadius: thickness / 2)
        log.fillColor = Palette.driftwood
        log.strokeColor = Palette.hullDark
        log.lineWidth = 2
        visual.addChild(log)

        for offset in [-thickness * 0.20, thickness * 0.16] {
            let grain = SKShapeNode(rectOf: CGSize(width: length * 0.78, height: 1.5), cornerRadius: 1)
            grain.fillColor = Palette.hullDark
            grain.strokeColor = .clear
            grain.alpha = 0.45
            grain.position = CGPoint(x: 0, y: offset)
            visual.addChild(grain)
        }

        // Kütükten fışkıran birkaç dal.
        for (dx, angle) in [(-length * 0.22, CGFloat(0.9)), (length * 0.26, CGFloat(-1.1))] {
            let branch = SKShapeNode(rectOf: CGSize(width: 3, height: thickness * 1.1), cornerRadius: 1.5)
            branch.fillColor = Palette.driftwood
            branch.strokeColor = Palette.hullDark
            branch.lineWidth = 1
            branch.position = CGPoint(x: dx, y: thickness * 0.5)
            branch.zRotation = angle
            visual.addChild(branch)
        }

        // Önünde biriken köpük.
        let foam = SKShapeNode(ellipseOf: CGSize(width: length * 1.05, height: thickness * 0.35))
        foam.fillColor = .clear
        foam.strokeColor = Palette.foam
        foam.lineWidth = 2
        foam.alpha = 0.5
        foam.position = CGPoint(x: 0, y: -thickness * 0.35)
        visual.addChild(foam)
    }
}
