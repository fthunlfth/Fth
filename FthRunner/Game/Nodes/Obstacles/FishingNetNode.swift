import SpriteKit

/// İki şamandıra arasına gerilmiş ağ. Yüksek — tam zamanında ve
/// parmağı basılı tutarak zıplamak gerekiyor.
final class FishingNetNode: ObstacleNode {

    private let netWidth: CGFloat = 54
    private var netHeight: CGFloat = 96

    override var localCollisionShapes: [CollisionShape] {
        [.rect(CGRect(x: -netWidth * 0.34, y: 0, width: netWidth * 0.68, height: netHeight * 0.94))]
    }

    func build(height: CGFloat) {
        netHeight = height
        visual.removeAllChildren()

        // İki direk.
        for side in [CGFloat(-1), 1] {
            let post = SKShapeNode(rectOf: CGSize(width: 5, height: netHeight), cornerRadius: 2.5)
            post.fillColor = Palette.driftwood
            post.strokeColor = Palette.hullDark
            post.lineWidth = 1.5
            post.position = CGPoint(x: side * netWidth * 0.32, y: netHeight / 2)
            visual.addChild(post)
        }

        // Çapraz örgü.
        let mesh = CGMutablePath()
        let step: CGFloat = 15
        var y: CGFloat = 6
        while y < netHeight - 6 {
            let next = min(y + step, netHeight - 6)
            mesh.move(to: CGPoint(x: -netWidth * 0.32, y: y))
            mesh.addLine(to: CGPoint(x: netWidth * 0.32, y: next))
            mesh.move(to: CGPoint(x: netWidth * 0.32, y: y))
            mesh.addLine(to: CGPoint(x: -netWidth * 0.32, y: next))
            y = next
        }
        let meshNode = SKShapeNode(path: mesh)
        meshNode.strokeColor = Palette.net
        meshNode.lineWidth = 1.5
        meshNode.alpha = 0.9
        visual.addChild(meshNode)

        // Tepedeki şamandıra.
        let buoy = SKShapeNode(circleOfRadius: 11)
        buoy.fillColor = Palette.buoy
        buoy.strokeColor = Palette.hullDark
        buoy.lineWidth = 1.5
        buoy.position = CGPoint(x: 0, y: netHeight)
        visual.addChild(buoy)

        let band = SKShapeNode(rectOf: CGSize(width: 22, height: 3.5), cornerRadius: 1.75)
        band.fillColor = Palette.foam
        band.strokeColor = .clear
        band.position = buoy.position
        visual.addChild(band)
    }
}
