import SpriteKit

/// Oyunun tamamı: akıntı hızı, engel üretimi, çarpışma ve efektler.
/// Fizik motoru kullanmıyoruz — hareket ve çarpışma elle hesaplanıyor,
/// böylece Tuning'deki ayarlar birebir öngörülebilir sonuç veriyor.
final class GameScene: SKScene {

    weak var state: GameState?

    // MARK: - Katmanlar
    private let backgroundLayer = SKNode()
    private let worldLayer = SKNode()
    private let effectsLayer = SKNode()
    private let ocean = Ocean()

    // MARK: - Oyun nesneleri
    private var boat: BoatNode!
    private var obstacles: [ObstacleNode] = []
    private var starfishes: [StarfishNode] = []

    // MARK: - Durum
    private var isRunning = false
    private var lastUpdateTime: TimeInterval = 0
    private var elapsed: TimeInterval = 0
    private var scrollSpeed = Tuning.startScrollSpeed
    private var distance: CGFloat = 0
    private var bonusScore = 0
    private var timeUntilNextWave: TimeInterval = 0
    private var timeUntilNextWhirlpool: TimeInterval = 0
    /// Bir önceki geçilebilir koridorun merkezi — sıradakinin erişilebilir kalması için.
    private var lastCorridorCenter: CGFloat?

    // Kayık hareketi
    private var targetX: CGFloat = 0
    private var lastTouchX: CGFloat = 0
    private var boatVelocityX: CGFloat = 0
    /// Girdapta biriken dönme açısı.
    private var whirlSpin: CGFloat = 0

    private var boatY: CGFloat { Tuning.boatBottomInset }
    private var slotWidth: CGFloat { size.width / CGFloat(Tuning.slotCount) }

    // MARK: - Sahne kurulumu

    override func didMove(to view: SKView) {
        scaleMode = .resizeFill
        anchorPoint = .zero
        backgroundColor = Palette.seaTop

        backgroundLayer.zPosition = 0
        worldLayer.zPosition = 10
        effectsLayer.zPosition = 30
        addChild(backgroundLayer)
        addChild(worldLayer)
        addChild(effectsLayer)

        buildBackground()

        boat = BoatNode(width: Tuning.boatWidth, collisionRadius: Tuning.boatRadius)
        boat.zPosition = 20
        worldLayer.addChild(boat)
        boat.setWakeTarget(worldLayer)

        resetToIdle()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 0, backgroundLayer.parent != nil else { return }
        buildBackground()
    }

    private func buildBackground() {
        backgroundLayer.removeAllChildren()
        ocean.build(size: size)
        backgroundLayer.addChild(ocean)
    }

    // MARK: - Tur yönetimi

    /// Menüde beklerken: kayık ortada, deniz sakin.
    func resetToIdle() {
        isRunning = false
        elapsed = 0
        distance = 0
        bonusScore = 0
        scrollSpeed = Tuning.startScrollSpeed
        lastUpdateTime = 0
        whirlSpin = 0
        lastCorridorCenter = nil

        clearWorld()

        targetX = size.width / 2
        boatVelocityX = 0
        boat.reset(at: CGPoint(x: targetX, y: boatY))
        boat.setSpin(0)
        worldLayer.position = .zero
    }

    func startRun() {
        resetToIdle()
        timeUntilNextWave = 0.7
        timeUntilNextWhirlpool = Tuning.whirlpoolUnlockTime
        isRunning = true
        Haptics.prepare()
        state?.beginRun()
    }

    private func capsize() {
        guard isRunning else { return }
        isRunning = false

        boat.capsize(in: effectsLayer)
        Haptics.crash()
        flashScreen(color: Palette.buoy, alpha: 0.5)
        shakeWorld()

        state?.endRun()
    }

    private func clearWorld() {
        for obstacle in obstacles { obstacle.removeFromParent() }
        obstacles.removeAll()
        for starfish in starfishes { starfish.removeFromParent() }
        starfishes.removeAll()
    }

    // MARK: - Ana döngü

    override func update(_ currentTime: TimeInterval) {
        // İlk kare ve arka plandan dönüşlerde dev bir delta oluşmasın.
        let rawDelta = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        let deltaTime = min(max(rawDelta, 0), 1.0 / 30.0)

        ocean.update(deltaTime: deltaTime,
                     scrollSpeed: isRunning ? scrollSpeed : Tuning.startScrollSpeed * 0.35)

        guard isRunning else { return }

        elapsed += deltaTime
        scrollSpeed = min(Tuning.maxScrollSpeed,
                          Tuning.startScrollSpeed + Tuning.speedGainPerSecond * CGFloat(elapsed))

        updateObstacles(deltaTime: deltaTime)
        updateStarfishes(deltaTime: deltaTime)
        updateBoat(deltaTime: deltaTime)
        updateSpawning(deltaTime: deltaTime)
        updateScore(deltaTime: deltaTime)
        checkCollisions()
    }

    private func updateBoat(deltaTime: TimeInterval) {
        // Girdapların toplam çekimi hedefi kaydırır: dümen tutmak zorlaşır.
        var pull: CGFloat = 0
        var strongestInfluence: CGFloat = 0
        for case let whirlpool as WhirlpoolNode in obstacles {
            pull += whirlpool.horizontalPull(towards: boat.position)
            strongestInfluence = max(strongestInfluence, whirlpool.influence(at: boat.position))
        }
        targetX += pull * CGFloat(deltaTime)

        let minX = Tuning.sideMargin + boat.collisionRadius
        let maxX = size.width - Tuning.sideMargin - boat.collisionRadius
        targetX = min(max(targetX, minX), maxX)

        let previousX = boat.position.x
        // Kare hızından bağımsız yumuşatma.
        let t = 1 - exp(-Tuning.boatFollowSharpness * CGFloat(deltaTime))
        boat.position.x += (targetX - boat.position.x) * t
        boat.position.y = boatY

        boatVelocityX = deltaTime > 0 ? (boat.position.x - previousX) / CGFloat(deltaTime) : 0
        boat.applyBank(horizontalVelocity: boatVelocityX)

        // Girdaptan çıkınca dönme yavaşça sönsün.
        if strongestInfluence > 0 {
            whirlSpin += strongestInfluence * 7 * CGFloat(deltaTime)
        } else {
            whirlSpin *= exp(-4 * CGFloat(deltaTime))
        }
        boat.setSpin(whirlSpin)
    }

    private func updateObstacles(deltaTime: TimeInterval) {
        let step = scrollSpeed * CGFloat(deltaTime)
        var stillAlive: [ObstacleNode] = []

        for obstacle in obstacles {
            obstacle.position.y -= step
            obstacle.advance(deltaTime: deltaTime, sceneSize: size)

            // Engel kayığın hizasını geçtiği anda kıl payı kontrolü.
            if !obstacle.hasBeenPassed && obstacle.position.y < boatY {
                obstacle.hasBeenPassed = true
                evaluateNearMiss(for: obstacle)
            }

            if obstacle.position.y < -Tuning.whirlpoolPullRadius - 60 {
                obstacle.removeFromParent()
            } else {
                stillAlive.append(obstacle)
            }
        }
        obstacles = stillAlive
    }

    private func updateStarfishes(deltaTime: TimeInterval) {
        let step = scrollSpeed * CGFloat(deltaTime)
        var stillAlive: [StarfishNode] = []

        for starfish in starfishes {
            starfish.position.y -= step
            if starfish.position.y < -60 {
                starfish.removeFromParent()
            } else {
                stillAlive.append(starfish)
            }
        }
        starfishes = stillAlive
    }

    private func updateSpawning(deltaTime: TimeInterval) {
        timeUntilNextWave -= deltaTime
        if timeUntilNextWave <= 0 {
            spawnWave()
            timeUntilNextWave = max(Tuning.minSpawnInterval,
                                    Tuning.startSpawnInterval - Tuning.spawnIntervalDecayPerSecond * elapsed)
        }

        guard elapsed > Tuning.whirlpoolUnlockTime else { return }
        timeUntilNextWhirlpool -= deltaTime
        if timeUntilNextWhirlpool <= 0 {
            spawnWhirlpool()
            timeUntilNextWhirlpool = Tuning.whirlpoolInterval
        }
    }

    private func updateScore(deltaTime: TimeInterval) {
        distance += scrollSpeed * CGFloat(deltaTime)
        let total = Int(distance / Tuning.distancePerScorePoint) + bonusScore
        state?.setScore(total)
    }

    // MARK: - Engel üretimi

    private enum ObstacleKind {
        case rock, driftwood, jellyfish, shark, net

        /// Kaç sütun kaplıyor.
        var slotSpan: Int {
            switch self {
            case .driftwood, .net: return 2
            case .rock, .jellyfish, .shark: return 1
            }
        }
    }

    private func spawnWave() {
        let spawnY = size.height + 90
        let freeSlots = max(Int(Tuning.minFreeSlots),
                            Int(round(Tuning.startFreeSlots - Tuning.freeSlotsShrinkPerSecond * CGFloat(elapsed))))
        let freeCount = max(1, min(freeSlots, Tuning.slotCount - 1))
        let corridor = pickCorridor(freeCount: freeCount)

        var slot = 0
        var didSpawnAnything = false

        while slot < Tuning.slotCount {
            guard !corridor.contains(slot) else {
                slot += 1
                continue
            }
            // Her dolu sütun engel taşımak zorunda değil; deniz böyle daha doğal görünüyor.
            guard Double.random(in: 0...1) < Tuning.slotFillChance else {
                slot += 1
                continue
            }

            let canSpanTwo = slot + 1 < Tuning.slotCount && !corridor.contains(slot + 1)
            let kind = pickObstacleKind(canSpanTwo: canSpanTwo)
            let span = kind.slotSpan
            let centerX = (CGFloat(slot) + CGFloat(span) / 2) * slotWidth
            // Küçük dikey kaydırma, sıraların cetvelle çizilmiş gibi durmasını engelliyor.
            let y = spawnY + CGFloat.random(in: -12...12)

            spawnObstacle(kind: kind, centerX: centerX, y: y, span: span)
            didSpawnAnything = true
            slot += span
        }

        // Şansa hiç engel çıkmadıysa dalgayı boş geçmeyelim.
        if !didSpawnAnything {
            let fallbackSlot = (0..<Tuning.slotCount).first { !corridor.contains($0) } ?? 0
            spawnObstacle(kind: .rock,
                          centerX: (CGFloat(fallbackSlot) + 0.5) * slotWidth,
                          y: spawnY,
                          span: 1)
        }

        if Double.random(in: 0...1) < Tuning.starfishChance {
            let center = corridorCenterX(corridor)
            spawnStarfish(at: CGPoint(x: center, y: spawnY + 40))
        }
    }

    /// Boş koridoru seçer. Bir öncekine göre çok uzağa kaçmasına izin vermez,
    /// yoksa yüksek hızda geçmesi imkânsız hale gelir.
    private func pickCorridor(freeCount: Int) -> Range<Int> {
        let maxStart = Tuning.slotCount - freeCount
        var candidates = Array(0...maxStart)

        if let previous = lastCorridorCenter {
            let reach = size.width * Tuning.maxCorridorShiftRatio
            let reachable = candidates.filter { start in
                abs(corridorCenterX(start..<(start + freeCount)) - previous) <= reach
            }
            if !reachable.isEmpty { candidates = reachable }
        }

        let start = candidates.randomElement() ?? 0
        let corridor = start..<(start + freeCount)
        lastCorridorCenter = corridorCenterX(corridor)
        return corridor
    }

    private func corridorCenterX(_ corridor: Range<Int>) -> CGFloat {
        (CGFloat(corridor.lowerBound) + CGFloat(corridor.count) / 2) * slotWidth
    }

    /// Engel çeşitleri oyun ilerledikçe havuza giriyor: ilk saniyeler sadece kaya,
    /// sonra kütük, denizanası, köpek balığı ve en son ağ.
    private func pickObstacleKind(canSpanTwo: Bool) -> ObstacleKind {
        var pool: [ObstacleKind] = [.rock, .rock, .rock]
        if elapsed > Tuning.logUnlockTime { pool += [.driftwood, .driftwood] }
        if elapsed > Tuning.jellyfishUnlockTime { pool += [.jellyfish, .jellyfish] }
        if elapsed > Tuning.sharkUnlockTime { pool += [.shark, .shark, .shark] }
        if elapsed > Tuning.netUnlockTime { pool += [.net, .net] }

        if !canSpanTwo {
            pool = pool.filter { $0.slotSpan == 1 }
        }
        return pool.randomElement() ?? .rock
    }

    private func spawnObstacle(kind: ObstacleKind, centerX: CGFloat, y: CGFloat, span: Int) {
        let node: ObstacleNode

        switch kind {
        case .rock:
            let rock = RockNode()
            rock.build(radius: .random(in: Tuning.rockRadiusRange))
            node = rock

        case .driftwood:
            let log = DriftwoodNode()
            log.build(length: min(Tuning.logLength, slotWidth * CGFloat(span) * 0.88))
            node = log

        case .jellyfish:
            let jellyfish = JellyfishNode()
            jellyfish.build(originX: centerX)
            node = jellyfish

        case .shark:
            let shark = SharkNode()
            shark.build(originX: centerX, direction: Bool.random() ? 1 : -1)
            node = shark

        case .net:
            let net = FishingNetNode()
            net.build(span: slotWidth * CGFloat(span) * 0.9)
            node = net
        }

        node.position = CGPoint(x: centerX, y: y)
        node.zPosition = 12
        worldLayer.addChild(node)
        obstacles.append(node)
    }

    private func spawnWhirlpool() {
        let inset = Tuning.whirlpoolPullRadius * 0.45
        let whirlpool = WhirlpoolNode()
        whirlpool.build()
        whirlpool.position = CGPoint(x: .random(in: inset...(size.width - inset)),
                                     y: size.height + Tuning.whirlpoolPullRadius)
        // Girdap suyun bir parçası; engellerin altında çizilsin.
        whirlpool.zPosition = 11
        worldLayer.addChild(whirlpool)
        obstacles.append(whirlpool)
    }

    private func spawnStarfish(at point: CGPoint) {
        let starfish = StarfishNode(radius: Tuning.starfishRadius)
        starfish.position = point
        starfish.zPosition = 15
        worldLayer.addChild(starfish)
        starfishes.append(starfish)
    }

    // MARK: - Çarpışma

    private func checkCollisions() {
        let center = boat.position
        let radius = boat.collisionRadius

        for obstacle in obstacles {
            // Uzaktaki engelleri hızlıca ele.
            guard abs(obstacle.position.y - center.y) < 200 else { continue }

            if let core = obstacle.lethalCore,
               core.offset(by: obstacle.position).intersects(circleAt: center, radius: radius) {
                capsize()
                return
            }

            for shape in obstacle.sceneCollisionShapes()
            where shape.intersects(circleAt: center, radius: radius) {
                capsize()
                return
            }
        }

        for starfish in starfishes {
            let combined = starfish.radius + radius
            let dx = starfish.position.x - center.x
            let dy = starfish.position.y - center.y
            guard dx * dx + dy * dy <= combined * combined else { continue }

            starfish.collect()
            starfishes.removeAll { $0 === starfish }
            bonusScore += Tuning.starfishScore
            state?.collectStarfish()
            Haptics.pickup()
        }
    }

    private func evaluateNearMiss(for obstacle: ObstacleNode) {
        let shapes = obstacle.sceneCollisionShapes()
        guard !shapes.isEmpty else { return }

        let closest = shapes.map { $0.distance(toCircleAt: boat.position, radius: boat.collisionRadius) }.min()
        guard let closest, closest > 0, closest < Tuning.nearMissDistance else { return }

        bonusScore += Tuning.nearMissScore
        state?.registerNearMiss()
        Haptics.nearMiss()
        showNearMissSpark()
    }

    // MARK: - Efektler

    private func showNearMissSpark() {
        let ring = SKShapeNode(circleOfRadius: boat.collisionRadius * 1.5)
        ring.position = boat.position
        ring.strokeColor = Palette.foam
        ring.lineWidth = 2
        ring.fillColor = .clear
        ring.zPosition = 25
        worldLayer.addChild(ring)
        ring.run(.sequence([
            .group([.scale(to: 2.4, duration: 0.3), .fadeOut(withDuration: 0.3)]),
            .removeFromParent()
        ]))
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
        let amplitude: CGFloat = 15
        var steps: [SKAction] = []
        for index in 0..<8 {
            let decay = 1 - CGFloat(index) / 8
            steps.append(.move(to: CGPoint(x: .random(in: -amplitude...amplitude) * decay,
                                           y: .random(in: -amplitude...amplitude) * decay),
                               duration: 0.04))
        }
        steps.append(.move(to: .zero, duration: 0.06))
        worldLayer.run(.sequence(steps))
    }

    // MARK: - Girdi
    // Parmağın mutlak yerini değil, hareketini kullanıyoruz:
    // ekranın istediğin yerinden sürükleyebilirsin, kayık parmağa zıplamaz.

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        lastTouchX = touch.location(in: self).x
        targetX = boat.position.x
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let x = touch.location(in: self).x
        targetX += (x - lastTouchX) * Tuning.dragSensitivity
        lastTouchX = x
    }
}
