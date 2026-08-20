import SpriteKit

/// Sudan çıkan kaya. Üstünden zıplanır; en temel engel.
final class RockNode: ObstacleNode {

    private var width: CGFloat = 0
    private var height: CGFloat = 0

    override var localCollisionShapes: [CollisionShape] {
        [.rect(CGRect(x: -width * 0.34, y: 0, width: width * 0.68, height: height * 0.9))]
    }

    func build(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
        visual.removeAllChildren()

        let rock = SKShapeNode(path: RockNode.silhouette(width: width, height: height))
        rock.fillColor = Palette.rock
        rock.strokeColor = Palette.rockDark
        rock.lineWidth = 2.5
        rock.lineJoin = .round
        visual.addChild(rock)

        // Güneş alan üst yüz.
        let highlight = SKShapeNode(path: RockNode.silhouette(width: width * 0.5, height: height * 0.45))
        highlight.fillColor = Palette.rockLight
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: -width * 0.10, y: height * 0.30)
        visual.addChild(highlight)

        // Su hattında kırılan köpük.
        let collar = SKShapeNode(ellipseOf: CGSize(width: width * 1.25, height: height * 0.16))
        collar.fillColor = .clear
        collar.strokeColor = Palette.foam
        collar.lineWidth = 2.5
        collar.alpha = 0.55
        collar.position = CGPoint(x: 0, y: 2)
        visual.addChild(collar)
    }

    /// Tabanı düz, tepesi köşeli kaya silueti.
    private static func silhouette(width: CGFloat, height: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -width / 2, y: 0))
        path.addLine(to: CGPoint(x: -width * 0.36, y: height * 0.55))
        path.addLine(to: CGPoint(x: -width * 0.12, y: height * 0.42))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: width * 0.22, y: height * 0.58))
        path.addLine(to: CGPoint(x: width * 0.40, y: height * 0.68))
        path.addLine(to: CGPoint(x: width / 2, y: 0))
        path.closeSubpath()
        return path
    }
}
