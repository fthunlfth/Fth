import SpriteKit

/// Kayık, içindeki kız ve kucağındaki ayıcık — yandan görünüş, sağa bakar.
/// Bölüm sonlarında katılan hayvanlar kıç tarafına diziliyor ve
/// kalabalıklaştıkça kayık uzuyor.
final class BoatNode: SKNode {

    /// Kayığa katılmış hayvanlar (bölüm sırasına göre).
    private(set) var companions: [AnimalKind] = []

    private let baseLength: CGFloat
    private let height: CGFloat

    /// Yatırma ve zıplama açısı buraya uygulanıyor; çarpışma kutusu etkilenmiyor.
    private let visual = SKNode()
    private let hullLayer = SKNode()
    private let crewLayer = SKNode()
    private let girl = SKNode()
    private var wake: SKEmitterNode?
    private var pitch: CGFloat = 0

    /// Mürettebat büyüdükçe kayık uzuyor.
    var length: CGFloat { baseLength + CGFloat(companions.count) * 15 }

    /// Çarpışma kutusu — kayığın orijinine göre.
    var collisionRect: CGRect {
        let inset = Tuning.boatCollisionInset
        return CGRect(x: -length / 2 + inset,
                      y: -height * 0.45 + inset * 0.5,
                      width: length - inset * 2,
                      height: height * 1.15 - inset)
    }

    init(length: CGFloat, height: CGFloat) {
        self.baseLength = length
        self.height = height
        super.init()

        addChild(visual)
        visual.addChild(hullLayer)
        visual.addChild(crewLayer)
        visual.addChild(girl)
        buildWake()
        rebuildHull()
        buildGirl()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) kullanılmıyor") }

    // MARK: - Tekne gövdesi

    private func hullPath() -> CGPath {
        let halfL = length / 2
        let deckBack = height * 0.30
        let deckFront = height * 0.52

        let path = CGMutablePath()
        path.move(to: CGPoint(x: -halfL, y: deckBack))
        path.addQuadCurve(to: CGPoint(x: halfL, y: deckFront),
                          control: CGPoint(x: 0, y: height * 0.36))
        path.addQuadCurve(to: CGPoint(x: -halfL, y: deckBack),
                          control: CGPoint(x: 0, y: -height * 1.20))
        path.closeSubpath()
        return path
    }

    private func rebuildHull() {
        hullLayer.removeAllChildren()
        let halfL = length / 2

        let hull = SKShapeNode(path: hullPath())
        hull.fillColor = Palette.hull
        hull.strokeColor = Palette.hullDark
        hull.lineWidth = 2.5
        hull.lineJoin = .round
        hullLayer.addChild(hull)

        // Küpeşte — güverte çizgisi boyunca açık renk bant.
        let rail = CGMutablePath()
        rail.move(to: CGPoint(x: -halfL + 2, y: height * 0.30))
        rail.addQuadCurve(to: CGPoint(x: halfL - 2, y: height * 0.52),
                          control: CGPoint(x: 0, y: height * 0.36))
        let railNode = SKShapeNode(path: rail)
        railNode.strokeColor = Palette.hullLight
        railNode.lineWidth = 4
        railNode.lineCap = .round
        hullLayer.addChild(railNode)

        // Kaplama tahtaları.
        for ratio in stride(from: CGFloat(-0.32), through: 0.32, by: 0.16) {
            let plank = SKShapeNode(rectOf: CGSize(width: 1.5, height: height * 0.5), cornerRadius: 0.75)
            plank.fillColor = Palette.hullDark
            plank.strokeColor = .clear
            plank.alpha = 0.35
            plank.position = CGPoint(x: length * ratio, y: -height * 0.02)
            hullLayer.addChild(plank)
        }

        // Pruvadaki küçük bayrak — kayığın yönünü belli ediyor.
        let pole = SKShapeNode(rectOf: CGSize(width: 2, height: height * 0.85), cornerRadius: 1)
        pole.fillColor = Palette.hullDark
        pole.strokeColor = .clear
        pole.position = CGPoint(x: halfL - height * 0.22, y: height * 0.92)
        hullLayer.addChild(pole)

        let flag = CGMutablePath()
        flag.move(to: CGPoint(x: 0, y: 0))
        flag.addLine(to: CGPoint(x: -height * 0.34, y: height * 0.10))
        flag.addLine(to: CGPoint(x: -height * 0.34, y: -height * 0.14))
        flag.closeSubpath()
        let flagNode = SKShapeNode(path: flag)
        flagNode.fillColor = Palette.shorts
        flagNode.strokeColor = Palette.hullDark
        flagNode.lineWidth = 1
        flagNode.position = CGPoint(x: halfL - height * 0.21, y: height * 1.28)
        hullLayer.addChild(flagNode)
        flagNode.run(.repeatForever(.sequence([
            .scaleX(to: 0.82, duration: 0.5),
            .scaleX(to: 1.0, duration: 0.5)
        ])))
    }

    // MARK: - Hira ve ayıcık

    private func buildGirl() {
        girl.removeAllChildren()
        let r = height * 0.30                       // kafa yarıçapı
        let seatY = height * 0.34
        let bodyX = -height * 0.05
        girl.position = CGPoint(x: length * 0.06, y: 0)

        buildDanglingLeg(hip: CGPoint(x: bodyX + r * 0.35, y: seatY + r * 0.1), scale: r)
        buildOutfit(at: CGPoint(x: bodyX, y: seatY + r * 0.55), scale: r)

        // Öne uzanan kol — ayıcığı tutuyor.
        let arm = SKShapeNode(ellipseOf: CGSize(width: r * 0.85, height: r * 0.36))
        arm.fillColor = Palette.skin
        arm.strokeColor = Palette.skinShade
        arm.lineWidth = 0.8
        arm.position = CGPoint(x: bodyX + r * 0.72, y: seatY + r * 0.42)
        arm.zRotation = -0.18
        arm.zPosition = 3
        girl.addChild(arm)

        buildTeddy(at: CGPoint(x: bodyX + r * 1.05, y: seatY + r * 0.50), scale: r)
        buildHead(at: CGPoint(x: bodyX + r * 0.10, y: seatY + r * 1.85), radius: r)
    }

    /// Fıstık yeşili şort, püsküllü beyaz üst ve üstündeki can yeleği bandı.
    private func buildOutfit(at point: CGPoint, scale r: CGFloat) {
        // Şort — oturağın hizasında, üstün altından görünüyor.
        let shorts = SKShapeNode(rectOf: CGSize(width: r * 1.45, height: r * 0.75), cornerRadius: r * 0.22)
        shorts.fillColor = Palette.shorts
        shorts.strokeColor = Palette.shortsShade
        shorts.lineWidth = 1
        shorts.position = CGPoint(x: point.x, y: point.y - r * 0.62)
        shorts.zPosition = 1
        girl.addChild(shorts)

        // Beyaz askılı üst.
        let top = SKShapeNode(ellipseOf: CGSize(width: r * 1.5, height: r * 1.55))
        top.fillColor = Palette.top
        top.strokeColor = Palette.topShade
        top.lineWidth = 1
        top.position = point
        top.zPosition = 2
        girl.addChild(top)

        // Etek ucundaki püskül — fotoğraftaki ayırt edici detay.
        for index in 0..<5 {
            let t = CGFloat(index) / 4
            let strand = SKShapeNode(rectOf: CGSize(width: r * 0.10, height: r * 0.34),
                                     cornerRadius: r * 0.05)
            strand.fillColor = Palette.top
            strand.strokeColor = Palette.topShade
            strand.lineWidth = 0.4
            strand.position = CGPoint(x: point.x - r * 0.52 + t * r * 1.04, y: point.y - r * 0.78)
            strand.zPosition = 2
            girl.addChild(strand)
        }

        // Can yeleği: dar bir bant, altındaki beyaz üst görünsün diye.
        let vest = SKShapeNode(rectOf: CGSize(width: r * 1.35, height: r * 0.62), cornerRadius: r * 0.2)
        vest.fillColor = Palette.lifeVest
        vest.strokeColor = Palette.hullDark
        vest.lineWidth = 1
        vest.position = CGPoint(x: point.x, y: point.y + r * 0.08)
        vest.zPosition = 3
        girl.addChild(vest)

        let strap = SKShapeNode(rectOf: CGSize(width: r * 0.22, height: r * 0.85), cornerRadius: r * 0.11)
        strap.fillColor = Palette.lifeVest
        strap.strokeColor = .clear
        strap.position = CGPoint(x: point.x - r * 0.12, y: point.y + r * 0.5)
        strap.zRotation = 0.12
        strap.zPosition = 3
        girl.addChild(strap)
    }

    /// Kayığın kenarından suya sarkan bacak: çizgili çorap ve sarı terlik.
    private func buildDanglingLeg(hip: CGPoint, scale r: CGFloat) {
        let leg = SKNode()
        leg.zPosition = 4

        let thigh = SKShapeNode(rectOf: CGSize(width: r * 0.95, height: r * 0.40), cornerRadius: r * 0.2)
        thigh.fillColor = Palette.skin
        thigh.strokeColor = Palette.skinShade
        thigh.lineWidth = 0.8
        thigh.position = CGPoint(x: hip.x + r * 0.42, y: hip.y - r * 0.18)
        leg.addChild(thigh)

        let shin = SKShapeNode(rectOf: CGSize(width: r * 0.36, height: r * 0.80), cornerRadius: r * 0.18)
        shin.fillColor = Palette.skin
        shin.strokeColor = Palette.skinShade
        shin.lineWidth = 0.8
        shin.position = CGPoint(x: hip.x + r * 0.86, y: hip.y - r * 0.62)
        leg.addChild(shin)

        let sock = SKShapeNode(rectOf: CGSize(width: r * 0.40, height: r * 0.42), cornerRadius: r * 0.16)
        sock.fillColor = .white
        sock.strokeColor = Palette.topShade
        sock.lineWidth = 0.6
        sock.position = CGPoint(x: hip.x + r * 0.88, y: hip.y - r * 1.10)
        leg.addChild(sock)

        let stripe = SKShapeNode(rectOf: CGSize(width: r * 0.40, height: r * 0.09))
        stripe.fillColor = Palette.sockStripe
        stripe.strokeColor = .clear
        stripe.position = CGPoint(x: hip.x + r * 0.88, y: hip.y - r * 1.02)
        leg.addChild(stripe)

        let clog = SKShapeNode(rectOf: CGSize(width: r * 0.62, height: r * 0.34), cornerRadius: r * 0.15)
        clog.fillColor = Palette.clog
        clog.strokeColor = Palette.clogShade
        clog.lineWidth = 0.8
        clog.position = CGPoint(x: hip.x + r * 0.96, y: hip.y - r * 1.38)
        leg.addChild(clog)

        girl.addChild(leg)

        // Suya değdikçe hafifçe sallanıyor.
        let swing = SKAction.sequence([
            .rotate(toAngle: 0.07, duration: 0.9),
            .rotate(toAngle: -0.05, duration: 0.9)
        ])
        swing.timingMode = .easeInEaseOut
        leg.run(.repeatForever(swing))
    }

    private func buildTeddy(at point: CGPoint, scale r: CGFloat) {
        let teddy = SKNode()
        teddy.position = point
        teddy.zPosition = 5

        let bodyRadius = r * 0.44
        let headRadius = r * 0.32

        let body = SKShapeNode(circleOfRadius: bodyRadius)
        body.fillColor = Palette.teddy
        body.strokeColor = Palette.teddyDark
        body.lineWidth = 0.8
        teddy.addChild(body)

        // Yandan tek kulak görünüyor.
        let ear = SKShapeNode(circleOfRadius: headRadius * 0.45)
        ear.fillColor = Palette.teddy
        ear.strokeColor = Palette.teddyDark
        ear.lineWidth = 0.6
        ear.position = CGPoint(x: -headRadius * 0.35, y: bodyRadius * 0.85 + headRadius * 0.7)
        teddy.addChild(ear)

        let head = SKShapeNode(circleOfRadius: headRadius)
        head.fillColor = Palette.teddy
        head.strokeColor = Palette.teddyDark
        head.lineWidth = 0.8
        head.position = CGPoint(x: 0, y: bodyRadius * 0.85)
        teddy.addChild(head)

        let muzzle = SKShapeNode(circleOfRadius: headRadius * 0.24)
        muzzle.fillColor = Palette.teddyDark
        muzzle.strokeColor = .clear
        muzzle.position = CGPoint(x: headRadius * 0.6, y: bodyRadius * 0.85 - headRadius * 0.1)
        teddy.addChild(muzzle)

        girl.addChild(teddy)
    }

    private func buildHead(at point: CGPoint, radius r: CGFloat) {
        let head = SKNode()
        head.position = point
        head.zPosition = 6

        // Arkada toplanmış at kuyruğu.
        let tail = CGMutablePath()
        tail.move(to: CGPoint(x: -r * 0.75, y: -r * 0.05))
        tail.addQuadCurve(to: CGPoint(x: -r * 1.45, y: -r * 1.35),
                          control: CGPoint(x: -r * 1.70, y: -r * 0.45))
        tail.addQuadCurve(to: CGPoint(x: -r * 0.62, y: -r * 0.30),
                          control: CGPoint(x: -r * 0.95, y: -r * 0.85))
        tail.closeSubpath()
        let tailNode = SKShapeNode(path: tail)
        tailNode.fillColor = Palette.hair
        tailNode.strokeColor = .clear
        tailNode.zPosition = -1
        head.addChild(tailNode)

        let tie = SKShapeNode(circleOfRadius: r * 0.14)
        tie.fillColor = Palette.shorts
        tie.strokeColor = Palette.shortsShade
        tie.lineWidth = 0.6
        tie.position = CGPoint(x: -r * 0.72, y: -r * 0.16)
        head.addChild(tie)

        // Saçın arka kütlesi.
        let backHair = SKShapeNode(ellipseOf: CGSize(width: r * 1.9, height: r * 2.1))
        backHair.fillColor = Palette.hair
        backHair.strokeColor = .clear
        backHair.position = CGPoint(x: -r * 0.22, y: r * 0.06)
        head.addChild(backHair)

        // Yüz.
        let face = SKShapeNode(circleOfRadius: r)
        face.fillColor = Palette.skin
        face.strokeColor = .clear
        head.addChild(face)

        // Kâkül: alnı kapatıp öne inen perçem.
        let bangs = CGMutablePath()
        bangs.move(to: CGPoint(x: -r * 1.02, y: r * 0.05))
        bangs.addQuadCurve(to: CGPoint(x: r * 0.92, y: r * 0.30),
                           control: CGPoint(x: -r * 0.10, y: r * 1.65))
        bangs.addQuadCurve(to: CGPoint(x: -r * 1.02, y: r * 0.05),
                           control: CGPoint(x: -r * 0.15, y: r * 0.22))
        bangs.closeSubpath()
        let bangsNode = SKShapeNode(path: bangs)
        bangsNode.fillColor = Palette.hair
        bangsNode.strokeColor = .clear
        head.addChild(bangsNode)

        let shine = SKShapeNode(ellipseOf: CGSize(width: r * 0.55, height: r * 0.2))
        shine.fillColor = Palette.hairShine
        shine.strokeColor = .clear
        shine.position = CGPoint(x: -r * 0.30, y: r * 0.78)
        shine.zRotation = 0.2
        head.addChild(shine)

        // Yandan tek göz.
        let eyeWhite = SKShapeNode(ellipseOf: CGSize(width: r * 0.34, height: r * 0.36))
        eyeWhite.fillColor = .white
        eyeWhite.strokeColor = .clear
        eyeWhite.position = CGPoint(x: r * 0.44, y: -r * 0.02)
        head.addChild(eyeWhite)

        let iris = SKShapeNode(circleOfRadius: r * 0.13)
        iris.fillColor = Palette.eyeBrown
        iris.strokeColor = .clear
        iris.position = CGPoint(x: r * 0.47, y: -r * 0.02)
        head.addChild(iris)

        let pupil = SKShapeNode(circleOfRadius: r * 0.07)
        pupil.fillColor = Palette.hair
        pupil.strokeColor = .clear
        pupil.position = iris.position
        head.addChild(pupil)

        // Yanak ve gülümseme.
        let cheek = SKShapeNode(ellipseOf: CGSize(width: r * 0.3, height: r * 0.18))
        cheek.fillColor = Palette.blush
        cheek.strokeColor = .clear
        cheek.alpha = 0.55
        cheek.position = CGPoint(x: r * 0.32, y: -r * 0.34)
        head.addChild(cheek)

        let smile = CGMutablePath()
        smile.move(to: CGPoint(x: r * 0.52, y: -r * 0.42))
        smile.addQuadCurve(to: CGPoint(x: r * 0.82, y: -r * 0.36),
                           control: CGPoint(x: r * 0.70, y: -r * 0.54))
        let smileNode = SKShapeNode(path: smile)
        smileNode.strokeColor = Palette.hair
        smileNode.lineWidth = r * 0.09
        smileNode.lineCap = .round
        head.addChild(smileNode)

        girl.addChild(head)
    }

    // MARK: - Mürettebat

    /// Kayıktaki hayvanları baştan kurar (kayıtlı ilerlemeyi geri yüklerken).
    func setCompanions(_ kinds: [AnimalKind]) {
        companions = kinds
        rebuildHull()
        buildGirl()
        layOutCompanions(animatingLast: false)
    }

    /// Bölüm sonunda yeni bir hayvan kayığa atlar.
    func addCompanion(_ kind: AnimalKind) {
        guard !companions.contains(kind) else { return }
        companions.append(kind)
        rebuildHull()
        buildGirl()
        layOutCompanions(animatingLast: true)
    }

    private func layOutCompanions(animatingLast: Bool) {
        crewLayer.removeAllChildren()
        guard !companions.isEmpty else { return }

        let animalHeight = height * 0.62
        let seatY = height * 0.30
        // Kızın arkasından kıça doğru diziliyorlar.
        let frontX = -height * 0.10
        let spacing = animalHeight * 0.78

        for (offset, kind) in companions.enumerated() {
            let node = AnimalNode(kind: kind, height: animalHeight)
            node.position = CGPoint(x: frontX - CGFloat(offset) * spacing, y: seatY)
            node.zPosition = CGFloat(3 - offset)
            crewLayer.addChild(node)

            if animatingLast && offset == companions.count - 1 {
                // Yukarıdan atlayıp yerine oturuyor.
                node.setScale(0.2)
                node.position.y += height * 2.2
                node.run(.group([
                    .move(to: CGPoint(x: node.position.x, y: seatY), duration: 0.45),
                    .scale(to: 1, duration: 0.45)
                ]))
            }
        }
    }

    // MARK: - Su izi

    private func buildWake() {
        let emitter = SKEmitterNode()
        emitter.particleTexture = TextureFactory.softCircle(diameter: 28, color: Palette.foam)
        emitter.particleBirthRate = 70
        emitter.particleLifetime = 0.9
        emitter.particleLifetimeRange = 0.4
        emitter.particleSize = CGSize(width: height * 0.5, height: height * 0.5)
        emitter.particleScaleSpeed = -0.45
        emitter.particleAlpha = 0.6
        emitter.particleAlphaSpeed = -0.65
        emitter.particleColor = Palette.foam
        emitter.particleColorBlendFactor = 1
        emitter.particlePositionRange = CGVector(dx: height * 0.3, dy: 3)
        emitter.emissionAngle = .pi
        emitter.emissionAngleRange = 0.8
        emitter.particleSpeed = 60
        emitter.particleSpeedRange = 30
        emitter.position = CGPoint(x: -baseLength * 0.48, y: 0)
        emitter.zPosition = -1
        addChild(emitter)
        wake = emitter
    }

    func setWakeTarget(_ node: SKNode) { wake?.targetNode = node }

    func setWakeActive(_ active: Bool) { wake?.particleBirthRate = active ? 70 : 0 }

    // MARK: - Hareket

    /// Zıplarken burun kalkar, inerken düşer; suda dalganın eğimine oturur.
    func setPitch(_ angle: CGFloat) {
        pitch = angle
        visual.zRotation = angle
    }

    /// Suya iniş: kısa bir çömelme ve sıçrama.
    func landingSquash() {
        visual.removeAction(forKey: "squash")
        visual.run(.sequence([
            .scaleX(to: 1.10, y: 0.85, duration: 0.07),
            .scaleX(to: 1.0, y: 1.0, duration: 0.16)
        ]), withKey: "squash")
    }

    /// Can kaybı: kırmızı yanıp sönme.
    func flashHurt(duration: TimeInterval) {
        visual.removeAction(forKey: "hurt")
        let blink = SKAction.sequence([
            .fadeAlpha(to: 0.35, duration: 0.1),
            .fadeAlpha(to: 1.0, duration: 0.1)
        ])
        let count = max(1, Int(duration / 0.2))
        visual.run(.sequence([.repeat(blink, count: count), .fadeAlpha(to: 1, duration: 0)]),
                   withKey: "hurt")
    }

    func capsize(in layer: SKNode) {
        setWakeActive(false)
        visual.removeAllActions()
        visual.run(.group([
            .rotate(byAngle: -2.2, duration: 0.9),
            .moveBy(x: -20, y: -height * 2.2, duration: 0.9),
            .fadeAlpha(to: 0.2, duration: 0.9)
        ]))
        splash(in: layer, strength: 1.4)
    }

    /// Suya çarpma köpüğü.
    func splash(in layer: SKNode, strength: CGFloat = 1) {
        let emitter = SKEmitterNode()
        emitter.particleTexture = TextureFactory.softCircle(diameter: 26, color: Palette.foam)
        emitter.numParticlesToEmit = Int(40 * strength)
        emitter.particleBirthRate = 1800
        emitter.particleLifetime = 0.6
        emitter.particleLifetimeRange = 0.3
        emitter.particleSize = CGSize(width: height * 0.35, height: height * 0.35)
        emitter.particleScaleSpeed = -0.6
        emitter.particleAlphaSpeed = -1.4
        emitter.particleColor = Palette.foam
        emitter.particleColorBlendFactor = 1
        emitter.emissionAngle = .pi / 2
        emitter.emissionAngleRange = .pi * 0.9
        emitter.particleSpeed = 190 * strength
        emitter.particleSpeedRange = 120
        emitter.yAcceleration = -700
        emitter.position = position
        emitter.zPosition = 40
        layer.addChild(emitter)
        emitter.run(.sequence([.wait(forDuration: 1.4), .removeFromParent()]))
    }

    func reset(at point: CGPoint) {
        position = point
        visual.removeAllActions()
        visual.alpha = 1
        visual.setScale(1)
        visual.zRotation = 0
        pitch = 0
        setWakeActive(true)
    }
}
