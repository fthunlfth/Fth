import SpriteKit

/// Gökyüzü katmanı: degrade, güneş/ay, yıldızlar, paralakslı bulutlar,
/// ufuktaki adalar ve fırtına bölümünde yağmur.
final class SkyNode: SKNode {

    private struct Drifting {
        let node: SKNode
        /// Düğümün kamera sıfırdayken durduğu yer.
        let baseX: CGFloat
        let parallax: CGFloat
        /// Sarma genişliği: bu kadar sola gidince baştan başlıyor.
        let span: CGFloat
    }

    private var drifting: [Drifting] = []
    private var areaSize: CGSize = .zero
    private var waterLine: CGFloat = 0

    func build(size: CGSize, waterLine: CGFloat, theme: SkyTheme) {
        removeAllChildren()
        drifting.removeAll()
        areaSize = size
        self.waterLine = waterLine

        let gradient = SKSpriteNode(texture: TextureFactory.verticalGradient(
            size: CGSize(width: 4, height: size.height),
            top: theme.skyTop,
            bottom: theme.skyBottom))
        gradient.anchorPoint = .zero
        gradient.size = size
        gradient.zPosition = -10
        addChild(gradient)

        if theme.hasStars { addStars(size: size) }
        if let orb = theme.orb { addOrb(color: orb, isMoon: theme.orbIsMoon, size: size) }
        addFarIslands(size: size, color: theme.farIsland)
        addClouds(size: size, color: theme.cloud)
        if theme.hasRain { addRain(size: size) }
    }

    // MARK: - Parçalar

    private func addStars(size: CGSize) {
        let texture = TextureFactory.softCircle(diameter: 12, color: .white)
        for _ in 0..<50 {
            let star = SKSpriteNode(texture: texture)
            let scale = CGFloat.random(in: 0.18...0.42)
            star.size = CGSize(width: 12 * scale, height: 12 * scale)
            star.alpha = .random(in: 0.35...0.95)
            star.position = CGPoint(x: .random(in: 0...size.width),
                                    y: .random(in: (waterLine + 60)...size.height))
            star.zPosition = -9
            addChild(star)

            // Hafif titreşim — gökyüzü ölü durmasın.
            let twinkle = SKAction.sequence([
                .fadeAlpha(to: 0.25, duration: .random(in: 0.8...2.0)),
                .fadeAlpha(to: 0.95, duration: .random(in: 0.8...2.0))
            ])
            star.run(.repeatForever(twinkle))
        }
    }

    private func addOrb(color: UIColor, isMoon: Bool, size: CGSize) {
        let radius = size.width * 0.09
        let container = SKNode()
        container.position = CGPoint(x: size.width * 0.74, y: size.height * 0.80)
        container.zPosition = -8

        let glowDiameter = radius * 6
        let glow = SKSpriteNode(texture: TextureFactory.softCircle(diameter: glowDiameter, color: color))
        glow.size = CGSize(width: glowDiameter, height: glowDiameter)
        glow.alpha = 0.35
        container.addChild(glow)

        let disc = SKShapeNode(circleOfRadius: radius)
        disc.fillColor = color
        disc.strokeColor = .clear
        container.addChild(disc)

        if isMoon {
            // Hilal: diskin üstüne gökyüzü rengiyle ikinci bir daire.
            let crater = SKShapeNode(circleOfRadius: radius * 0.18)
            crater.fillColor = color.withAlphaComponent(0.55)
            crater.strokeColor = .clear
            crater.position = CGPoint(x: -radius * 0.3, y: radius * 0.25)
            container.addChild(crater)

            let crater2 = SKShapeNode(circleOfRadius: radius * 0.12)
            crater2.fillColor = color.withAlphaComponent(0.5)
            crater2.strokeColor = .clear
            crater2.position = CGPoint(x: radius * 0.28, y: -radius * 0.2)
            container.addChild(crater2)
        }

        addChild(container)
    }

    private func addFarIslands(size: CGSize, color: UIColor) {
        let spacing = size.width * 0.85
        for index in 0..<Tuning.farIslandCount {
            let island = SKNode()
            let width = CGFloat.random(in: (size.width * 0.22)...(size.width * 0.42))
            let peak = CGFloat.random(in: 26...58)

            let hill = CGMutablePath()
            hill.move(to: CGPoint(x: -width / 2, y: 0))
            hill.addQuadCurve(to: CGPoint(x: width / 2, y: 0),
                              control: CGPoint(x: CGFloat.random(in: -width * 0.2...width * 0.2), y: peak * 2))
            hill.closeSubpath()

            let node = SKShapeNode(path: hill)
            node.fillColor = color
            node.strokeColor = .clear
            island.addChild(node)

            let baseX = CGFloat(index) * spacing + .random(in: 0...spacing * 0.4)
            island.position = CGPoint(x: baseX, y: waterLine + 6)
            island.zPosition = -6
            addChild(island)
            drifting.append(Drifting(node: island, baseX: baseX, parallax: 0.35,
                                     span: spacing * CGFloat(Tuning.farIslandCount)))
        }
    }

    private func addClouds(size: CGSize, color: UIColor) {
        let spacing = size.width * 0.7
        for index in 0..<Tuning.cloudCount {
            let cloud = SKNode()
            let scale = CGFloat.random(in: 0.7...1.35)

            // Üst üste binen üç daire — yumuşak bulut silueti.
            for (dx, dy, r) in [(CGFloat(-26), CGFloat(0), CGFloat(18)),
                                (0, 8, 24),
                                (26, -1, 16)] {
                let puff = SKShapeNode(circleOfRadius: r * scale)
                puff.fillColor = color
                puff.strokeColor = .clear
                puff.position = CGPoint(x: dx * scale, y: dy * scale)
                cloud.addChild(puff)
            }
            let baseX = CGFloat(index) * spacing + .random(in: 0...spacing * 0.5)
            cloud.alpha = .random(in: 0.55...0.9)
            cloud.position = CGPoint(x: baseX,
                                     y: .random(in: (size.height * 0.62)...(size.height * 0.92)))
            cloud.zPosition = -7
            addChild(cloud)
            drifting.append(Drifting(node: cloud, baseX: baseX, parallax: 0.16,
                                     span: spacing * CGFloat(Tuning.cloudCount)))
        }
    }

    private func addRain(size: CGSize) {
        let emitter = SKEmitterNode()
        emitter.particleTexture = TextureFactory.softCircle(diameter: 8, color: .white)
        emitter.particleBirthRate = 260
        emitter.particleLifetime = 1.4
        emitter.particleSize = CGSize(width: 1.6, height: 13)
        emitter.particleAlpha = 0.35
        emitter.particleColor = UIColor(white: 0.85, alpha: 1)
        emitter.particleColorBlendFactor = 1
        emitter.position = CGPoint(x: size.width / 2, y: size.height + 20)
        emitter.particlePositionRange = CGVector(dx: size.width * 1.4, dy: 0)
        emitter.emissionAngle = -.pi / 2 - 0.28
        emitter.particleSpeed = 900
        emitter.particleSpeedRange = 180
        emitter.zPosition = 60
        addChild(emitter)
    }

    // MARK: - Döngü

    /// Kamera sağa gittikçe katmanlar hızlarına göre sola kayar ve başa sarar.
    func update(cameraX: CGFloat) {
        let margin = areaSize.width * 0.6
        for item in drifting {
            var x = (item.baseX - cameraX * item.parallax).truncatingRemainder(dividingBy: item.span)
            if x < -margin { x += item.span }
            item.node.position.x = x
        }
    }
}
