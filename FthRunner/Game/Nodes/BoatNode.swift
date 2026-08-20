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
        flagNode.fillColor = Palette.dress
        flagNode.strokeColor = Palette.hullDark
        flagNode.lineWidth = 1
        flagNode.position = CGPoint(x: halfL - height * 0.21, y: height * 1.28)
        hullLayer.addChild(flagNode)
        flagNode.run(.repeatForever(.sequence([
            .scaleX(to: 0.82, duration: 0.5),
            .scaleX(to: 1.0, duration: 0.5)
        ])))
    }

    // MARK: - Kız ve ayıcık

    private func buildGirl() {
        girl.removeAllChildren()
        let r = height * 0.30                       // kafa yarıçapı
        let seatY = height * 0.34
        let bodyX = -height * 0.05
        girl.position = CGPoint(x: length * 0.06, y: 0)

        // Gövde ve can yeleği.
        let torso = SKShapeNode(ellipseOf: CGSize(width: r * 1.5, height: r * 1.7))
        torso.fillColor = Palette.dress
        torso.strokeColor = Palette.hullDark
        torso.lineWidth = 1
        torso.position = CGPoint(x: bodyX, y: seatY + r * 0.55)
        girl.addChild(torso)

        let vest = SKShapeNode(rectOf: CGSize(width: r * 1.35, height: r * 1.05), cornerRadius: r * 0.3)
        vest.fillColor = Palette.lifeVest
        vest.strokeColor = Palette.hullDark
        vest.lineWidth = 1
        vest.position = CGPoint(x: bodyX, y: seatY + r * 0.55)
        girl.addChild(vest)

        // Öne uzanan kol — ayıcığı tutuyor.
        let arm = SKShapeNode(ellipseOf: CGSize(width: r * 0.85, height: r * 0.36))
        arm.fillColor = Palette.skin
        arm.strokeColor = Palette.hullDark
        arm.lineWidth = 0.8
        arm.position = CGPoint(x: bodyX + r * 0.72, y: seatY + r * 0.42)
        arm.zRotation = -0.18
        arm.zPosition = 3
        girl.addChild(arm)

        buildTeddy(at: CGPoint(x: bodyX + r * 1.05, y: seatY + r * 0.50), scale: r)
        buildHead(at: CGPoint(x: bodyX + r * 0.10, y: seatY + r * 1.85), radius: r)
    }

    private func buildTeddy(at point: CGPoint, scale r: CGFloat) {
        let teddy = SKNode()
        teddy.position = point
        teddy.zPosition = 2

        let bodyRadius = r * 0.34
        let headRadius = r * 0.26

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
        head.zPosition = 4

        // Arkaya dökülen saç.
        let backHair = SKShapeNode(ellipseOf: CGSize(width: r * 1.85, height: r * 2.3))
        backHair.fillColor = Palette.hair
        backHair.strokeColor = .clear
        backHair.position = CGPoint(x: -r * 0.28, y: -r * 0.42)
        head.addChild(backHair)

        // Yüz.
        let face = SKShapeNode(circleOfRadius: r)
        face.fillColor = Palette.skin
        face.strokeColor = .clear
        head.addChild(face)

        // Kâkül: alnın üstünü kaplayıp öne doğru inen perçem.
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
        let eye = SKShapeNode(circleOfRadius: r * 0.11)
        eye.fillColor = Palette.hullDark
        eye.strokeColor = .clear
        eye.position = CGPoint(x: r * 0.42, y: -r * 0.02)
        head.addChild(eye)

        // Yanak ve gülümseme.
        let cheek = SKShapeNode(ellipseOf: CGSize(width: r * 0.3, height: r * 0.18))
        cheek.fillColor = Palette.skinShade
        cheek.strokeColor = .clear
        cheek.alpha = 0.7
        cheek.position = CGPoint(x: r * 0.30, y: -r * 0.32)
        head.addChild(cheek)

        let smile = CGMutablePath()
        smile.move(to: CGPoint(x: r * 0.52, y: -r * 0.40))
        smile.addQuadCurve(to: CGPoint(x: r * 0.82, y: -r * 0.34),
                           control: CGPoint(x: r * 0.70, y: -r * 0.52))
        let smileNode = SKShapeNode(path: smile)
        smileNode.strokeColor = Palette.hullDark
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
