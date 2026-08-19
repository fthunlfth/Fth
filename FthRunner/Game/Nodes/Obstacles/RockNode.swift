import SpriteKit

/// Sudan çıkan kaya. Hareket etmez, en temel engel.
final class RockNode: ObstacleNode {

    private var radius: CGFloat = 0

    override var localCollisionShapes: [CollisionShape] {
        // Görsel taş düzensiz; çarpışma dairesi biraz küçük tutuldu ki haksız hissettirmesin.
        [.circle(center: .zero, radius: radius * 0.82)]
    }

    func build(radius: CGFloat) {
        self.radius = radius
        visual.removeAllChildren()

        // Su altındaki gölge — kayanın suyun içinde devam ettiğini gösteriyor.
        let shadow = SKShapeNode(ellipseOf: CGSize(width: radius * 2.6, height: radius * 1.4))
        shadow.fillColor = Palette.deepShadow
        shadow.strokeColor = .clear
        shadow.alpha = 0.35
        shadow.position = CGPoint(x: 0, y: -radius * 0.35)
        visual.addChild(shadow)

        let rock = SKShapeNode(path: RockNode.jaggedPath(radius: radius))
        rock.fillColor = Palette.rock
        rock.strokeColor = Palette.deepShadow
        rock.lineWidth = 2
        rock.lineJoin = .round
        visual.addChild(rock)

        // Üstteki aydınlık yüzey.
        let highlight = SKShapeNode(path: RockNode.jaggedPath(radius: radius * 0.55))
        highlight.fillColor = Palette.rockLight
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: -radius * 0.15, y: radius * 0.22)
        visual.addChild(highlight)

        // Kayanın etrafında kırılan köpük halkası.
        let collar = SKShapeNode(ellipseOf: CGSize(width: radius * 2.5, height: radius * 1.1))
        collar.fillColor = .clear
        collar.strokeColor = Palette.foam
        collar.lineWidth = 2.5
        collar.alpha = 0.5
        collar.position = CGPoint(x: 0, y: -radius * 0.55)
        visual.addChild(collar)

        visual.zRotation = .random(in: 0...(.pi * 2))
    }

    /// Rastgele köşeli taş silueti.
    private static func jaggedPath(radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let corners = Int.random(in: 7...9)
        for index in 0..<corners {
            let angle = (CGFloat(index) / CGFloat(corners)) * .pi * 2
            let distance = radius * CGFloat.random(in: 0.78...1.0)
            let point = CGPoint(x: cos(angle) * distance, y: sin(angle) * distance)
            if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}
