import SpriteKit

/// Açılış ekranındaki Hira: önden, ayakta, elinde küçük gri ayıcığıyla.
/// Fotoğraftan yola çıkılmış karikatür bir karakter — kâküllü koyu kahve saç,
/// arkada toplanmış at kuyruğu, püsküllü beyaz askılı üst, fıstık yeşili şort,
/// çizgili çorap ve sarı terlik.
///
/// Düğümün orijini ayakların bastığı yer; yukarısı `height` kadar.
final class HiraNode: SKNode {

    private let height: CGFloat
    private let headRadius: CGFloat

    init(height: CGFloat) {
        self.height = height
        self.headRadius = height * 0.105
        super.init()

        buildLegs()
        buildShorts()
        buildArms()
        buildTop()
        buildHead()
        buildTeddy()
        startIdleMotion()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) kullanılmıyor") }

    // MARK: - Yardımcılar

    @discardableResult
    private func add(_ node: SKShapeNode, at point: CGPoint, z: CGFloat = 0) -> SKShapeNode {
        node.position = point
        node.zPosition = z
        addChild(node)
        return node
    }

    private func filled(_ path: CGPath, _ color: UIColor, stroke: UIColor? = nil, width: CGFloat = 1) -> SKShapeNode {
        let node = SKShapeNode(path: path)
        node.fillColor = color
        node.strokeColor = stroke ?? .clear
        node.lineWidth = stroke == nil ? 0 : width
        node.lineJoin = .round
        return node
    }

    private func capsule(width w: CGFloat, height h: CGFloat, color: UIColor,
                         stroke: UIColor? = nil) -> SKShapeNode {
        let node = SKShapeNode(rectOf: CGSize(width: w, height: h), cornerRadius: w / 2)
        node.fillColor = color
        node.strokeColor = stroke ?? .clear
        node.lineWidth = stroke == nil ? 0 : 1
        return node
    }

    private func disc(_ radius: CGFloat, _ color: UIColor, stroke: UIColor? = nil, width: CGFloat = 1) -> SKShapeNode {
        let node = SKShapeNode(circleOfRadius: radius)
        node.fillColor = color
        node.strokeColor = stroke ?? .clear
        node.lineWidth = stroke == nil ? 0 : width
        return node
    }

    private func oval(_ size: CGSize, _ color: UIColor, stroke: UIColor? = nil, width: CGFloat = 1) -> SKShapeNode {
        let node = SKShapeNode(ellipseOf: size)
        node.fillColor = color
        node.strokeColor = stroke ?? .clear
        node.lineWidth = stroke == nil ? 0 : width
        return node
    }

    // MARK: - Bacaklar, çorap, terlik

    private func buildLegs() {
        let h = height
        let legWidth = h * 0.052
        let hipY = h * 0.40
        let ankleY = h * 0.115

        for side in [CGFloat(-1), 1] {
            let x = side * h * 0.048

            let leg = capsule(width: legWidth, height: hipY - ankleY + legWidth,
                              color: Palette.skin, stroke: Palette.skinShade)
            add(leg, at: CGPoint(x: x, y: (hipY + ankleY) / 2), z: -1)

            // Çizgili çorap.
            let sockHeight = h * 0.085
            let sock = capsule(width: legWidth * 1.08, height: sockHeight,
                               color: .white, stroke: Palette.topShade)
            add(sock, at: CGPoint(x: x, y: ankleY + sockHeight * 0.34), z: 1)

            for offset in [sockHeight * 0.22, sockHeight * 0.36] {
                let stripe = SKShapeNode(rectOf: CGSize(width: legWidth * 1.08, height: h * 0.008))
                stripe.fillColor = Palette.sockStripe
                stripe.strokeColor = .clear
                add(stripe, at: CGPoint(x: x, y: ankleY + sockHeight * 0.34 + offset), z: 2)
            }

            buildClog(at: CGPoint(x: x, y: ankleY - h * 0.012), width: h * 0.082)
        }
    }

    /// Sarı terlik: kalın burun, arkada bant, üstünde birkaç süs.
    private func buildClog(at point: CGPoint, width: CGFloat) {
        let node = SKNode()
        node.position = point
        node.zPosition = 3

        let body = SKShapeNode(rectOf: CGSize(width: width, height: width * 0.62),
                               cornerRadius: width * 0.28)
        body.fillColor = Palette.clog
        body.strokeColor = Palette.clogShade
        body.lineWidth = 1.2
        node.addChild(body)

        let toe = SKShapeNode(ellipseOf: CGSize(width: width * 0.86, height: width * 0.42))
        toe.fillColor = Palette.clog
        toe.strokeColor = Palette.clogShade
        toe.lineWidth = 1
        toe.position = CGPoint(x: 0, y: width * 0.10)
        node.addChild(toe)

        for dx in [-width * 0.22, 0, width * 0.22] {
            let dot = SKShapeNode(circleOfRadius: width * 0.055)
            dot.fillColor = Palette.clogShade
            dot.strokeColor = .clear
            dot.position = CGPoint(x: dx, y: width * 0.14)
            node.addChild(dot)
        }

        addChild(node)
    }

    // MARK: - Şort

    private func buildShorts() {
        let h = height
        let waistY = h * 0.52
        let hemY = h * 0.385
        let halfWidth = h * 0.105

        let path = CGMutablePath()
        path.move(to: CGPoint(x: -halfWidth, y: waistY))
        path.addLine(to: CGPoint(x: halfWidth, y: waistY))
        path.addLine(to: CGPoint(x: halfWidth * 1.06, y: hemY))
        path.addLine(to: CGPoint(x: halfWidth * 0.18, y: hemY))
        // Ortadaki çentik iki paçayı ayırıyor.
        path.addLine(to: CGPoint(x: 0, y: hemY + h * 0.035))
        path.addLine(to: CGPoint(x: -halfWidth * 0.18, y: hemY))
        path.addLine(to: CGPoint(x: -halfWidth * 1.06, y: hemY))
        path.closeSubpath()

        add(filled(path, Palette.shorts, stroke: Palette.shortsShade, width: 1.2), at: .zero, z: 0)
    }

    // MARK: - Üst

    private func buildTop() {
        let h = height
        let shoulderY = h * 0.735
        let chestY = h * 0.70
        let hemY = h * 0.505
        let halfChest = h * 0.082
        let halfHem = h * 0.108

        // İnce askılar.
        for side in [CGFloat(-1), 1] {
            let strap = SKShapeNode(rectOf: CGSize(width: h * 0.012, height: h * 0.055), cornerRadius: h * 0.006)
            strap.fillColor = Palette.top
            strap.strokeColor = Palette.topShade
            strap.lineWidth = 0.6
            add(strap, at: CGPoint(x: side * h * 0.052, y: shoulderY), z: 4)
        }

        // Hafif A kesim gövde.
        let body = CGMutablePath()
        body.move(to: CGPoint(x: -halfChest, y: chestY))
        body.addLine(to: CGPoint(x: halfChest, y: chestY))
        body.addLine(to: CGPoint(x: halfHem, y: hemY))
        body.addLine(to: CGPoint(x: -halfHem, y: hemY))
        body.closeSubpath()
        add(filled(body, Palette.top, stroke: Palette.topShade, width: 1.2), at: .zero, z: 4)

        // Püsküllü etek ucu — fotoğraftaki en ayırt edici detay.
        let fringeCount = 13
        for index in 0..<fringeCount {
            let t = CGFloat(index) / CGFloat(fringeCount - 1)
            let x = -halfHem + t * halfHem * 2
            let strand = SKShapeNode(rectOf: CGSize(width: h * 0.009, height: h * 0.045),
                                     cornerRadius: h * 0.0045)
            strand.fillColor = Palette.top
            strand.strokeColor = Palette.topShade
            strand.lineWidth = 0.4
            add(strand, at: CGPoint(x: x, y: hemY - h * 0.020), z: 4)
        }

        // Göğüsteki küçük mavi nakış.
        let motif = oval(CGSize(width: h * 0.045, height: h * 0.030), .clear, stroke: Palette.topMotif, width: 1.6)
        add(motif, at: CGPoint(x: -h * 0.018, y: chestY - h * 0.045), z: 5)
        let motifDot = disc(h * 0.007, Palette.topMotif)
        add(motifDot, at: CGPoint(x: -h * 0.018, y: chestY - h * 0.045), z: 5)
    }

    // MARK: - Kollar

    private func buildArms() {
        let h = height
        let armWidth = h * 0.040
        let topY = h * 0.715
        let bottomY = h * 0.475

        for side in [CGFloat(-1), 1] {
            let arm = capsule(width: armWidth, height: topY - bottomY + armWidth,
                              color: Palette.skin, stroke: Palette.skinShade)
            arm.zRotation = side * -0.06
            add(arm, at: CGPoint(x: side * h * 0.098, y: (topY + bottomY) / 2), z: 3)

            let hand = disc(armWidth * 0.62, Palette.skin, stroke: Palette.skinShade)
            add(hand, at: CGPoint(x: side * h * 0.104, y: bottomY - h * 0.006), z: 3)
        }
    }

    // MARK: - Baş

    private func buildHead() {
        let h = height
        let r = headRadius
        let centerY = h - r * 1.30

        // Arkada toplanmış at kuyruğu.
        let tail = CGMutablePath()
        tail.move(to: CGPoint(x: r * 0.75, y: centerY - r * 0.15))
        tail.addQuadCurve(to: CGPoint(x: r * 1.30, y: centerY - r * 2.05),
                          control: CGPoint(x: r * 1.60, y: centerY - r * 0.95))
        tail.addQuadCurve(to: CGPoint(x: r * 0.62, y: centerY - r * 0.35),
                          control: CGPoint(x: r * 0.80, y: centerY - r * 1.25))
        tail.closeSubpath()
        add(filled(tail, Palette.hair), at: .zero, z: -2)

        let tie = disc(r * 0.16, Palette.shorts, stroke: Palette.shortsShade)
        add(tie, at: CGPoint(x: r * 0.82, y: centerY - r * 0.30), z: -1)

        // Boyun.
        let neck = capsule(width: r * 0.44, height: r * 0.55, color: Palette.skinShade)
        add(neck, at: CGPoint(x: 0, y: centerY - r * 1.05), z: 2)

        // Saç kütlesi ve yüz.
        add(disc(r * 1.14, Palette.hair), at: CGPoint(x: 0, y: centerY + r * 0.08), z: 5)
        for side in [CGFloat(-1), 1] {
            add(disc(r * 0.17, Palette.skin, stroke: Palette.skinShade),
                at: CGPoint(x: side * r * 1.02, y: centerY - r * 0.10), z: 5)
        }
        add(disc(r, Palette.skin), at: CGPoint(x: 0, y: centerY), z: 6)

        buildFringe(centerY: centerY, r: r)
        buildFace(centerY: centerY, r: r)
    }

    /// Kâkül: alnı kapatıp bir yana savrulan perçem.
    private func buildFringe(centerY: CGFloat, r: CGFloat) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -r * 1.03, y: centerY + r * 0.06))
        path.addQuadCurve(to: CGPoint(x: r * 1.00, y: centerY + r * 0.50),
                          control: CGPoint(x: 0, y: centerY + r * 1.62))
        path.addQuadCurve(to: CGPoint(x: -r * 1.03, y: centerY + r * 0.06),
                          control: CGPoint(x: -r * 0.10, y: centerY - r * 0.06))
        path.closeSubpath()
        add(filled(path, Palette.hair), at: .zero, z: 7)

        let shine = oval(CGSize(width: r * 0.62, height: r * 0.20), Palette.hairShine)
        shine.zRotation = 0.22
        add(shine, at: CGPoint(x: -r * 0.30, y: centerY + r * 0.72), z: 8)
    }

    private func buildFace(centerY: CGFloat, r: CGFloat) {
        // Kaşlar.
        for side in [CGFloat(-1), 1] {
            let brow = CGMutablePath()
            brow.move(to: CGPoint(x: side * r * 0.20, y: centerY + r * 0.30))
            brow.addQuadCurve(to: CGPoint(x: side * r * 0.60, y: centerY + r * 0.30),
                              control: CGPoint(x: side * r * 0.40, y: centerY + r * 0.42))
            let node = SKShapeNode(path: brow)
            node.strokeColor = Palette.hair
            node.lineWidth = r * 0.09
            node.lineCap = .round
            add(node, at: .zero, z: 8)
        }

        // Kahverengi iri gözler.
        for side in [CGFloat(-1), 1] {
            let x = side * r * 0.40
            let y = centerY + r * 0.04
            add(oval(CGSize(width: r * 0.42, height: r * 0.46), .white, stroke: Palette.skinShade, width: 0.8),
                at: CGPoint(x: x, y: y), z: 8)
            add(disc(r * 0.16, Palette.eyeBrown), at: CGPoint(x: x, y: y - r * 0.01), z: 9)
            add(disc(r * 0.08, Palette.hair), at: CGPoint(x: x, y: y - r * 0.01), z: 10)
            add(disc(r * 0.05, .white), at: CGPoint(x: x + r * 0.07, y: y + r * 0.08), z: 11)
        }

        // Burun ve yanaklar.
        let nose = SKShapeNode(path: {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -r * 0.05, y: centerY - r * 0.26))
            path.addQuadCurve(to: CGPoint(x: r * 0.07, y: centerY - r * 0.28),
                              control: CGPoint(x: r * 0.02, y: centerY - r * 0.34))
            return path
        }())
        nose.strokeColor = Palette.skinShade
        nose.lineWidth = r * 0.07
        nose.lineCap = .round
        add(nose, at: .zero, z: 8)

        for side in [CGFloat(-1), 1] {
            let cheek = oval(CGSize(width: r * 0.34, height: r * 0.20), Palette.blush)
            cheek.alpha = 0.5
            add(cheek, at: CGPoint(x: side * r * 0.58, y: centerY - r * 0.36), z: 8)
        }

        // Gülümseme.
        let smile = CGMutablePath()
        smile.move(to: CGPoint(x: -r * 0.24, y: centerY - r * 0.52))
        smile.addQuadCurve(to: CGPoint(x: r * 0.24, y: centerY - r * 0.52),
                           control: CGPoint(x: 0, y: centerY - r * 0.76))
        let smileNode = SKShapeNode(path: smile)
        smileNode.strokeColor = Palette.hair
        smileNode.lineWidth = r * 0.09
        smileNode.lineCap = .round
        add(smileNode, at: .zero, z: 8)
    }

    // MARK: - Ayıcık

    /// Elinde sarkan küçük gri ayıcık — Hira onu hiç bırakmıyor.
    private func buildTeddy() {
        let h = height
        let scale = h * 0.072
        let teddy = SKNode()
        teddy.position = CGPoint(x: -h * 0.128, y: h * 0.355)
        teddy.zPosition = 6

        let bodyRadius = scale * 0.95
        let headRadiusTeddy = scale * 0.72

        for side in [CGFloat(-1), 1] {
            let arm = SKShapeNode(ellipseOf: CGSize(width: scale * 0.5, height: scale * 0.9))
            arm.fillColor = Palette.teddy
            arm.strokeColor = Palette.teddyDark
            arm.lineWidth = 0.7
            arm.position = CGPoint(x: side * bodyRadius * 0.85, y: scale * 0.1)
            arm.zRotation = side * 0.35
            teddy.addChild(arm)

            let leg = SKShapeNode(ellipseOf: CGSize(width: scale * 0.55, height: scale * 0.8))
            leg.fillColor = Palette.teddy
            leg.strokeColor = Palette.teddyDark
            leg.lineWidth = 0.7
            leg.position = CGPoint(x: side * bodyRadius * 0.5, y: -bodyRadius * 1.0)
            teddy.addChild(leg)

            let ear = SKShapeNode(circleOfRadius: headRadiusTeddy * 0.42)
            ear.fillColor = Palette.teddy
            ear.strokeColor = Palette.teddyDark
            ear.lineWidth = 0.6
            ear.position = CGPoint(x: side * headRadiusTeddy * 0.78,
                                   y: bodyRadius * 0.95 + headRadiusTeddy * 0.72)
            teddy.addChild(ear)
        }

        let body = SKShapeNode(ellipseOf: CGSize(width: bodyRadius * 1.8, height: bodyRadius * 2.0))
        body.fillColor = Palette.teddy
        body.strokeColor = Palette.teddyDark
        body.lineWidth = 0.8
        teddy.addChild(body)

        let head = SKShapeNode(circleOfRadius: headRadiusTeddy)
        head.fillColor = Palette.teddy
        head.strokeColor = Palette.teddyDark
        head.lineWidth = 0.8
        head.position = CGPoint(x: 0, y: bodyRadius * 0.95)
        teddy.addChild(head)

        let muzzle = SKShapeNode(ellipseOf: CGSize(width: headRadiusTeddy * 0.8, height: headRadiusTeddy * 0.55))
        muzzle.fillColor = Palette.skin
        muzzle.strokeColor = .clear
        muzzle.position = CGPoint(x: 0, y: bodyRadius * 0.95 - headRadiusTeddy * 0.28)
        teddy.addChild(muzzle)

        let nose = SKShapeNode(circleOfRadius: headRadiusTeddy * 0.16)
        nose.fillColor = Palette.teddyDark
        nose.strokeColor = .clear
        nose.position = CGPoint(x: 0, y: bodyRadius * 0.95 - headRadiusTeddy * 0.18)
        teddy.addChild(nose)

        for side in [CGFloat(-1), 1] {
            let eye = SKShapeNode(circleOfRadius: headRadiusTeddy * 0.12)
            eye.fillColor = Palette.teddyDark
            eye.strokeColor = .clear
            eye.position = CGPoint(x: side * headRadiusTeddy * 0.32,
                                   y: bodyRadius * 0.95 + headRadiusTeddy * 0.12)
            teddy.addChild(eye)
        }

        addChild(teddy)

        // Elinde hafifçe sallanıyor.
        let swing = SKAction.sequence([
            .rotate(toAngle: 0.09, duration: 1.3),
            .rotate(toAngle: -0.09, duration: 1.3)
        ])
        swing.timingMode = .easeInEaseOut
        teddy.run(.repeatForever(swing))
    }

    // MARK: - Duruş

    private func startIdleMotion() {
        let breathe = SKAction.sequence([
            .moveBy(x: 0, y: height * 0.008, duration: 1.4),
            .moveBy(x: 0, y: -height * 0.008, duration: 1.4)
        ])
        breathe.timingMode = .easeInEaseOut
        run(.repeatForever(breathe))
    }
}
