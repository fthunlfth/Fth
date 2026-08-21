import SpriteKit

/// Buzdağı. Kayadan çok daha yüksek — tam zamanında ve parmağı basılı
/// tutarak zıplamak gerekiyor. Buz denizinin imzası.
final class IcebergNode: ObstacleNode {

    private var width: CGFloat = 0
    private var height: CGFloat = 0

    override var localCollisionShapes: [CollisionShape] {
        [.rect(CGRect(x: -width * 0.28, y: 0, width: width * 0.56, height: height * 0.92))]
    }

    func build(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
        visual.removeAllChildren()

        // Su altında kalan kütle — buzdağının görünmeyen kısmı.
        let submerged = SKShapeNode(ellipseOf: CGSize(width: width * 1.9, height: height * 0.34))
        submerged.fillColor = Palette.iceDeep
        submerged.strokeColor = .clear
        submerged.alpha = 0.45
        submerged.position = CGPoint(x: 0, y: -height * 0.08)
        visual.addChild(submerged)

        // Ana kütle: köşeli, tek parça buz.
        let body = CGMutablePath()
        body.move(to: CGPoint(x: -width / 2, y: 0))
        body.addLine(to: CGPoint(x: -width * 0.30, y: height * 0.52))
        body.addLine(to: CGPoint(x: -width * 0.08, y: height * 0.38))
        body.addLine(to: CGPoint(x: width * 0.06, y: height))
        body.addLine(to: CGPoint(x: width * 0.26, y: height * 0.46))
        body.addLine(to: CGPoint(x: width / 2, y: 0))
        body.closeSubpath()
        let bodyNode = SKShapeNode(path: body)
        bodyNode.fillColor = Palette.ice
        bodyNode.strokeColor = Palette.iceDeep
        bodyNode.lineWidth = 2
        bodyNode.lineJoin = .round
        visual.addChild(bodyNode)

        // Gölgede kalan yüz — buza hacim veriyor.
        let facet = CGMutablePath()
        facet.move(to: CGPoint(x: width * 0.06, y: height))
        facet.addLine(to: CGPoint(x: width * 0.26, y: height * 0.46))
        facet.addLine(to: CGPoint(x: width / 2, y: 0))
        facet.addLine(to: CGPoint(x: width * 0.10, y: 0))
        facet.closeSubpath()
        let facetNode = SKShapeNode(path: facet)
        facetNode.fillColor = Palette.iceShade
        facetNode.strokeColor = .clear
        visual.addChild(facetNode)

        // Su hattında kırılan köpük.
        let collar = SKShapeNode(ellipseOf: CGSize(width: width * 1.35, height: height * 0.10))
        collar.fillColor = .clear
        collar.strokeColor = Palette.foam
        collar.lineWidth = 2.5
        collar.alpha = 0.6
        collar.position = CGPoint(x: 0, y: 2)
        visual.addChild(collar)
    }
}
