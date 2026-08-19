import SpriteKit

/// Denizin kendisi: derinlik degradesi, kayan dalga çizgileri ve
/// paralakslı köpük lekeleri. Hız arttıkça köpükler uzayıp çizgiye döner.
final class Ocean: SKNode {

    private struct Foam {
        let node: SKSpriteNode
        let parallax: CGFloat
    }

    private var foam: [Foam] = []
    private var waveLines: [SKShapeNode] = []
    private var areaSize: CGSize = .zero

    func build(size: CGSize) {
        removeAllChildren()
        foam.removeAll()
        waveLines.removeAll()
        areaSize = size

        addDepthGradient(size: size)
        addWaveLines(size: size)
        addFoam(size: size)
    }

    // MARK: - Kurulum

    private func addDepthGradient(size: CGSize) {
        let gradient = SKSpriteNode(texture: TextureFactory.verticalGradient(
            size: CGSize(width: 4, height: size.height),
            top: Palette.seaTop,
            bottom: Palette.seaBottom))
        gradient.anchorPoint = .zero
        gradient.size = size
        gradient.zPosition = -3
        addChild(gradient)
    }

    /// Ufuktan gelen geniş, sönük dalga bantları. Derinlik hissi veriyor.
    private func addWaveLines(size: CGSize) {
        let spacing = size.height / CGFloat(Tuning.waveLineCount)
        for index in 0..<Tuning.waveLineCount {
            let y = CGFloat(index) * spacing
            let line = SKShapeNode(path: wavePath(width: size.width, amplitude: 7))
            line.strokeColor = Palette.foam
            line.lineWidth = 2
            line.alpha = 0.08
            line.position = CGPoint(x: 0, y: y)
            line.zPosition = -2
            addChild(line)
            waveLines.append(line)
        }
    }

    private func wavePath(width: CGFloat, amplitude: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -20, y: 0))
        var x: CGFloat = -20
        let step: CGFloat = 26
        var up = true
        while x < width + 20 {
            let next = x + step
            path.addQuadCurve(to: CGPoint(x: next, y: 0),
                              control: CGPoint(x: x + step / 2, y: up ? amplitude : -amplitude))
            up.toggle()
            x = next
        }
        return path
    }

    private func addFoam(size: CGSize) {
        let texture = TextureFactory.softCircle(diameter: 24, color: Palette.foam)
        for _ in 0..<Tuning.foamCount {
            let parallax = CGFloat.random(in: Tuning.foamParallaxRange)
            let node = SKSpriteNode(texture: texture)
            // Uzaktakiler küçük ve sönük, yakındakiler büyük ve parlak.
            let scale = 0.5 + parallax * 1.4
            node.size = CGSize(width: 24 * scale, height: 24 * scale)
            node.alpha = 0.10 + parallax * 0.35
            node.position = CGPoint(x: .random(in: 0...size.width),
                                    y: .random(in: 0...size.height))
            node.zPosition = -1
            addChild(node)
            foam.append(Foam(node: node, parallax: parallax))
        }
    }

    // MARK: - Döngü

    func update(deltaTime: TimeInterval, scrollSpeed: CGFloat) {
        guard areaSize.height > 0 else { return }
        let speedRatio = scrollSpeed / Tuning.maxScrollSpeed

        for item in foam {
            item.node.position.y -= scrollSpeed * item.parallax * CGFloat(deltaTime)
            // Hız arttıkça köpük dikey uzar: akıntı çizgisine dönüşür.
            item.node.yScale = 1 + speedRatio * item.parallax * 9

            if item.node.position.y < -30 {
                item.node.position.y = areaSize.height + CGFloat.random(in: 0...50)
                item.node.position.x = .random(in: 0...areaSize.width)
            }
        }

        let spacing = areaSize.height / CGFloat(Tuning.waveLineCount)
        for line in waveLines {
            // Dalga bantları köpükten yavaş akar; katmanlı bir derinlik çıkıyor.
            line.position.y -= scrollSpeed * 0.22 * CGFloat(deltaTime)
            if line.position.y < -spacing {
                line.position.y += spacing * CGFloat(Tuning.waveLineCount)
            }
        }
    }
}
