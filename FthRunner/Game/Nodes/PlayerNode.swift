import SpriteKit

/// Oyuncunun gemisi: gövde, parlama halesi ve arkasındaki iz.
final class PlayerNode: SKNode {

    let radius: CGFloat
    private let body = SKShapeNode()
    private let glow = SKSpriteNode()
    private var trail: SKEmitterNode?

    init(radius: CGFloat) {
        self.radius = radius
        super.init()
        buildGlow()
        buildBody()
        buildTrail()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) kullanılmıyor") }

    // MARK: - Kurulum

    private func buildGlow() {
        let diameter = radius * 7
        glow.texture = TextureFactory.softCircle(diameter: diameter, color: Palette.playerGlow)
        glow.size = CGSize(width: diameter, height: diameter)
        glow.alpha = 0.5
        glow.blendMode = .add
        glow.zPosition = -1
        addChild(glow)
    }

    private func buildBody() {
        // Yukarı bakan, köşeleri yumuşatılmış bir ok.
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: radius * 1.5))
        path.addLine(to: CGPoint(x: radius, y: -radius))
        path.addLine(to: CGPoint(x: 0, y: -radius * 0.45))
        path.addLine(to: CGPoint(x: -radius, y: -radius))
        path.closeSubpath()

        body.path = path
        body.fillColor = Palette.player
        body.strokeColor = .white
        body.lineWidth = 1.5
        body.lineJoin = .round
        addChild(body)
    }

    private func buildTrail() {
        let emitter = SKEmitterNode()
        emitter.particleTexture = TextureFactory.softCircle(diameter: 24, color: Palette.player)
        emitter.particleBirthRate = 140
        emitter.particleLifetime = 0.45
        emitter.particleLifetimeRange = 0.2
        emitter.particleSize = CGSize(width: radius * 1.4, height: radius * 1.4)
        emitter.particleScale = 1
        emitter.particleScaleSpeed = -1.8
        emitter.particleAlpha = 0.7
        emitter.particleAlphaSpeed = -1.6
        emitter.particleColor = Palette.player
        emitter.particleColorBlendFactor = 1
        emitter.particleBlendMode = .add
        emitter.particlePositionRange = CGVector(dx: radius * 0.8, dy: 2)
        emitter.emissionAngle = -.pi / 2
        emitter.emissionAngleRange = 0.5
        emitter.particleSpeed = 90
        emitter.particleSpeedRange = 40
        emitter.position = CGPoint(x: 0, y: -radius * 0.6)
        emitter.zPosition = -2
        addChild(emitter)
        trail = emitter
    }

    // MARK: - Davranış

    /// Yatay hıza göre gemiyi hafifçe yatırır — hareket hissi verir.
    func applyBank(horizontalVelocity: CGFloat) {
        let maxAngle: CGFloat = 0.42
        let target = max(-maxAngle, min(maxAngle, -horizontalVelocity / 1400))
        body.zRotation += (target - body.zRotation) * 0.25
    }

    /// İz parçacıkları gemiyle birlikte taşınmasın diye dünya katmanına bağlanır.
    /// Sahne kurulumunda bir kez çağrılmalı.
    func setTrailTarget(_ node: SKNode) {
        trail?.targetNode = node
    }

    func setTrailActive(_ active: Bool) {
        trail?.particleBirthRate = active ? 140 : 0
    }

    /// Çarpışma anı: gemi kaybolur, yerine patlama gelir.
    func explode(in layer: SKNode) {
        setTrailActive(false)
        isHidden = true

        let burst = SKEmitterNode()
        burst.particleTexture = TextureFactory.softCircle(diameter: 28, color: Palette.player)
        burst.numParticlesToEmit = 90
        burst.particleBirthRate = 3000
        burst.particleLifetime = 0.7
        burst.particleLifetimeRange = 0.3
        burst.particleSize = CGSize(width: radius, height: radius)
        burst.particleScaleSpeed = -1.2
        burst.particleAlphaSpeed = -1.3
        burst.particleColor = Palette.player
        burst.particleColorBlendFactor = 1
        burst.particleBlendMode = .add
        burst.emissionAngleRange = .pi * 2
        burst.particleSpeed = 320
        burst.particleSpeedRange = 220
        burst.position = position
        burst.zPosition = 50
        layer.addChild(burst)
        burst.run(.sequence([.wait(forDuration: 1.4), .removeFromParent()]))
    }

    func reset(at point: CGPoint) {
        position = point
        isHidden = false
        body.zRotation = 0
        setTrailActive(true)
    }
}
