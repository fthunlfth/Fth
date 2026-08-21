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
        case .puppy:     buildPuppy()
        case .owl:       buildOwl()
        case .crab:      buildCrab()
        case .arcticFox: buildArcticFox()
        case .octopus:   buildOctopus()
        case .otter:     buildOtter()
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

    // MARK: - Baykuş

    private func buildOwl() {
        let h = height
        let body = Palette.owlFeather

        // Kanat, gövdenin yanında.
        addEllipse(CGSize(width: h * 0.26, height: h * 0.50),
                   at: CGPoint(x: -h * 0.16, y: h * 0.42), fill: Palette.owlBelly, rotation: 0.12)

        addEllipse(CGSize(width: h * 0.66, height: h * 0.80), at: CGPoint(x: 0, y: h * 0.44), fill: body)
        addEllipse(CGSize(width: h * 0.40, height: h * 0.56), at: CGPoint(x: h * 0.04, y: h * 0.38),
                   fill: Palette.owlBelly)

        // Göğsündeki tüy çentikleri.
        for row in 0..<3 {
            for column in [CGFloat(-1), 1] {
                addEllipse(CGSize(width: h * 0.07, height: h * 0.04),
                           at: CGPoint(x: h * 0.04 + column * h * 0.09,
                                       y: h * 0.24 + CGFloat(row) * h * 0.11),
                           fill: body)
            }
        }

        // Kulak püskülleri.
        for side in [CGFloat(-1), 1] {
            let tuft = CGMutablePath()
            tuft.move(to: CGPoint(x: side * h * 0.10, y: h * 0.86))
            tuft.addLine(to: CGPoint(x: side * h * 0.26, y: h * 1.06))
            tuft.addLine(to: CGPoint(x: side * h * 0.28, y: h * 0.82))
            tuft.closeSubpath()
            addChild(shape(tuft, fill: body))
        }

        addCircle(h * 0.30, at: CGPoint(x: 0, y: h * 0.82), fill: body)

        // Baykuşun imzası: iri, öne bakan iki göz.
        for side in [CGFloat(-1), 1] {
            addCircle(h * 0.14, at: CGPoint(x: side * h * 0.14, y: h * 0.86), fill: Palette.owlBelly)
            addEye(at: CGPoint(x: side * h * 0.14, y: h * 0.86), radius: h * 0.085, iris: Palette.owlBeak)
        }

        let beak = CGMutablePath()
        beak.move(to: CGPoint(x: -h * 0.05, y: h * 0.78))
        beak.addLine(to: CGPoint(x: h * 0.05, y: h * 0.78))
        beak.addLine(to: CGPoint(x: 0, y: h * 0.66))
        beak.closeSubpath()
        addChild(shape(beak, fill: Palette.owlBeak))

        for side in [CGFloat(-1), 1] {
            addEllipse(CGSize(width: h * 0.14, height: h * 0.07),
                       at: CGPoint(x: side * h * 0.13, y: h * 0.05), fill: Palette.owlBeak)
        }
    }

    // MARK: - Yengeç

    private func buildCrab() {
        let h = height
        let shell = Palette.crabShell
        let line = Palette.crabShade

        // Bacaklar.
        for side in [CGFloat(-1), 1] {
            for index in 0..<3 {
                let baseX = side * h * (0.22 + CGFloat(index) * 0.11)
                let leg = CGMutablePath()
                leg.move(to: CGPoint(x: baseX, y: h * 0.30))
                leg.addQuadCurve(to: CGPoint(x: baseX + side * h * 0.16, y: h * 0.04),
                                 control: CGPoint(x: baseX + side * h * 0.20, y: h * 0.22))
                let node = SKShapeNode(path: leg)
                node.strokeColor = line
                node.lineWidth = h * 0.05
                node.lineCap = .round
                node.zPosition = -1
                addChild(node)
            }
        }

        // Kıskaçlar.
        for side in [CGFloat(-1), 1] {
            let arm = CGMutablePath()
            arm.move(to: CGPoint(x: side * h * 0.30, y: h * 0.40))
            arm.addQuadCurve(to: CGPoint(x: side * h * 0.56, y: h * 0.56),
                             control: CGPoint(x: side * h * 0.50, y: h * 0.38))
            let armNode = SKShapeNode(path: arm)
            armNode.strokeColor = shell
            armNode.lineWidth = h * 0.08
            armNode.lineCap = .round
            addChild(armNode)

            addEllipse(CGSize(width: h * 0.24, height: h * 0.20),
                       at: CGPoint(x: side * h * 0.60, y: h * 0.60), fill: shell, stroke: line, width: 1)
            // Kıskacın açık ağzı.
            let claw = CGMutablePath()
            claw.move(to: CGPoint(x: side * h * 0.60, y: h * 0.60))
            claw.addLine(to: CGPoint(x: side * h * 0.74, y: h * 0.70))
            claw.addLine(to: CGPoint(x: side * h * 0.72, y: h * 0.58))
            claw.closeSubpath()
            addChild(shape(claw, fill: shell, stroke: line))
        }

        // Kabuk.
        addEllipse(CGSize(width: h * 0.82, height: h * 0.52),
                   at: CGPoint(x: 0, y: h * 0.44), fill: shell, stroke: line, width: 1.2)

        // Göz sapları.
        for side in [CGFloat(-1), 1] {
            let stalk = SKShapeNode(rectOf: CGSize(width: h * 0.04, height: h * 0.18), cornerRadius: h * 0.02)
            stalk.fillColor = shell
            stalk.strokeColor = .clear
            stalk.position = CGPoint(x: side * h * 0.16, y: h * 0.70)
            addChild(stalk)
            addEye(at: CGPoint(x: side * h * 0.16, y: h * 0.80), radius: h * 0.075, iris: nil)
        }

        // Gülen ağız.
        let mouth = CGMutablePath()
        mouth.move(to: CGPoint(x: -h * 0.12, y: h * 0.36))
        mouth.addQuadCurve(to: CGPoint(x: h * 0.12, y: h * 0.36),
                           control: CGPoint(x: 0, y: h * 0.26))
        let mouthNode = SKShapeNode(path: mouth)
        mouthNode.strokeColor = line
        mouthNode.lineWidth = h * 0.03
        mouthNode.lineCap = .round
        addChild(mouthNode)
    }

    // MARK: - Kutup tilkisi

    private func buildArcticFox() {
        let h = height
        let fur = Palette.foxFur
        let line = Palette.foxShade

        // Gövdeyi saran kabarık kuyruk.
        let tail = CGMutablePath()
        tail.move(to: CGPoint(x: -h * 0.24, y: h * 0.20))
        tail.addCurve(to: CGPoint(x: h * 0.30, y: h * 0.10),
                      control1: CGPoint(x: -h * 0.75, y: h * 0.34),
                      control2: CGPoint(x: -h * 0.30, y: -h * 0.20))
        let tailNode = SKShapeNode(path: tail)
        tailNode.strokeColor = fur
        tailNode.lineWidth = h * 0.22
        tailNode.lineCap = .round
        tailNode.zPosition = -1
        addChild(tailNode)

        addEllipse(CGSize(width: h * 0.58, height: h * 0.52),
                   at: CGPoint(x: -h * 0.04, y: h * 0.28), fill: fur, stroke: line, width: 1)

        addCircle(h * 0.24, at: CGPoint(x: h * 0.16, y: h * 0.66), fill: fur, stroke: line, width: 1)

        // Sivri kulaklar.
        for offset in [CGFloat(-0.10), 0.16] {
            let ear = CGMutablePath()
            ear.move(to: CGPoint(x: h * (0.16 + offset) - h * 0.08, y: h * 0.80))
            ear.addLine(to: CGPoint(x: h * (0.16 + offset), y: h * 1.02))
            ear.addLine(to: CGPoint(x: h * (0.16 + offset) + h * 0.09, y: h * 0.80))
            ear.closeSubpath()
            addChild(shape(ear, fill: fur, stroke: line))
        }

        // Sivri burun.
        let snout = CGMutablePath()
        snout.move(to: CGPoint(x: h * 0.28, y: h * 0.72))
        snout.addLine(to: CGPoint(x: h * 0.52, y: h * 0.60))
        snout.addLine(to: CGPoint(x: h * 0.28, y: h * 0.54))
        snout.closeSubpath()
        addChild(shape(snout, fill: fur, stroke: line))

        addCircle(h * 0.04, at: CGPoint(x: h * 0.50, y: h * 0.60), fill: Palette.animalEye)
        addEye(at: CGPoint(x: h * 0.24, y: h * 0.70), radius: h * 0.05, iris: nil)
    }

    // MARK: - Yavru ahtapot

    private func buildOctopus() {
        let h = height
        let skin = Palette.octopus
        let line = Palette.octopusDark

        // Kıvrılan kollar.
        for index in 0..<5 {
            let x = (CGFloat(index) - 2) * h * 0.17
            let curl: CGFloat = index.isMultiple(of: 2) ? 1 : -1
            let arm = CGMutablePath()
            arm.move(to: CGPoint(x: x, y: h * 0.34))
            arm.addQuadCurve(to: CGPoint(x: x + curl * h * 0.16, y: h * 0.02),
                             control: CGPoint(x: x - curl * h * 0.14, y: h * 0.16))
            let node = SKShapeNode(path: arm)
            node.strokeColor = skin
            node.lineWidth = h * 0.09
            node.lineCap = .round
            node.zPosition = -1
            addChild(node)

            // Uçlarındaki vantuzlar.
            addCircle(h * 0.035, at: CGPoint(x: x + curl * h * 0.16, y: h * 0.03), fill: line)
        }

        // Kafa/manto.
        addEllipse(CGSize(width: h * 0.74, height: h * 0.78),
                   at: CGPoint(x: 0, y: h * 0.56), fill: skin, stroke: line, width: 1.2)

        // İri gözler.
        for side in [CGFloat(-1), 1] {
            addCircle(h * 0.13, at: CGPoint(x: side * h * 0.16, y: h * 0.62), fill: .white)
            addEye(at: CGPoint(x: side * h * 0.16, y: h * 0.62), radius: h * 0.075, iris: nil)
        }

        let smile = CGMutablePath()
        smile.move(to: CGPoint(x: -h * 0.09, y: h * 0.42))
        smile.addQuadCurve(to: CGPoint(x: h * 0.09, y: h * 0.42),
                           control: CGPoint(x: 0, y: h * 0.33))
        let smileNode = SKShapeNode(path: smile)
        smileNode.strokeColor = line
        smileNode.lineWidth = h * 0.03
        smileNode.lineCap = .round
        addChild(smileNode)
    }

    // MARK: - Su samuru

    private func buildOtter() {
        let h = height
        let fur = Palette.otterFur
        let belly = Palette.otterBelly

        // Yassı kuyruk.
        let tail = CGMutablePath()
        tail.move(to: CGPoint(x: -h * 0.22, y: h * 0.16))
        tail.addQuadCurve(to: CGPoint(x: -h * 0.66, y: h * 0.10),
                          control: CGPoint(x: -h * 0.48, y: h * 0.30))
        let tailNode = SKShapeNode(path: tail)
        tailNode.strokeColor = fur
        tailNode.lineWidth = h * 0.14
        tailNode.lineCap = .round
        tailNode.zPosition = -1
        addChild(tailNode)

        // Dik oturan gövde.
        addEllipse(CGSize(width: h * 0.54, height: h * 0.72), at: CGPoint(x: 0, y: h * 0.38), fill: fur)
        addEllipse(CGSize(width: h * 0.34, height: h * 0.48), at: CGPoint(x: h * 0.02, y: h * 0.34),
                   fill: belly)

        // Su samurunun imzası: göğsünde birleşen iki küçük pati.
        for side in [CGFloat(-1), 1] {
            addEllipse(CGSize(width: h * 0.14, height: h * 0.10),
                       at: CGPoint(x: h * 0.02 + side * h * 0.08, y: h * 0.36),
                       fill: fur, rotation: side * 0.4)
        }

        addCircle(h * 0.26, at: CGPoint(x: h * 0.04, y: h * 0.84), fill: fur)

        for side in [CGFloat(-1), 1] {
            addCircle(h * 0.07, at: CGPoint(x: h * 0.04 + side * h * 0.20, y: h * 1.00), fill: fur)
        }

        addEllipse(CGSize(width: h * 0.26, height: h * 0.18),
                   at: CGPoint(x: h * 0.14, y: h * 0.76), fill: belly)
        addCircle(h * 0.045, at: CGPoint(x: h * 0.22, y: h * 0.80), fill: Palette.animalEye)

        for side in [CGFloat(-1), 1] {
            addEye(at: CGPoint(x: h * 0.04 + side * h * 0.11, y: h * 0.90), radius: h * 0.045, iris: nil)
        }

        for angle in [CGFloat(0.22), -0.06] {
            let whisker = CGMutablePath()
            whisker.move(to: CGPoint(x: h * 0.22, y: h * 0.74))
            whisker.addLine(to: CGPoint(x: h * 0.22 + cos(angle) * h * 0.18,
                                        y: h * 0.74 + sin(angle) * h * 0.18))
            let node = SKShapeNode(path: whisker)
            node.strokeColor = belly
            node.lineWidth = h * 0.014
            addChild(node)
        }
    }
}
