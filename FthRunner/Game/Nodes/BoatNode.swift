import SpriteKit

/// Oyuncunun kayığı ve içindeki kız: kahverengi kâkküllü saç,
/// turuncu can yeleği ve kucağında küçük gri ayıcık.
/// Bütün çizim kod ile yapılıyor; hiçbir görsel dosyaya bağlı değil.
final class BoatNode: SKNode {

    let collisionRadius: CGFloat
    private let width: CGFloat
    private var length: CGFloat { width * 1.36 }

    /// Yatırma ve girdap dönüşü buraya uygulanıyor ki çarpışma dairesi sabit kalsın.
    private let visual = SKNode()
    /// Dalgadaki sürekli yalpalama burada döner; `visual` ile çakışmasın diye ayrı.
    private let rocker = SKNode()
    private let girl = SKNode()
    private var wake: SKEmitterNode?
    private var bankAngle: CGFloat = 0
    private var spinAngle: CGFloat = 0

    init(width: CGFloat, collisionRadius: CGFloat) {
        self.width = width
        self.collisionRadius = collisionRadius
        super.init()

        addChild(visual)
        visual.addChild(rocker)
        buildWake()
        buildHull()
        buildGirl()
        rocker.addChild(girl)
        startIdleMotion()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) kullanılmıyor") }

    // MARK: - Kayık gövdesi

    /// Pruvası sivri, kıçı yuvarlak ahşap tekne silueti.
    private func hullPath(scale: CGFloat) -> CGPath {
        let halfW = width / 2 * scale
        let halfL = length / 2 * scale
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: halfL))
        path.addCurve(to: CGPoint(x: halfW, y: -halfL * 0.35),
                      control1: CGPoint(x: halfW * 0.75, y: halfL * 0.60),
                      control2: CGPoint(x: halfW, y: halfL * 0.05))
        path.addQuadCurve(to: CGPoint(x: -halfW, y: -halfL * 0.35),
                          control: CGPoint(x: 0, y: -halfL * 1.30))
        path.addCurve(to: CGPoint(x: 0, y: halfL),
                      control1: CGPoint(x: -halfW, y: halfL * 0.05),
                      control2: CGPoint(x: -halfW * 0.75, y: halfL * 0.60))
        path.closeSubpath()
        return path
    }

    private func buildHull() {
        let outer = SKShapeNode(path: hullPath(scale: 1))
        outer.fillColor = Palette.hull
        outer.strokeColor = Palette.hullDark
        outer.lineWidth = 2
        outer.lineJoin = .round
        rocker.addChild(outer)

        // İç boşluk — tekneye derinlik veriyor.
        let inner = SKShapeNode(path: hullPath(scale: 0.72))
        inner.fillColor = Palette.hullLight
        inner.strokeColor = Palette.hullDark
        inner.lineWidth = 1
        inner.position = CGPoint(x: 0, y: -length * 0.02)
        rocker.addChild(inner)

        // Oturma tahtaları.
        for offset in [length * 0.16, -length * 0.20] {
            let plank = SKShapeNode(rectOf: CGSize(width: width * 0.62, height: 4), cornerRadius: 2)
            plank.fillColor = Palette.hull
            plank.strokeColor = Palette.hullDark
            plank.lineWidth = 0.5
            plank.position = CGPoint(x: 0, y: offset)
            rocker.addChild(plank)
        }
    }

    // MARK: - Kız ve ayıcık

    private func buildGirl() {
        let headRadius = width * 0.185
        let headY = width * 0.10

        buildBodyAndArms(headRadius: headRadius, headY: headY)
        buildTeddy(headRadius: headRadius, headY: headY)
        buildHeadAndHair(headRadius: headRadius, headY: headY)
    }

    private func buildBodyAndArms(headRadius r: CGFloat, headY: CGFloat) {
        // Elbise
        let dress = SKShapeNode(ellipseOf: CGSize(width: r * 2.3, height: r * 1.9))
        dress.fillColor = Palette.dress
        dress.strokeColor = Palette.hullDark
        dress.lineWidth = 1
        dress.position = CGPoint(x: 0, y: headY - r * 1.35)
        girl.addChild(dress)

        // Can yeleği — hem renk katıyor hem denizde mantıklı duruyor.
        let vest = SKShapeNode(rectOf: CGSize(width: r * 1.9, height: r * 1.15), cornerRadius: r * 0.35)
        vest.fillColor = Palette.lifeVest
        vest.strokeColor = Palette.hullDark
        vest.lineWidth = 1
        vest.position = CGPoint(x: 0, y: headY - r * 1.25)
        girl.addChild(vest)

        // Ayıcığı saran iki küçük kol.
        for side in [CGFloat(-1), 1] {
            let arm = SKShapeNode(ellipseOf: CGSize(width: r * 0.52, height: r * 1.05))
            arm.fillColor = Palette.skin
            arm.strokeColor = Palette.hullDark
            arm.lineWidth = 0.8
            arm.position = CGPoint(x: side * r * 1.05, y: headY - r * 1.45)
            arm.zRotation = side * -0.45
            girl.addChild(arm)
        }
    }

    private func buildTeddy(headRadius r: CGFloat, headY: CGFloat) {
        let teddy = SKNode()
        teddy.position = CGPoint(x: 0, y: headY - r * 1.75)
        teddy.zPosition = 1

        let bodyRadius = r * 0.46
        let headRadiusTeddy = r * 0.34

        let bodyShape = SKShapeNode(circleOfRadius: bodyRadius)
        bodyShape.fillColor = Palette.teddy
        bodyShape.strokeColor = Palette.teddyDark
        bodyShape.lineWidth = 0.8
        teddy.addChild(bodyShape)

        let headShape = SKShapeNode(circleOfRadius: headRadiusTeddy)
        headShape.fillColor = Palette.teddy
        headShape.strokeColor = Palette.teddyDark
        headShape.lineWidth = 0.8
        headShape.position = CGPoint(x: 0, y: bodyRadius * 0.95)
        teddy.addChild(headShape)

        for side in [CGFloat(-1), 1] {
            let ear = SKShapeNode(circleOfRadius: headRadiusTeddy * 0.42)
            ear.fillColor = Palette.teddy
            ear.strokeColor = Palette.teddyDark
            ear.lineWidth = 0.6
            ear.position = CGPoint(x: side * headRadiusTeddy * 0.75,
                                   y: bodyRadius * 0.95 + headRadiusTeddy * 0.72)
            teddy.addChild(ear)
        }

        // Burun
        let muzzle = SKShapeNode(circleOfRadius: headRadiusTeddy * 0.22)
        muzzle.fillColor = Palette.teddyDark
        muzzle.strokeColor = .clear
        muzzle.position = CGPoint(x: 0, y: bodyRadius * 0.95 - headRadiusTeddy * 0.25)
        teddy.addChild(muzzle)

        girl.addChild(teddy)
    }

    private func buildHeadAndHair(headRadius r: CGFloat, headY: CGFloat) {
        let head = SKNode()
        head.position = CGPoint(x: 0, y: headY)
        head.zPosition = 2

        // Arkadaki saç kütlesi — omuz hizasına inen bob kesim.
        let hairBack = SKShapeNode(ellipseOf: CGSize(width: r * 2.5, height: r * 2.5))
        hairBack.fillColor = Palette.hair
        hairBack.strokeColor = .clear
        hairBack.position = CGPoint(x: 0, y: -r * 0.18)
        head.addChild(hairBack)

        for side in [CGFloat(-1), 1] {
            let strand = SKShapeNode(ellipseOf: CGSize(width: r * 0.85, height: r * 1.7))
            strand.fillColor = Palette.hair
            strand.strokeColor = .clear
            strand.position = CGPoint(x: side * r * 0.92, y: -r * 0.75)
            head.addChild(strand)
        }

        // Yüz
        let face = SKShapeNode(circleOfRadius: r * 0.98)
        face.fillColor = Palette.skin
        face.strokeColor = .clear
        head.addChild(face)

        // Kâkül: alnı kapatan, ortası hafif inen bir perçem.
        let bangs = CGMutablePath()
        bangs.move(to: CGPoint(x: -r * 0.99, y: r * 0.12))
        bangs.addQuadCurve(to: CGPoint(x: r * 0.99, y: r * 0.12),
                           control: CGPoint(x: 0, y: r * 1.75))
        bangs.addQuadCurve(to: CGPoint(x: -r * 0.99, y: r * 0.12),
                           control: CGPoint(x: 0, y: -r * 0.10))
        bangs.closeSubpath()
        let bangsNode = SKShapeNode(path: bangs)
        bangsNode.fillColor = Palette.hair
        bangsNode.strokeColor = .clear
        head.addChild(bangsNode)

        // Saç parlaması
        let shine = SKShapeNode(ellipseOf: CGSize(width: r * 0.7, height: r * 0.28))
        shine.fillColor = Palette.hairShine
        shine.strokeColor = .clear
        shine.position = CGPoint(x: -r * 0.3, y: r * 0.75)
        shine.zRotation = 0.25
        head.addChild(shine)

        // Gözler ve ağız
        for side in [CGFloat(-1), 1] {
            let eye = SKShapeNode(circleOfRadius: r * 0.13)
            eye.fillColor = Palette.hullDark
            eye.strokeColor = .clear
            eye.position = CGPoint(x: side * r * 0.36, y: -r * 0.12)
            head.addChild(eye)
        }

        let smile = CGMutablePath()
        smile.move(to: CGPoint(x: -r * 0.28, y: -r * 0.28))
        smile.addQuadCurve(to: CGPoint(x: r * 0.28, y: -r * 0.28),
                           control: CGPoint(x: 0, y: -r * 0.56))
        let smileNode = SKShapeNode(path: smile)
        smileNode.strokeColor = Palette.hullDark
        smileNode.lineWidth = r * 0.12
        smileNode.lineCap = .round
        head.addChild(smileNode)

        girl.addChild(head)
    }

    // MARK: - Su izi

    private func buildWake() {
        let emitter = SKEmitterNode()
        emitter.particleTexture = TextureFactory.softCircle(diameter: 28, color: Palette.foam)
        emitter.particleBirthRate = 90
        emitter.particleLifetime = 0.8
        emitter.particleLifetimeRange = 0.35
        emitter.particleSize = CGSize(width: width * 0.42, height: width * 0.42)
        emitter.particleScaleSpeed = -0.55
        emitter.particleAlpha = 0.55
        emitter.particleAlphaSpeed = -0.7
        emitter.particleColor = Palette.foam
        emitter.particleColorBlendFactor = 1
        emitter.particlePositionRange = CGVector(dx: width * 0.55, dy: 3)
        emitter.emissionAngle = -.pi / 2
        emitter.emissionAngleRange = 0.7
        emitter.particleSpeed = 70
        emitter.particleSpeedRange = 35
        emitter.position = CGPoint(x: 0, y: -length * 0.45)
        emitter.zPosition = -1
        addChild(emitter)
        wake = emitter
    }

    /// Köpük kayıkla birlikte taşınmasın diye dünya katmanına bağlanır.
    func setWakeTarget(_ node: SKNode) {
        wake?.targetNode = node
    }

    // MARK: - Hareket

    private func startIdleMotion() {
        // Dalgada hafif yalpalama.
        let rock = SKAction.sequence([
            .rotate(byAngle: 0.05, duration: 1.1),
            .rotate(byAngle: -0.10, duration: 2.2),
            .rotate(byAngle: 0.05, duration: 1.1)
        ])
        rock.timingMode = .easeInEaseOut
        girl.run(.repeatForever(.sequence([
            .moveBy(x: 0, y: 1.5, duration: 1.0),
            .moveBy(x: 0, y: -1.5, duration: 1.0)
        ])))
        rocker.run(.repeatForever(rock), withKey: "idleRock")
    }

    /// Yatay hıza göre kayığı yatırır — dönüş hissi verir.
    func applyBank(horizontalVelocity: CGFloat) {
        let maxAngle: CGFloat = 0.36
        let target = max(-maxAngle, min(maxAngle, -horizontalVelocity / 1500))
        bankAngle += (target - bankAngle) * 0.22
        updateRotation()
    }

    /// Girdabın içindeyken kayık kendi ekseninde dönmeye başlar.
    /// Açıyı sahne biriktiriyor, burada sadece uygulanıyor.
    func setSpin(_ angle: CGFloat) {
        spinAngle = angle
        updateRotation()
    }

    private func updateRotation() {
        visual.zRotation = bankAngle + spinAngle
    }

    func setWakeActive(_ active: Bool) {
        wake?.particleBirthRate = active ? 90 : 0
    }

    // MARK: - Devrilme

    func capsize(in layer: SKNode) {
        setWakeActive(false)
        rocker.removeAction(forKey: "idleRock")
        visual.run(.group([
            .rotate(byAngle: 2.6, duration: 0.8),
            .scale(to: 0.55, duration: 0.8),
            .fadeAlpha(to: 0.25, duration: 0.8)
        ]))

        let splash = SKEmitterNode()
        splash.particleTexture = TextureFactory.softCircle(diameter: 30, color: Palette.foam)
        splash.numParticlesToEmit = 80
        splash.particleBirthRate = 2500
        splash.particleLifetime = 0.8
        splash.particleLifetimeRange = 0.4
        splash.particleSize = CGSize(width: width * 0.35, height: width * 0.35)
        splash.particleScaleSpeed = -0.5
        splash.particleAlphaSpeed = -1.1
        splash.particleColor = Palette.foam
        splash.particleColorBlendFactor = 1
        splash.emissionAngleRange = .pi * 2
        splash.particleSpeed = 260
        splash.particleSpeedRange = 180
        splash.position = position
        splash.zPosition = 50
        layer.addChild(splash)
        splash.run(.sequence([.wait(forDuration: 1.6), .removeFromParent()]))
    }

    func reset(at point: CGPoint) {
        position = point
        bankAngle = 0
        spinAngle = 0
        visual.removeAllActions()
        visual.alpha = 1
        visual.setScale(1)
        visual.zRotation = 0
        rocker.removeAllActions()
        rocker.zRotation = 0
        girl.removeAllActions()
        girl.position = .zero
        startIdleMotion()
        setWakeActive(true)
    }
}
