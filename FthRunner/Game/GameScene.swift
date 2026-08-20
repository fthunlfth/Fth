import SpriteKit

/// Yandan görünen, bölüm bölüm ilerleyen oyunun tamamı:
/// dünya sola akar, kayık dalganın üstünde durur, dokunuşla zıplar.
/// Fizik motoru yok — hareket ve çarpışma elle hesaplanıyor, böylece
/// `Tuning` içindeki sayılar birebir öngörülebilir sonuç veriyor.
final class GameScene: SKScene {

    weak var state: GameState?

    // MARK: - Katmanlar
    private let sky = SkyNode()
    private let sea = SeaNode()
    private let worldLayer = SKNode()
    private let titleLayer = SKNode()
    private let effectsLayer = SKNode()
    private let titleScene = TitleSceneNode()

    // MARK: - Oyun nesneleri
    private var boat: BoatNode!
    private var obstacles: [ObstacleNode] = []
    private var starfishes: [StarfishNode] = []
    private var goalIsland: GoalIslandNode?

    // MARK: - Durum
    private var level = Level.level(at: 0)
    private var isRunning = false
    private var lastUpdateTime: TimeInterval = 0
    private var elapsed: TimeInterval = 0
    /// Dünyanın kaydırılmış toplam mesafesi. Bölüm ilerlemesi bu.
    private var cameraX: CGFloat = 0
    private var scrollSpeed: CGFloat = 0
    private var bonusScore = 0
    private var nextSpawnWorldX: CGFloat = 0
    private var invulnerableUntil: TimeInterval = 0
    private var isCelebrating = false

    // MARK: - Kayık hareketi
    private var boatY: CGFloat = 0
    private var velocityY: CGFloat = 0
    private var isGrounded = true
    private var coyoteTimer: TimeInterval = 0
    private var jumpBufferTimer: TimeInterval = 0
    private var holdTimer: TimeInterval = 0
    private var isHoldingJump = false

    private var boatScreenX: CGFloat { size.width * Tuning.boatScreenXRatio }
    private var waterLine: CGFloat { size.height * Tuning.waterLineRatio }
    private var isInvulnerable: Bool { elapsed < invulnerableUntil }

    // MARK: - Sahne kurulumu

    override func didMove(to view: SKView) {
        scaleMode = .resizeFill
        anchorPoint = .zero

        sky.zPosition = 0
        sea.zPosition = 10
        worldLayer.zPosition = 20
        titleLayer.zPosition = 24
        effectsLayer.zPosition = 40
        addChild(sky)
        addChild(sea)
        addChild(worldLayer)
        addChild(titleLayer)
        addChild(effectsLayer)
        titleLayer.addChild(titleScene)

        boat = BoatNode(length: Tuning.boatLength, height: Tuning.boatHeight)
        boat.zPosition = 25
        worldLayer.addChild(boat)
        boat.setWakeTarget(worldLayer)

        applyTheme()
        buildTitleScene()
        showTitle(true)
        resetToIdle()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 0, sky.parent != nil else { return }
        applyTheme()
        buildTitleScene()
    }

    private func applyTheme() {
        sky.build(size: size, waterLine: waterLine, theme: level.sky)
        sea.build(size: size, waterLine: waterLine, theme: level.sky)
        backgroundColor = level.sky.skyTop
    }

    // MARK: - Açılış tablosu

    private func buildTitleScene() {
        let characterHeight = min(size.height * 0.46, 210)
        titleScene.build(characterHeight: characterHeight)
        titleScene.position = CGPoint(x: size.width * 0.73, y: waterLine + 4)
    }

    /// Menüde Hira kumsalda duruyor; oynarken yerini kayığa bırakıyor.
    func showTitle(_ show: Bool) {
        titleLayer.isHidden = !show
        boat.isHidden = show
    }

    /// Menüye dönüş: ilk bölümün sabahına geri sar ve tabloyu göster.
    func showMenu() {
        level = Level.level(at: 0)
        applyTheme()
        resetToIdle()
        showTitle(true)
    }

    // MARK: - Bölüm yönetimi

    /// Menüde ve bölüm kartında görünen sakin hâl.
    func resetToIdle() {
        isRunning = false
        isCelebrating = false
        elapsed = 0
        cameraX = 0
        // Menüde ve bölüm kartında deniz yavaşça akmaya devam etsin.
        scrollSpeed = level.scrollSpeed * 0.22
        bonusScore = 0
        lastUpdateTime = 0
        invulnerableUntil = 0
        velocityY = 0
        isGrounded = true
        coyoteTimer = 0
        jumpBufferTimer = 0
        holdTimer = 0
        isHoldingJump = false

        clearWorld()

        boatY = waterLine
        boat.reset(at: CGPoint(x: boatScreenX, y: boatY))
        boat.setCompanions(state?.companions ?? [])
        worldLayer.position = .zero
    }

    /// Bölüm kartı açılırken: temayı o bölüme çevir, sahneyi sakin hâle al.
    func prepare(level index: Int) {
        level = Level.level(at: index)
        applyTheme()
        resetToIdle()
        showTitle(false)
    }

    /// Bölüm kartından oynamaya geçiş.
    func startLevel(_ index: Int) {
        prepare(level: index)
        scrollSpeed = level.scrollSpeed
        nextSpawnWorldX = size.width + 220
        isRunning = true
        Haptics.prepare()
        state?.beginLevel()
    }

    private func clearWorld() {
        for obstacle in obstacles { obstacle.removeFromParent() }
        obstacles.removeAll()
        for starfish in starfishes { starfish.removeFromParent() }
        starfishes.removeAll()
        goalIsland?.removeFromParent()
        goalIsland = nil
    }

    // MARK: - Ana döngü

    override func update(_ currentTime: TimeInterval) {
        // İlk kare ve arka plandan dönüşlerde dev bir delta oluşmasın.
        let rawDelta = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        let deltaTime = min(max(rawDelta, 0), 1.0 / 30.0)
        elapsed += deltaTime

        cameraX += scrollSpeed * CGFloat(deltaTime)

        sky.update(cameraX: cameraX)
        sea.update(cameraX: cameraX, time: elapsed, scrollSpeed: scrollSpeed, deltaTime: deltaTime)

        updateBoat(deltaTime: deltaTime)
        repositionWorldObjects()

        guard isRunning else { return }

        updateGoal(deltaTime: deltaTime)
        updateObstacles(deltaTime: deltaTime)
        updateSpawning()
        updateScore()
        checkCollisions()
    }

    // MARK: - Kayık

    private func updateBoat(deltaTime: TimeInterval) {
        let surfaceY = sea.surfaceY(screenX: boatScreenX, cameraX: cameraX, time: elapsed)

        if isGrounded {
            boatY = surfaceY
            velocityY = 0
            coyoteTimer = Tuning.coyoteTime
            // Dalganın eğimine yatıyor.
            let slope = Wave.slope(atWorldX: cameraX + boatScreenX, time: elapsed)
            boat.setPitch(atan(slope) * 0.85)
        } else {
            coyoteTimer = max(0, coyoteTimer - deltaTime)
            // Parmağı basılı tuttukça yükseliş uzuyor (Mario tarzı değişken zıplama).
            let holdingRise = isHoldingJump && velocityY > 0 && holdTimer > 0
            let scale = holdingRise ? Tuning.jumpHoldGravityScale : 1
            holdTimer = max(0, holdTimer - deltaTime)

            velocityY -= Tuning.gravity * scale * CGFloat(deltaTime)
            boatY += velocityY * CGFloat(deltaTime)
            boat.setPitch(max(-Tuning.jumpPitchAngle, min(Tuning.jumpPitchAngle, velocityY / 2200)))

            if boatY <= surfaceY && velocityY <= 0 {
                land(at: surfaceY)
            }
        }

        jumpBufferTimer = max(0, jumpBufferTimer - deltaTime)
        if jumpBufferTimer > 0 && (isGrounded || coyoteTimer > 0) {
            performJump()
        }

        boat.position = CGPoint(x: boatScreenX, y: boatY)
    }

    private func performJump() {
        velocityY = Tuning.jumpImpulse
        isGrounded = false
        coyoteTimer = 0
        jumpBufferTimer = 0
        holdTimer = Tuning.maxJumpHoldTime
        boat.setWakeActive(false)
        boat.splash(in: effectsLayer, strength: 0.6)
        Haptics.jump()
        SoundEngine.shared.play(.jump)
    }

    private func land(at surfaceY: CGFloat) {
        let impact = min(1.6, abs(velocityY) / Tuning.jumpImpulse)
        boatY = surfaceY
        velocityY = 0
        isGrounded = true
        boat.setWakeActive(true)
        boat.landingSquash()
        boat.splash(in: effectsLayer, strength: 0.5 + impact)
        // Sert iniş daha gür şapırdasın.
        SoundEngine.shared.play(.splash, volume: Float(min(1, 0.45 + impact * 0.45)))
        if impact > 0.4 { Haptics.land() }
    }

    // MARK: - Dünya nesnelerinin yerleşimi

    /// Engeller dünya koordinatında yaşıyor; ekran konumu her karede
    /// kameradan ve su yüzeyinden hesaplanıyor.
    private func repositionWorldObjects() {
        for obstacle in obstacles {
            let screenX = obstacle.worldX - cameraX
            let baseY = obstacle.ridesWave
                ? sea.surfaceY(screenX: screenX, cameraX: cameraX, time: elapsed)
                : waterLine
            obstacle.position = CGPoint(x: screenX, y: baseY + obstacle.verticalOffset)
        }

        for starfish in starfishes {
            starfish.position.x = starfish.worldX - cameraX
        }

        if let island = goalIsland {
            let screenX = island.worldX - cameraX
            island.position = CGPoint(x: screenX,
                                      y: sea.surfaceY(screenX: screenX, cameraX: cameraX, time: elapsed) - 6)
        }
    }

    private func updateObstacles(deltaTime: TimeInterval) {
        var stillAlive: [ObstacleNode] = []
        for obstacle in obstacles {
            obstacle.advance(deltaTime: deltaTime)

            if !obstacle.hasBeenPassed && obstacle.worldX < cameraX + boatScreenX {
                obstacle.hasBeenPassed = true
                evaluateNearMiss(for: obstacle)
            }

            if obstacle.worldX - cameraX < -240 {
                obstacle.removeFromParent()
            } else {
                stillAlive.append(obstacle)
            }
        }
        obstacles = stillAlive

        starfishes.removeAll { starfish in
            guard starfish.worldX - cameraX < -80 else { return false }
            starfish.removeFromParent()
            return true
        }
    }

    // MARK: - Üretim

    private func updateSpawning() {
        let horizon = cameraX + size.width + 240
        let spawnLimit = level.length - Tuning.goalClearanceDistance

        while nextSpawnWorldX < horizon && nextSpawnWorldX < spawnLimit {
            spawnObstacle(kind: level.kinds.randomElement() ?? .rock, at: nextSpawnWorldX)

            let gap = CGFloat.random(in: level.gapRange)
            // İki engelin arasına deniz yıldızı yayı serpiştiriliyor.
            if Double.random(in: 0...1) < Tuning.starfishChance {
                spawnStarfishArc(centeredAt: nextSpawnWorldX + gap / 2)
            }
            nextSpawnWorldX += gap
        }
    }

    private func spawnObstacle(kind: ObstacleKind, at worldX: CGFloat) {
        let node: ObstacleNode

        switch kind {
        case .rock:
            let rock = RockNode()
            rock.build(width: .random(in: 46...70), height: .random(in: 46...74))
            node = rock

        case .driftwood:
            let log = DriftwoodNode()
            log.build(length: .random(in: 76...118))
            node = log

        case .sharkFin:
            let fin = SharkFinNode()
            fin.build(closingSpeed: .random(in: 55...105))
            node = fin

        case .jellyfish:
            let jellyfish = JellyfishNode()
            jellyfish.build()
            node = jellyfish

        case .net:
            let net = FishingNetNode()
            net.build(height: .random(in: 88...112))
            node = net

        case .seagull:
            let seagull = SeagullNode()
            seagull.build(flyHeight: .random(in: 108...142))
            node = seagull
            // Her martı bağırmasın; ara sıra duyulunca daha canlı oluyor.
            if Double.random(in: 0...1) < 0.35 {
                SoundEngine.shared.play(.seagull)
            }

        case .whirlpool:
            let whirlpool = WhirlpoolNode()
            whirlpool.build(width: .random(in: 130...180))
            node = whirlpool
        }

        node.worldX = worldX
        node.zPosition = 22
        worldLayer.addChild(node)
        obstacles.append(node)
    }

    /// Zıplama yayını takip eden üç deniz yıldızı — nereden atlanacağını da öğretiyor.
    private func spawnStarfishArc(centeredAt worldX: CGFloat) {
        let spacing: CGFloat = 46
        for offset in [-1, 0, 1] {
            let starfish = StarfishNode(radius: Tuning.starfishRadius)
            starfish.worldX = worldX + CGFloat(offset) * spacing
            // Ortadaki en yüksekte: yayın tepesi.
            let lift: CGFloat = offset == 0 ? 118 : 88
            starfish.position = CGPoint(x: starfish.worldX - cameraX, y: waterLine + lift)
            starfish.zPosition = 24
            worldLayer.addChild(starfish)
            starfishes.append(starfish)
        }
    }

    // MARK: - Bölüm sonu

    private func updateGoal(deltaTime: TimeInterval) {
        if goalIsland == nil && cameraX > level.length - size.width {
            let island = GoalIslandNode()
            island.build(reward: level.reward)
            island.worldX = level.length + Tuning.goalSlowdownDistance
            island.zPosition = 21
            worldLayer.addChild(island)
            goalIsland = island
        }

        guard let island = goalIsland else { return }

        // Adaya yaklaştıkça yavaşla, kayığın hizasında dur.
        let stopScreenX = boatScreenX + 130
        let remaining = (island.worldX - cameraX) - stopScreenX
        let ratio = max(0, min(1, remaining / Tuning.goalSlowdownDistance))
        // Taban hız olmadan son metreler asimptotik olarak sürünürdü.
        scrollSpeed = level.scrollSpeed * max(0.2, ratio)

        if remaining <= 6 && !isCelebrating {
            celebrate(island: island)
        }
    }

    private func celebrate(island: GoalIslandNode) {
        isCelebrating = true
        isRunning = false
        scrollSpeed = 0
        // Bölümü bitirme primi; skor artık donduğu için bir kez elle yansıtılıyor.
        bonusScore += Tuning.levelClearScore
        state?.setScore(Int(cameraX / Tuning.distancePerScorePoint) + bonusScore)
        Haptics.celebrate()
        SoundEngine.shared.play(.fanfare)

        let landingPoint = CGPoint(x: boat.position.x - island.position.x - Tuning.boatLength * 0.25,
                                   y: boat.position.y - island.position.y + Tuning.boatHeight * 0.6)
        let reward = level.reward

        island.launchAnimal(to: landingPoint) { [weak self] in
            guard let self else { return }
            self.boat.addCompanion(reward)
            self.confetti()
            self.showJoinBanner(text: reward.greeting)
            // Kutlama sahnede bir an nefes alsın, bölüm sonu kartı sonra gelsin.
            self.run(.sequence([
                .wait(forDuration: 1.3),
                .run { self.state?.completeLevel() }
            ]))
        }
    }

    /// Yeni arkadaş kayığa bindiği anda üstünde beliren şerit.
    private func showJoinBanner(text: String) {
        SoundEngine.shared.play(.sparkle)

        let banner = SKNode()
        banner.zPosition = 70
        banner.position = CGPoint(x: size.width / 2, y: boat.position.y + Tuning.boatHeight * 3.2)

        let label = SKLabelNode(text: text)
        label.fontName = Fonts.roundedName(size: 26, weight: .heavy)
        label.fontSize = 26
        label.fontColor = UIColor.black.withAlphaComponent(0.85)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center

        let padding = CGSize(width: 34, height: 18)
        let plateSize = CGSize(width: label.frame.width + padding.width * 2,
                               height: label.frame.height + padding.height * 2)
        let plate = SKShapeNode(rectOf: plateSize, cornerRadius: plateSize.height / 2)
        plate.fillColor = Palette.lifeVest
        plate.strokeColor = .white
        plate.lineWidth = 2.5

        banner.addChild(plate)
        banner.addChild(label)
        effectsLayer.addChild(banner)

        // Aşağıdan zıplayarak gelip bir süre durup kayboluyor.
        banner.setScale(0.4)
        banner.alpha = 0
        banner.position.y -= 30
        banner.run(.sequence([
            .group([
                .scale(to: 1.08, duration: 0.22),
                .fadeIn(withDuration: 0.18),
                .moveBy(x: 0, y: 30, duration: 0.22)
            ]),
            .scale(to: 1.0, duration: 0.1),
            .wait(forDuration: 1.5),
            .group([.fadeOut(withDuration: 0.35), .moveBy(x: 0, y: 20, duration: 0.35)]),
            .removeFromParent()
        ]))
    }

    private func confetti() {
        let colors: [UIColor] = [Palette.lifeVest, Palette.shorts, Palette.starfish, Palette.foam, Palette.palm]
        for color in colors {
            let emitter = SKEmitterNode()
            emitter.particleTexture = TextureFactory.softCircle(diameter: 20, color: color)
            emitter.numParticlesToEmit = 26
            emitter.particleBirthRate = 320
            emitter.particleLifetime = 1.6
            emitter.particleLifetimeRange = 0.6
            emitter.particleSize = CGSize(width: 9, height: 9)
            emitter.particleAlphaSpeed = -0.6
            emitter.particleColor = color
            emitter.particleColorBlendFactor = 1
            emitter.emissionAngle = .pi / 2
            emitter.emissionAngleRange = 1.5
            emitter.particleSpeed = 320
            emitter.particleSpeedRange = 160
            emitter.yAcceleration = -520
            emitter.position = CGPoint(x: boat.position.x, y: boat.position.y + Tuning.boatHeight)
            emitter.zPosition = 60
            effectsLayer.addChild(emitter)
            emitter.run(.sequence([.wait(forDuration: 2.6), .removeFromParent()]))
        }
    }

    // MARK: - Puan

    private func updateScore() {
        let total = Int(cameraX / Tuning.distancePerScorePoint) + bonusScore
        state?.setScore(total)
        state?.setProgress(Double(cameraX / level.length))
    }

    // MARK: - Çarpışma

    private func checkCollisions() {
        let boatRect = boat.collisionRect.offsetBy(dx: boat.position.x, dy: boat.position.y)

        for starfish in starfishes {
            let disc = CollisionShape.circle(center: starfish.position, radius: starfish.radius)
            guard disc.intersects(rect: boatRect) else { continue }

            starfish.collect()
            starfishes.removeAll { $0 === starfish }
            bonusScore += Tuning.starfishScore
            state?.collectStarfish()
            Haptics.pickup()
            SoundEngine.shared.play(.pickup)
        }

        guard !isInvulnerable else { return }

        for obstacle in obstacles {
            guard abs(obstacle.position.x - boatRect.midX) < 220 else { continue }
            for shape in obstacle.sceneCollisionShapes() where shape.intersects(rect: boatRect) {
                takeHit(from: obstacle)
                return
            }
        }
    }

    private func takeHit(from obstacle: ObstacleNode) {
        // Çarpılan engel dağılıyor ki aynı kare içinde tekrar tekrar vurmasın.
        obstacle.hasBeenPassed = true
        burst(at: obstacle.position, color: Palette.foam)
        obstacle.removeFromParent()
        obstacles.removeAll { $0 === obstacle }

        shakeWorld()

        guard let state else { return }
        if state.loseLife() {
            invulnerableUntil = elapsed + Tuning.invulnerabilityTime
            boat.flashHurt(duration: Tuning.invulnerabilityTime)
            flashScreen(color: Palette.buoy, alpha: 0.35)
            Haptics.hurt()
            SoundEngine.shared.play(.hurt)
        } else {
            isRunning = false
            scrollSpeed = 0
            boat.capsize(in: effectsLayer)
            flashScreen(color: Palette.buoy, alpha: 0.5)
            Haptics.crash()
            SoundEngine.shared.play(.gameOver)
            state.endRun()
        }
    }

    private func evaluateNearMiss(for obstacle: ObstacleNode) {
        let boatRect = boat.collisionRect.offsetBy(dx: boat.position.x, dy: boat.position.y)
        let shapes = obstacle.sceneCollisionShapes()
        guard !shapes.isEmpty else { return }

        // Zıplanan engelde tepe ile tekne dibi arası, martıda tam tersi.
        let clearance: CGFloat
        if obstacle.mustDuckUnder {
            clearance = (shapes.map(\.bottomY).min() ?? 0) - boatRect.maxY
        } else {
            clearance = boatRect.minY - (shapes.map(\.topY).max() ?? 0)
        }

        guard clearance > 0, clearance < 26 else { return }
        bonusScore += 2
        Haptics.nearMiss()
        showSpark(at: CGPoint(x: boat.position.x, y: boatRect.minY))
    }

    // MARK: - Efektler

    private func showSpark(at point: CGPoint) {
        let ring = SKShapeNode(circleOfRadius: 14)
        ring.position = point
        ring.strokeColor = Palette.foam
        ring.lineWidth = 2
        ring.fillColor = .clear
        ring.zPosition = 45
        effectsLayer.addChild(ring)
        ring.run(.sequence([
            .group([.scale(to: 2.6, duration: 0.3), .fadeOut(withDuration: 0.3)]),
            .removeFromParent()
        ]))
    }

    private func burst(at point: CGPoint, color: UIColor) {
        let emitter = SKEmitterNode()
        emitter.particleTexture = TextureFactory.softCircle(diameter: 24, color: color)
        emitter.numParticlesToEmit = 40
        emitter.particleBirthRate = 1600
        emitter.particleLifetime = 0.6
        emitter.particleSize = CGSize(width: 14, height: 14)
        emitter.particleScaleSpeed = -0.8
        emitter.particleAlphaSpeed = -1.4
        emitter.particleColor = color
        emitter.particleColorBlendFactor = 1
        emitter.emissionAngleRange = .pi * 2
        emitter.particleSpeed = 220
        emitter.particleSpeedRange = 140
        emitter.position = point
        emitter.zPosition = 50
        effectsLayer.addChild(emitter)
        emitter.run(.sequence([.wait(forDuration: 1.2), .removeFromParent()]))
    }

    private func flashScreen(color: UIColor, alpha: CGFloat) {
        let flash = SKSpriteNode(color: color, size: size)
        flash.anchorPoint = .zero
        flash.alpha = alpha
        flash.zPosition = 100
        effectsLayer.addChild(flash)
        flash.run(.sequence([.fadeOut(withDuration: 0.35), .removeFromParent()]))
    }

    private func shakeWorld() {
        let amplitude: CGFloat = 12
        var steps: [SKAction] = []
        for index in 0..<7 {
            let decay = 1 - CGFloat(index) / 7
            steps.append(.move(to: CGPoint(x: .random(in: -amplitude...amplitude) * decay,
                                           y: .random(in: -amplitude...amplitude) * decay),
                               duration: 0.04))
        }
        steps.append(.move(to: .zero, duration: 0.06))
        worldLayer.run(.sequence(steps))
    }

    // MARK: - Girdi
    // Ekranın herhangi bir yerine dokun: zıplar. Basılı tutarsan daha yükseğe.

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHoldingJump = true
        jumpBufferTimer = Tuning.jumpBufferTime
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHoldingJump = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHoldingJump = false
    }
}
