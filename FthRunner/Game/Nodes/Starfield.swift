import SpriteKit

/// Arka plandaki paralaks yıldızlar. Hız arttıkça çizgiye dönüşerek
/// oyuncuya ne kadar hızlandığını hissettirir.
final class Starfield: SKNode {

    private struct Star {
        let node: SKSpriteNode
        let parallax: CGFloat
    }

    private var stars: [Star] = []
    private var areaSize: CGSize = .zero

    func build(size: CGSize, count: Int) {
        removeAllChildren()
        stars.removeAll()
        areaSize = size

        let texture = TextureFactory.softCircle(diameter: 16, color: Palette.star)
        for _ in 0..<count {
            let parallax = CGFloat.random(in: Tuning.starParallaxRange)
            let node = SKSpriteNode(texture: texture)
            // Uzaktakiler küçük ve sönük, yakındakiler büyük ve parlak.
            let scale = 0.14 + parallax * 0.5
            node.size = CGSize(width: 16 * scale, height: 16 * scale)
            node.alpha = 0.25 + parallax
            node.blendMode = .add
            node.position = CGPoint(x: .random(in: 0...size.width),
                                    y: .random(in: 0...size.height))
            addChild(node)
            stars.append(Star(node: node, parallax: parallax))
        }
    }

    func update(deltaTime: TimeInterval, scrollSpeed: CGFloat) {
        guard areaSize.height > 0 else { return }
        let speedRatio = scrollSpeed / Tuning.maxScrollSpeed

        for star in stars {
            star.node.position.y -= scrollSpeed * star.parallax * CGFloat(deltaTime)

            // Hız arttıkça dikey esneme: yıldız çizgiye dönüşür.
            star.node.yScale = 1 + speedRatio * star.parallax * 14

            if star.node.position.y < -20 {
                star.node.position.y = areaSize.height + CGFloat.random(in: 0...40)
                star.node.position.x = .random(in: 0...areaSize.width)
            }
        }
    }
}
