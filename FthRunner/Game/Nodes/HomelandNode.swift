import SpriteKit

/// Yolculuğun sonundaki kıyı. Küçük bir ada değil — kumsalı, tepesi, palmiyeleri,
/// çiçekleri ve pencereleri yanan küçük eviyle koca bir kara parçası.
/// Onuncu bölümün sonunda kayık buraya yanaşıyor ve hayvanlar karaya çıkıyor.
final class HomelandNode: GoalIslandNode {

    /// Kıyı çizgisi düğümün orijininde; kara sağa doğru uzanıyor.
    private let landWidth: CGFloat = 680

    /// Kayık kumsala girmesin, suyun kenarında dursun.
    override var stopOffset: CGFloat { 165 }

    override func build(reward: AnimalKind) {
        removeAllChildren()

        buildHill()
        buildBeach()
        buildShoreFoam()
        buildPalm(at: CGPoint(x: landWidth * 0.30, y: 26), scale: 1.0)
        buildPalm(at: CGPoint(x: landWidth * 0.52, y: 34), scale: 0.78)
        buildCottage(at: CGPoint(x: landWidth * 0.70, y: 44))
        buildFlowers()

        // Onuncu arkadaş kıyıda bekliyor.
        let node = AnimalNode(kind: reward, height: 46)
        node.position = CGPoint(x: landWidth * 0.16, y: 18)
        node.xScale = -1                     // Kayığa, yani Hira'ya dönük.
        node.zPosition = 4
        addChild(node)
        animal = node
    }

    // MARK: - Kara

    private func buildHill() {
        let hill = CGMutablePath()
        hill.move(to: CGPoint(x: landWidth * 0.10, y: 0))
        hill.addQuadCurve(to: CGPoint(x: landWidth, y: 0),
                          control: CGPoint(x: landWidth * 0.58, y: 210))
        hill.closeSubpath()
        let node = SKShapeNode(path: hill)
        node.fillColor = Palette.palm
        node.strokeColor = .clear
        node.zPosition = -2
        addChild(node)

        // Tepenin güneş almayan yamacı.
        let shade = CGMutablePath()
        shade.move(to: CGPoint(x: landWidth * 0.58, y: 105))
        shade.addQuadCurve(to: CGPoint(x: landWidth, y: 0),
                           control: CGPoint(x: landWidth * 0.86, y: 60))
        shade.addLine(to: CGPoint(x: landWidth * 0.58, y: 0))
        shade.closeSubpath()
        let shadeNode = SKShapeNode(path: shade)
        shadeNode.fillColor = Palette.islandShade
        shadeNode.strokeColor = .clear
        shadeNode.alpha = 0.35
        shadeNode.zPosition = -1
        addChild(shadeNode)
    }

    private func buildBeach() {
        let beach = CGMutablePath()
        beach.move(to: CGPoint(x: -30, y: 0))
        // Kıyı çizgisi yumuşak bir yay çizerek yükseliyor.
        beach.addQuadCurve(to: CGPoint(x: landWidth, y: 62),
                           control: CGPoint(x: landWidth * 0.35, y: 58))
        beach.addLine(to: CGPoint(x: landWidth, y: -80))
        beach.addLine(to: CGPoint(x: -30, y: -80))
        beach.closeSubpath()
        let node = SKShapeNode(path: beach)
        node.fillColor = Palette.island
        node.strokeColor = .clear
        addChild(node)
    }

    private func buildShoreFoam() {
        let foam = CGMutablePath()
        foam.move(to: CGPoint(x: -34, y: 2))
        var x: CGFloat = -34
        var up = true
        while x < landWidth * 0.55 {
            let next = x + 30
            foam.addQuadCurve(to: CGPoint(x: next, y: 2 + (next - x) * 0.06),
                              control: CGPoint(x: x + 15, y: up ? 12 : -6))
            up.toggle()
            x = next
        }
        let node = SKShapeNode(path: foam)
        node.strokeColor = Palette.foam
        node.lineWidth = 3.5
        node.alpha = 0.7
        node.zPosition = 1
        addChild(node)
    }

    private func buildPalm(at base: CGPoint, scale: CGFloat) {
        let trunk = CGMutablePath()
        trunk.move(to: base)
        trunk.addQuadCurve(to: CGPoint(x: base.x - 22 * scale, y: base.y + 104 * scale),
                           control: CGPoint(x: base.x - 3 * scale, y: base.y + 56 * scale))
        let trunkNode = SKShapeNode(path: trunk)
        trunkNode.strokeColor = Palette.driftwood
        trunkNode.lineWidth = 10 * scale
        trunkNode.lineCap = .round
        addChild(trunkNode)

        let top = CGPoint(x: base.x - 22 * scale, y: base.y + 104 * scale)
        for angle in stride(from: CGFloat.pi * 0.08, through: .pi * 0.92, by: .pi * 0.168) {
            let leaf = CGMutablePath()
            leaf.move(to: top)
            leaf.addQuadCurve(to: CGPoint(x: top.x + cos(angle) * 52 * scale,
                                          y: top.y + sin(angle) * 32 * scale),
                              control: CGPoint(x: top.x + cos(angle) * 26 * scale,
                                               y: top.y + sin(angle) * 44 * scale))
            let leafNode = SKShapeNode(path: leaf)
            leafNode.strokeColor = Palette.palm
            leafNode.lineWidth = 8 * scale
            leafNode.lineCap = .round
            addChild(leafNode)
        }

        for offset in [CGFloat(-6), 7] {
            let coconut = SKShapeNode(circleOfRadius: 5.5 * scale)
            coconut.fillColor = Palette.driftwood
            coconut.strokeColor = .clear
            coconut.position = CGPoint(x: top.x + offset * scale, y: top.y - 9 * scale)
            addChild(coconut)
        }
    }

    /// Pencereleri yanan küçük ev — "eve dönüş" hissini veren şey.
    private func buildCottage(at base: CGPoint) {
        let wallWidth: CGFloat = 84
        let wallHeight: CGFloat = 62

        let wall = SKShapeNode(rectOf: CGSize(width: wallWidth, height: wallHeight))
        wall.fillColor = Palette.island
        wall.strokeColor = Palette.hullDark
        wall.lineWidth = 2
        wall.position = CGPoint(x: base.x, y: base.y + wallHeight / 2)
        addChild(wall)

        let roof = CGMutablePath()
        roof.move(to: CGPoint(x: base.x - wallWidth * 0.62, y: base.y + wallHeight))
        roof.addLine(to: CGPoint(x: base.x, y: base.y + wallHeight + 44))
        roof.addLine(to: CGPoint(x: base.x + wallWidth * 0.62, y: base.y + wallHeight))
        roof.closeSubpath()
        let roofNode = SKShapeNode(path: roof)
        roofNode.fillColor = Palette.buoy
        roofNode.strokeColor = Palette.hullDark
        roofNode.lineWidth = 2
        roofNode.lineJoin = .round
        addChild(roofNode)

        // Sıcak ışıklı pencere.
        let window = SKShapeNode(rectOf: CGSize(width: 26, height: 24), cornerRadius: 3)
        window.fillColor = Palette.lifeVest
        window.strokeColor = Palette.hullDark
        window.lineWidth = 2
        window.position = CGPoint(x: base.x, y: base.y + wallHeight * 0.58)
        addChild(window)

        let glow = SKSpriteNode(texture: TextureFactory.softCircle(diameter: 120, color: Palette.lifeVest))
        glow.size = CGSize(width: 120, height: 120)
        glow.alpha = 0.35
        glow.blendMode = .add
        glow.position = window.position
        glow.zPosition = -1
        addChild(glow)

        let door = SKShapeNode(rectOf: CGSize(width: 22, height: 30), cornerRadius: 2)
        door.fillColor = Palette.driftwood
        door.strokeColor = Palette.hullDark
        door.lineWidth = 1.5
        door.position = CGPoint(x: base.x + wallWidth * 0.26, y: base.y + 15)
        addChild(door)
    }

    private func buildFlowers() {
        var random = SplitMix64(seed: 4242)
        for index in 0..<14 {
            let x = landWidth * (0.12 + CGFloat(index) * 0.058)
            let y = 24 + CGFloat(random.nextUnit()) * 10
            let color: UIColor = index.isMultiple(of: 3) ? Palette.dress2
                : (index.isMultiple(of: 2) ? Palette.lifeVest : Palette.foam)

            for petal in 0..<5 {
                let angle = CGFloat(petal) / 5 * .pi * 2
                let node = SKShapeNode(circleOfRadius: 3)
                node.fillColor = color
                node.strokeColor = .clear
                node.position = CGPoint(x: x + cos(angle) * 3.4, y: y + sin(angle) * 3.4)
                node.zPosition = 2
                addChild(node)
            }
            let center = SKShapeNode(circleOfRadius: 2)
            center.fillColor = Palette.starfish
            center.strokeColor = .clear
            center.position = CGPoint(x: x, y: y)
            center.zPosition = 3
            addChild(center)
        }
    }
}
