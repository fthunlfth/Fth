import SpriteKit

/// İki şamandıra arasına gerilmiş balık ağı. Geniş bir bariyer;
/// oyunun ilerleyen dakikalarında koridoru gerçekten daraltıyor.
final class FishingNetNode: ObstacleNode {

    private var span: CGFloat = 160
    private let thickness = Tuning.netThickness

    override var localCollisionShapes: [CollisionShape] {
        [.rect(CGRect(x: -span / 2, y: -thickness / 2, width: span, height: thickness))]
    }

    func build(span: CGFloat) {
        self.span = span
        visual.removeAllChildren()

        // Ağın kendisi: çapraz örgü.
        let mesh = CGMutablePath()
        let step: CGFloat = 14
        var x = -span / 2
        while x < span / 2 {
            mesh.move(to: CGPoint(x: x, y: -thickness / 2))
            mesh.addLine(to: CGPoint(x: min(x + step, span / 2), y: thickness / 2))
            mesh.move(to: CGPoint(x: min(x + step, span / 2), y: -thickness / 2))
            mesh.addLine(to: CGPoint(x: x, y: thickness / 2))
            x += step
        }
        let meshNode = SKShapeNode(path: mesh)
        meshNode.strokeColor = Palette.net
        meshNode.lineWidth = 1.5
        meshNode.alpha = 0.85
        visual.addChild(meshNode)

        // Üst ve alt halatlar.
        for y in [-thickness / 2, thickness / 2] {
            let rope = SKShapeNode(rectOf: CGSize(width: span, height: 2.5), cornerRadius: 1.25)
            rope.fillColor = Palette.net
            rope.strokeColor = .clear
            rope.position = CGPoint(x: 0, y: y)
            visual.addChild(rope)
        }

        // Uçlardaki şamandıralar.
        for side in [CGFloat(-1), 1] {
            let buoy = SKShapeNode(circleOfRadius: thickness * 0.55)
            buoy.fillColor = Palette.buoy
            buoy.strokeColor = Palette.deepShadow
            buoy.lineWidth = 1.5
            buoy.position = CGPoint(x: side * span / 2, y: 0)
            visual.addChild(buoy)

            let band = SKShapeNode(rectOf: CGSize(width: thickness * 1.1, height: 3), cornerRadius: 1.5)
            band.fillColor = Palette.foam
            band.strokeColor = .clear
            band.position = buoy.position
            visual.addChild(band)
        }
    }
}
