import SpriteKit

/// Yüzeydeki girdap. Alçak ama çok geniş — kısa bir zıplama yetmiyor,
/// tam kenarından ve basılı tutarak atlamak gerekiyor.
final class WhirlpoolNode: ObstacleNode {

    private var width: CGFloat = 150

    override var verticalOffset: CGFloat { -6 }

    override var localCollisionShapes: [CollisionShape] {
        [.rect(CGRect(x: -width * 0.42, y: -4, width: width * 0.84, height: 22))]
    }

    func build(width: CGFloat) {
        self.width = width
        visual.removeAllChildren()

        // Suyun çöktüğü karanlık çukur.
        let well = SKShapeNode(ellipseOf: CGSize(width: width, height: width * 0.30))
        well.fillColor = Palette.whirlpool
        well.strokeColor = .clear
        well.alpha = 0.75
        visual.addChild(well)

        // İç içe köpük halkaları — yandan bakınca basık elipsler.
        for index in 0..<3 {
            let ratio = 1 - CGFloat(index) * 0.28
            let ring = SKShapeNode(ellipseOf: CGSize(width: width * 0.82 * ratio,
                                                     height: width * 0.24 * ratio))
            ring.fillColor = .clear
            ring.strokeColor = Palette.foam
            ring.lineWidth = 2.5 - CGFloat(index) * 0.5
            ring.alpha = 0.25 + ratio * 0.3
            ring.position = CGPoint(x: 0, y: -CGFloat(index) * 3)
            visual.addChild(ring)

            // Dönüyormuş hissi: halkalar yatay olarak sıkışıp açılıyor.
            let swirl = SKAction.sequence([
                .scaleX(to: 0.82, duration: 0.7 + Double(index) * 0.2),
                .scaleX(to: 1.0, duration: 0.7 + Double(index) * 0.2)
            ])
            swirl.timingMode = .easeInEaseOut
            ring.run(.repeatForever(swirl))
        }

        // Ortadaki göz.
        let eye = SKShapeNode(ellipseOf: CGSize(width: width * 0.2, height: width * 0.07))
        eye.fillColor = Palette.whirlpool
        eye.strokeColor = Palette.foam
        eye.lineWidth = 1.5
        eye.alpha = 0.9
        eye.position = CGPoint(x: 0, y: -4)
        visual.addChild(eye)
    }
}
