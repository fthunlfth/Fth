import SpriteKit

/// Deniz katmanı: dalgalanan su yüzeyi, altındaki derinlik degradesi
/// ve yüzeyde parlayan köpükler. Yüzey her karede `Wave` fonksiyonundan
/// yeniden çiziliyor; kayık da aynı fonksiyona oturuyor.
final class SeaNode: SKNode {

    private let surface = SKShapeNode()
    private let foamLine = SKShapeNode()
    private var sparkles: [SKSpriteNode] = []

    private var areaSize: CGSize = .zero
    private var waterLine: CGFloat = 0

    func build(size: CGSize, waterLine: CGFloat, theme: SkyTheme) {
        removeAllChildren()
        sparkles.removeAll()
        areaSize = size
        self.waterLine = waterLine

        surface.fillColor = theme.seaSurface
        surface.strokeColor = .clear
        surface.zPosition = 0
        addChild(surface)

        // Derinlik: dalga çukurunun altından ekranın dibine kadar.
        let depthTop = waterLine - Tuning.waveAmplitude - Tuning.waveAmplitude2 - 4
        let sprite = SKSpriteNode(texture: TextureFactory.verticalGradient(
            size: CGSize(width: 4, height: max(depthTop, 1)),
            top: theme.seaSurface,
            bottom: theme.seaDeep))
        sprite.anchorPoint = CGPoint(x: 0, y: 1)
        sprite.size = CGSize(width: size.width, height: max(depthTop, 1))
        sprite.position = CGPoint(x: 0, y: depthTop)
        sprite.zPosition = 1
        addChild(sprite)

        foamLine.strokeColor = Palette.foam
        foamLine.lineWidth = 3
        foamLine.alpha = 0.5
        foamLine.fillColor = .clear
        foamLine.zPosition = 2
        addChild(foamLine)

        addSparkles(size: size)
    }

    private func addSparkles(size: CGSize) {
        let texture = TextureFactory.softCircle(diameter: 20, color: Palette.foam)
        for _ in 0..<Tuning.foamCount {
            let node = SKSpriteNode(texture: texture)
            let scale = CGFloat.random(in: 0.25...0.7)
            node.size = CGSize(width: 20 * scale, height: 20 * scale)
            node.alpha = .random(in: 0.15...0.5)
            node.position = CGPoint(x: .random(in: 0...size.width),
                                    y: .random(in: (waterLine - 90)...(waterLine - 6)))
            node.zPosition = 3
            addChild(node)
            sparkles.append(node)
        }
    }

    // MARK: - Döngü

    func update(cameraX: CGFloat, time: TimeInterval, scrollSpeed: CGFloat, deltaTime: TimeInterval) {
        rebuildSurface(cameraX: cameraX, time: time)

        for sparkle in sparkles {
            sparkle.position.x -= scrollSpeed * 0.55 * CGFloat(deltaTime)
            if sparkle.position.x < -20 {
                sparkle.position.x = areaSize.width + CGFloat.random(in: 0...40)
                sparkle.position.y = .random(in: (waterLine - 90)...(waterLine - 6))
            }
        }
    }

    /// Yüzey eğrisini ekran boyunca örnekleyip iki yol kurar:
    /// biri suyu dolduran alan, diğeri üstündeki köpük çizgisi.
    private func rebuildSurface(cameraX: CGFloat, time: TimeInterval) {
        let step: CGFloat = 8
        let from: CGFloat = -step * 2
        let to = areaSize.width + step * 2

        let body = CGMutablePath()
        let line = CGMutablePath()
        var isFirst = true

        var x = from
        while x <= to {
            let y = waterLine + Wave.offset(atWorldX: cameraX + x, time: time)
            if isFirst {
                body.move(to: CGPoint(x: x, y: y))
                line.move(to: CGPoint(x: x, y: y))
                isFirst = false
            } else {
                body.addLine(to: CGPoint(x: x, y: y))
                line.addLine(to: CGPoint(x: x, y: y))
            }
            x += step
        }

        body.addLine(to: CGPoint(x: to, y: -20))
        body.addLine(to: CGPoint(x: from, y: -20))
        body.closeSubpath()

        surface.path = body
        foamLine.path = line
    }

    /// Verilen ekran x'i için su yüzeyinin ekran y'si.
    func surfaceY(screenX: CGFloat, cameraX: CGFloat, time: TimeInterval) -> CGFloat {
        waterLine + Wave.offset(atWorldX: cameraX + screenX, time: time)
    }
}
