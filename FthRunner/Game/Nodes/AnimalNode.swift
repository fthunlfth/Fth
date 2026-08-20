import SpriteKit

/// Bölüm sonlarında kayığa katılan hayvanlar. Hepsi yandan, sağa bakar
/// biçimde çiziliyor ve düğümün orijini hayvanın oturduğu nokta.
final class AnimalNode: SKNode {

    let kind: AnimalKind
    private let height: CGFloat

    init(kind: AnimalKind, height: CGFloat) {
        self.kind = kind
        self.height = height
        super.init()

        switch kind {
        case .cat:     buildCat()
        case .seal:    buildSeal()
        case .penguin: buildPenguin()
        case .turtle:  buildTurtle()
        case .puppy:   buildPuppy()
        }

        startIdleMotion()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) kullanılmıyor") }

    // MARK: - Ortak yardımcılar

    private func shape(_ path: CGPath, fill: UIColor, stroke: UIColor? = nil, width: CGFloat = 1) -> SKShapeNode {
        let node = SKShapeNode(path: path)
        node.fillColor = fill
        node.strokeColor = stroke ?? .clear
        node.lineWidth = stroke == nil ? 0 : width
        node.lineJoin = .round
        return node
    }

    private func addEllipse(_ size: CGSize, at point: CGPoint, fill: UIColor,
                            stroke: UIColor? = nil, width: CGFloat = 1, rotation: CGFloat = 0) {
        let node = SKShapeNode(ellipseOf: size)
        node.fillColor = fill
        node.strokeColor = stroke ?? .clear
        node.lineWidth = stroke == nil ? 0 : width
        node.position = point
        node.zRotation = rotation
        addChild(node)
    }

    private func addCircle(_ radius: CGFloat, at point: CGPoint, fill: UIColor,
                           stroke: UIColor? = nil, width: CGFloat = 1) {
        addEllipse(CGSize(width: radius * 2, height: radius * 2), at: point,
                   fill: fill, stroke: stroke, width: width)
    }

    /// Gözler hep aynı düzende: koyu badem, üstünde küçük beyaz parlama.
    private func addEye(at point: CGPoint, radius: CGFloat, iris: UIColor?) {
        if let iris {
            addCircle(radius, at: point, fill: iris)
            addCircle(radius * 0.5, at: CGPoint(x: point.x + radius * 0.1, y: point.y), fill: Palette.animalEye)
        } else {
            addCircle(radius, at: point, fill: Palette.animalEye)
        }
        addCircle(radius * 0.3, at: CGPoint(x: point.x + radius * 0.35, y: point.y + radius * 0.4), fill: .white)
    }

    private func startIdleMotion() {
        // Hepsi hafifçe zıplıyor — kayıkta canlı duruyorlar.
        let bob = SKAction.sequence([
            .moveBy(x: 0, y: height * 0.05, duration: 0.7),
            .moveBy(x: 0, y: -height * 0.05, duration: 0.7)
        ])
        bob.timingMode = .easeInEaseOut
        run(.repeatForever(bob))
    }

    // MARK: - Mavi gözlü beyaz kedi

    private func buildCat() {
        let h = height
        let fur = Palette.catFur
        let line = Palette.catShade

        // Kuyruk — gövdenin arkasından kıvrılıp yukarı.
        let tail = CGMutablePath()
        tail.move(to: CGPoint(x: -h * 0.30, y: h * 0.16))
        tail.addCurve(to: CGPoint(x: -h * 0.52, y: h * 0.62),
                      control1: CGPoint(x: -h * 0.62, y: h * 0.12),
                      control2: CGPoint(x: -h * 0.70, y: h * 0.48))
        let tailNode = SKShapeNode(path: tail)
        tailNode.strokeColor = fur
        tailNode.lineWidth = h * 0.13
        tailNode.lineCap = .round
        tailNode.zPosition = -1
        addChild(tailNode)

        // Oturan gövde.
        addEllipse(CGSize(width: h * 0.60, height: h * 0.55), at: CGPoint(x: -h * 0.06, y: h * 0.26),
                   fill: fur, stroke: line, width: 1)

        // Ön patiler.
        for offset in [CGFloat(0.10), 0.20] {
            addEllipse(CGSize(width: h * 0.16, height: h * 0.10),
                       at: CGPoint(x: h * 0.18, y: h * 0.05 + offset * h * 0.05), fill: fur, stroke: line)
        }

        // Kafa.
        addCircle(h * 0.26, at: CGPoint(x: h * 0.12, y: h * 0.66), fill: fur, stroke: line, width: 1)

        // Kulaklar.
        for side in [CGFloat(-1), 1] {
            let ear = CGMutablePath()
            let baseX = h * 0.12 + side * h * 0.16
            ear.move(to: CGPoint(x: baseX - h * 0.07, y: h * 0.82))
            ear.addLine(to: CGPoint(x: baseX + side * h * 0.02, y: h * 1.00))
            ear.addLine(to: CGPoint(x: baseX + h * 0.09, y: h * 0.84))
            ear.closeSubpath()
            addChild(shape(ear, fill: fur, stroke: line))
        }

        // Mavi göz — kedinin imzası.
        addEye(at: CGPoint(x: h * 0.22, y: h * 0.68), radius: h * 0.065, iris: Palette.catEye)

        // Burun ve ağız.
        addCircle(h * 0.035, at: CGPoint(x: h * 0.36, y: h * 0.62), fill: Palette.catNose)

        let mouth = CGMutablePath()
        mouth.move(to: CGPoint(x: h * 0.36, y: h * 0.60))
        mouth.addQuadCurve(to: CGPoint(x: h * 0.28, y: h * 0.56), control: CGPoint(x: h * 0.32, y: h * 0.56))
        let mouthNode = SKShapeNode(path: mouth)
        mouthNode.strokeColor = line
        mouthNode.lineWidth = h * 0.02
        addChild(mouthNode)

        // Bıyıklar.
        for angle in [CGFloat(0.20), 0, -0.20] {
            let whisker = CGMutablePath()
            whisker.move(to: CGPoint(x: h * 0.34, y: h * 0.62))
            whisker.addLine(to: CGPoint(x: h * 0.34 + cos(angle) * h * 0.22,
                                        y: h * 0.62 + sin(angle) * h * 0.22))
            let node = SKShapeNode(path: whisker)
            node.strokeColor = line
            node.lineWidth = h * 0.014
            addChild(node)
        }
    }

    // MARK: - Yavru fok

    private func buildSeal() {
        let h = height
        let fur = Palette.sealFur
        let line = Palette.sealShade

        // Kuyruk yüzgeci.
        let fluke = CGMutablePath()
        fluke.move(to: CGPoint(x: -h * 0.34, y: h * 0.20))
        fluke.addLine(to: CGPoint(x: -h * 0.62, y: h * 0.42))
        fluke.addLine(to: CGPoint(x: -h * 0.58, y: h * 0.14))
        fluke.closeSubpath()
        addChild(shape(fluke, fill: line))

        addEllipse(CGSize(width: h * 0.78, height: h * 0.48), at: CGPoint(x: -h * 0.04, y: h * 0.24),
                   fill: fur, stroke: line, width: 1)

        // Ön yüzgeç.
        addEllipse(CGSize(width: h * 0.26, height: h * 0.12),
                   at: CGPoint(x: h * 0.14, y: h * 0.10), fill: line, rotation: -0.25)

        addCircle(h * 0.25, at: CGPoint(x: h * 0.22, y: h * 0.60), fill: fur, stroke: line, width: 1)
        addEllipse(CGSize(width: h * 0.22, height: h * 0.16),
                   at: CGPoint(x: h * 0.38, y: h * 0.54), fill: fur, stroke: line)

        addEye(at: CGPoint(x: h * 0.28, y: h * 0.66), radius: h * 0.055, iris: nil)
        addCircle(h * 0.035, at: CGPoint(x: h * 0.47, y: h * 0.55), fill: Palette.animalEye)

        for angle in [CGFloat(0.25), -0.05] {
            let whisker = CGMutablePath()
            whisker.move(to: CGPoint(x: h * 0.45, y: h * 0.53))
            whisker.addLine(to: CGPoint(x: h * 0.45 + cos(angle) * h * 0.20,
                                        y: h * 0.53 + sin(angle) * h * 0.20))
            let node = SKShapeNode(path: whisker)
            node.strokeColor = line
            node.lineWidth = h * 0.014
            addChild(node)
        }
    }

    // MARK: - Küçük penguen

    private func buildPenguin() {
        let h = height
        let body = Palette.penguin

        addEllipse(CGSize(width: h * 0.30, height: h * 0.10),
                   at: CGPoint(x: h * 0.16, y: h * 0.04), fill: Palette.penguinBeak)

        addEllipse(CGSize(width: h * 0.58, height: h * 0.76), at: CGPoint(x: 0, y: h * 0.44), fill: body)
        addEllipse(CGSize(width: h * 0.40, height: h * 0.58), at: CGPoint(x: h * 0.06, y: h * 0.40), fill: .white)

        // Kanat.
        addEllipse(CGSize(width: h * 0.16, height: h * 0.42),
                   at: CGPoint(x: -h * 0.20, y: h * 0.42), fill: body, rotation: 0.18)

        addCircle(h * 0.24, at: CGPoint(x: h * 0.04, y: h * 0.86), fill: body)
        addEllipse(CGSize(width: h * 0.26, height: h * 0.22),
                   at: CGPoint(x: h * 0.14, y: h * 0.82), fill: .white)

        let beak = CGMutablePath()
        beak.move(to: CGPoint(x: h * 0.20, y: h * 0.88))
        beak.addLine(to: CGPoint(x: h * 0.38, y: h * 0.83))
        beak.addLine(to: CGPoint(x: h * 0.20, y: h * 0.79))
        beak.closeSubpath()
        addChild(shape(beak, fill: Palette.penguinBeak))

        addEye(at: CGPoint(x: h * 0.14, y: h * 0.91), radius: h * 0.05, iris: nil)
    }

    // MARK: - Deniz kaplumbağası

    private func buildTurtle() {
        let h = height

        // Yüzgeçler.
        addEllipse(CGSize(width: h * 0.30, height: h * 0.14),
                   at: CGPoint(x: h * 0.22, y: h * 0.12), fill: Palette.turtleSkin, rotation: -0.3)
        addEllipse(CGSize(width: h * 0.26, height: h * 0.12),
                   at: CGPoint(x: -h * 0.30, y: h * 0.14), fill: Palette.turtleSkin, rotation: 0.3)

        // Kubbe kabuk.
        let shell = CGMutablePath()
        shell.addArc(center: CGPoint(x: 0, y: h * 0.26), radius: h * 0.44,
                     startAngle: 0, endAngle: .pi, clockwise: false)
        shell.closeSubpath()
        addChild(shape(shell, fill: Palette.turtleShell, stroke: Palette.animalEye, width: 1))

        // Kabuk deseni.
        for offset in [CGFloat(-0.22), 0, 0.22] {
            addEllipse(CGSize(width: h * 0.16, height: h * 0.14),
                       at: CGPoint(x: h * offset, y: h * 0.44), fill: Palette.turtleSkin)
        }

        // Baş.
        addEllipse(CGSize(width: h * 0.32, height: h * 0.26),
                   at: CGPoint(x: h * 0.42, y: h * 0.34), fill: Palette.turtleSkin, stroke: Palette.animalEye, width: 1)
        addEye(at: CGPoint(x: h * 0.48, y: h * 0.38), radius: h * 0.045, iris: nil)
    }

    // MARK: - Yavru köpek

    private func buildPuppy() {
        let h = height
        let fur = Palette.puppyFur
        let line = Palette.puppyShade

        // Sallanan kuyruk.
        let tail = CGMutablePath()
        tail.move(to: CGPoint(x: -h * 0.28, y: h * 0.32))
        tail.addQuadCurve(to: CGPoint(x: -h * 0.52, y: h * 0.62),
                          control: CGPoint(x: -h * 0.56, y: h * 0.34))
        let tailNode = SKShapeNode(path: tail)
        tailNode.strokeColor = fur
        tailNode.lineWidth = h * 0.11
        tailNode.lineCap = .round
        tailNode.zPosition = -1
        addChild(tailNode)
        tailNode.run(.repeatForever(.sequence([
            .rotate(toAngle: 0.28, duration: 0.28),
            .rotate(toAngle: -0.12, duration: 0.28)
        ])))

        addEllipse(CGSize(width: h * 0.62, height: h * 0.52), at: CGPoint(x: -h * 0.04, y: h * 0.26),
                   fill: fur, stroke: line, width: 1)

        for offset in [CGFloat(0.14), 0.26] {
            addEllipse(CGSize(width: h * 0.15, height: h * 0.10),
                       at: CGPoint(x: h * offset, y: h * 0.06), fill: fur, stroke: line)
        }

        addCircle(h * 0.25, at: CGPoint(x: h * 0.16, y: h * 0.64), fill: fur, stroke: line, width: 1)

        // Sarkık kulak.
        addEllipse(CGSize(width: h * 0.16, height: h * 0.32),
                   at: CGPoint(x: h * 0.02, y: h * 0.58), fill: line, rotation: 0.15)

        // Burun bölgesi.
        addEllipse(CGSize(width: h * 0.26, height: h * 0.18),
                   at: CGPoint(x: h * 0.34, y: h * 0.58), fill: Palette.catFur, stroke: line)
        addCircle(h * 0.045, at: CGPoint(x: h * 0.45, y: h * 0.60), fill: Palette.animalEye)

        addEye(at: CGPoint(x: h * 0.24, y: h * 0.70), radius: h * 0.05, iris: nil)
    }
}
