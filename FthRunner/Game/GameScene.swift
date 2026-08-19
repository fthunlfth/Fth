import SpriteKit

/// Oyunun tamamı: hız rampası, duvar üretimi, çarpışma ve efektler.
/// Fizik motoru kullanmıyoruz — hareket ve çarpışma elle hesaplanıyor,
/// böylece ayarlar birebir öngörülebilir kalıyor.
final class GameScene: SKScene {

    weak var state: GameState?

    // MARK: - Katmanlar
    private let backgroundLayer = SKNode()
    private let worldLayer = SKNode()
    private let effectsLayer = SKNode()
    private let starfield = Starfield()

    // MARK: - Oyun nesneleri
    private var player: PlayerNode!
    private var rows: [WallRow] = []
    private var rowPool: [WallRow] = []

    // MARK: - Durum
    private var isRunning = false
    private var lastUpdateTime: TimeInterval = 0
    private var elapsed: TimeInterval = 0
    private var scrollSpeed = Tuning.startScrollSpeed
    private var distance: CGFloat = 0
    private var bonusScore = 0
    private var timeUntilNextRow: TimeInterval = 0
    /// Bir önceki tek geçidin merkezi — sıradaki geçidin erişilebilir kalması için.
    private var lastGapCenter: CGFloat?

    // Oyuncu hareketi
    private var targetX: CGFloat = 0
    private var lastTouchX: CGFloat = 0
    private var playerVelocityX: CGFloat = 0

    private var playerY: CGFloat { Tuning.playerBottomInset }

    // MARK: - Sahne kurulumu

    override func didMove(to view: SKView) {
        scaleMode = .resizeFill
        anchorPoint = .zero
        backgroundColor = Palette.skyTop

        backgroundLayer.zPosition = 0
        worldLayer.zPosition = 10
        effectsLayer.zPosition = 30
        addChild(backgroundLayer)
        addChild(worldLayer)
        addChild(effectsLayer)

        buildBackground()

        player = PlayerNode(radius: Tuning.playerRadius)
        player.zPosition = 20
        worldLayer.addChild(player)
        player.setTrailTarget(worldLayer)

        resetToIdle()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 0, backgroundLayer.parent != nil else { return }
        buildBackground()
    }

    private func buildBackground() {
        backgroundLayer.removeAllChildren()

        let gradient = SKSpriteNode(texture: TextureFactory.verticalGradient(
            size: CGSize(width: 4, height: size.height),
            top: Palette.skyTop,
            bottom: Palette.skyBottom))
        gradient.anchorPoint = .zero
        gradient.size = size
        backgroundLayer.addChild(gradient)

        starfield.build(size: size, count: Tuning.starCount)
        backgroundLayer.addChild(starfield)
    }

    // MARK: - Tur yönetimi

    /// Menüde beklerken: gemi ortada, duvar yok.
    func resetToIdle() {
        isRunning = false
        elapsed = 0
        distance = 0
        bonusScore = 0
        scrollSpeed = Tuning.startScrollSpeed
        lastUpdateTime = 0

        recycleAllRows()
        lastGapCenter = nil

        targetX = size.width / 2
        playerVelocityX = 0
        player.reset(at: CGPoint(x: targetX, y: playerY))
        worldLayer.position = .zero
    }

    func startRun() {
        resetToIdle()
        timeUntilNextRow = 0.6
        isRunning = true
        Haptics.prepare()
        state?.beginRun()
    }

    private func crash() {
        guard isRunning else { return }
        isRunning = false

        player.explode(in: effectsLayer)
        Haptics.crash()
        flashScreen(color: Palette.wallFill, alpha: 0.55)
        shakeWorld()

        state?.endRun()
    }

    // MARK: - Ana döngü

    override func update(_ currentTime: TimeInterval) {
        // İlk kare ve arka plandan dönüşlerde dev bir delta oluşmasın.
        let rawDelta = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        let deltaTime = min(max(rawDelta, 0), 1.0 / 30.0)

        starfield.update(deltaTime: deltaTime, scrollSpeed: isRunning ? scrollSpeed : Tuning.startScrollSpeed * 0.35)

        guard isRunning else { return }

        elapsed += deltaTime
        scrollSpeed = min(Tuning.maxScrollSpeed,
                          Tuning.startScrollSpeed + Tuning.speedGainPerSecond * CGFloat(elapsed))

        updatePlayer(deltaTime: deltaTime)
        updateRows(deltaTime: deltaTime)
        updateSpawning(deltaTime: deltaTime)
        updateScore(deltaTime: deltaTime)
        checkCollisions()
    }

    private func updatePlayer(deltaTime: TimeInterval) {
        let minX = Tuning.sideMargin + player.radius
        let maxX = size.width - Tuning.sideMargin - player.radius
        targetX = min(max(targetX, minX), maxX)

        let previousX = player.position.x
        // Kare hızından bağımsız yumuşatma.
        let t = 1 - exp(-Tuning.playerFollowSharpness * CGFloat(deltaTime))
        player.position.x += (targetX - player.position.x) * t
        player.position.y = playerY

        playerVelocityX = deltaTime > 0 ? (player.position.x - previousX) / CGFloat(deltaTime) : 0
        player.applyBank(horizontalVelocity: playerVelocityX)
    }

    private func updateRows(deltaTime: TimeInterval) {
        let step = scrollSpeed * CGFloat(deltaTime)
        var stillAlive: [WallRow] = []

        for row in rows {
            row.position.y -= step

            // Sıra oyuncunun hizasını geçtiği anda kıl payı kontrolü.
            if !row.hasBeenPassed && row.position.y < playerY {
                row.hasBeenPassed = true
                evaluateNearMiss(for: row)
            }

            if row.position.y < -Tuning.wallHeight * 2 {
                recycle(row)
            } else {
                stillAlive.append(row)
            }
        }
        rows = stillAlive
    }

    private func updateSpawning(deltaTime: TimeInterval) {
        timeUntilNextRow -= deltaTime
        guard timeUntilNextRow <= 0 else { return }

        spawnRow()

        let interval = max(Tuning.minSpawnInterval,
                           Tuning.startSpawnInterval - Tuning.spawnIntervalDecayPerSecond * elapsed)
        timeUntilNextRow = interval
    }

    private func updateScore(deltaTime: TimeInterval) {
        distance += scrollSpeed * CGFloat(deltaTime)
        let total = Int(distance / Tuning.distancePerScorePoint) + bonusScore
        state?.setScore(total)
    }

    // MARK: - Duvar üretimi

    private func spawnRow() {
        let width = size.width
        let gapRatio = max(Tuning.minGapRatio,
                           Tuning.startGapRatio - Tuning.gapShrinkPerSecond * CGFloat(elapsed))
        let gapWidth = width * gapRatio

        var gaps: [ClosedRange<CGFloat>] = []
        let wantsDoubleGap = elapsed > Tuning.doubleGapAfterSeconds
            && Double.random(in: 0...1) < Tuning.doubleGapChance

        // İki dar geçit: biri solda, biri sağda, aralarında mutlaka duvar kalacak şekilde.
        if wantsDoubleGap,
           let pair = doubleGapRanges(width: width, gapWidth: gapWidth) {
            gaps = pair
        } else {
            // Tek geçit. Bir öncekine göre çok uzağa kaçmasın ki geçmesi mümkün olsun.
            let halfGap = gapWidth / 2
            var lowerBoundX = halfGap
            var upperBoundX = width - halfGap
            if let previous = lastGapCenter {
                let reach = width * Tuning.maxGapShiftRatio
                lowerBoundX = max(lowerBoundX, previous - reach)
                upperBoundX = min(upperBoundX, previous + reach)
            }
            let center = CGFloat.random(in: lowerBoundX...max(lowerBoundX, upperBoundX))
            lastGapCenter = center
            gaps = [(center - halfGap)...(center + halfGap)]
        }

        let row = dequeueRow()
        row.build(width: width, gaps: gaps, height: Tuning.wallHeight)
        row.position = CGPoint(x: 0, y: size.height + Tuning.wallHeight)

        if Double.random(in: 0...1) < Tuning.coinChance, let gap = gaps.randomElement() {
            let center = (gap.lowerBound + gap.upperBound) / 2
            row.attachCoin(at: center)
        }

        worldLayer.addChild(row)
        rows.append(row)
    }

    /// Ekranı ikiye bölen iki dar geçit üretir. Sığmıyorsa nil döner
    /// ve çağıran tek geçide düşer.
    private func doubleGapRanges(width: CGFloat, gapWidth: CGFloat) -> [ClosedRange<CGFloat>]? {
        let narrow = max(Tuning.minDoubleGapWidth, min(gapWidth * 0.62, width * 0.22))
        let half = narrow / 2
        let leftLower = half
        let leftUpper = width / 2 - Tuning.minWallBetweenGaps / 2 - half
        let rightLower = width / 2 + Tuning.minWallBetweenGaps / 2 + half
        let rightUpper = width - half
        guard leftLower <= leftUpper, rightLower <= rightUpper else { return nil }

        let leftCenter = CGFloat.random(in: leftLower...leftUpper)
        let rightCenter = CGFloat.random(in: rightLower...rightUpper)
        lastGapCenter = Bool.random() ? leftCenter : rightCenter
        return [
            (leftCenter - half)...(leftCenter + half),
            (rightCenter - half)...(rightCenter + half)
        ]
    }

    // Sıralar sürekli doğup ölüyor; havuzda tutup yeniden kullanıyoruz.
    private func dequeueRow() -> WallRow {
        if let row = rowPool.popLast() { return row }
        return WallRow()
    }

    private func recycle(_ row: WallRow) {
        row.removeFromParent()
        row.removeAllChildren()
        rowPool.append(row)
    }

    private func recycleAllRows() {
        for row in rows { recycle(row) }
        rows.removeAll()
    }

    // MARK: - Çarpışma

    private func checkCollisions() {
        let center = player.position
        let radius = player.radius

        for row in rows {
            // Uzaktaki sıraları hızlıca ele.
            guard abs(row.position.y - center.y) < Tuning.wallHeight + radius + 4 else {
                continue
            }

            for rect in row.sceneSegments() where circleIntersects(rect: rect, center: center, radius: radius) {
                crash()
                return
            }
        }

        // Altınlar duvarlarla aynı sırada taşınıyor.
        for row in rows {
            guard let coin = row.coin else { continue }
            let coinCenter = CGPoint(x: coin.position.x + row.position.x,
                                     y: coin.position.y + row.position.y)
            let combined = coin.radius + radius
            if distanceSquared(coinCenter, center) <= combined * combined {
                row.removeCoin()
                bonusScore += Tuning.coinScore
                state?.collectCoin()
                Haptics.coin()
            }
        }
    }

    private func evaluateNearMiss(for row: WallRow) {
        let clearance = row.horizontalClearance(at: player.position.x)
        guard clearance < Tuning.nearMissDistance else { return }
        bonusScore += Tuning.nearMissScore
        state?.registerNearMiss()
        Haptics.nearMiss()
        showNearMissSpark()
    }

    private func circleIntersects(rect: CGRect, center: CGPoint, radius: CGFloat) -> Bool {
        let closestX = min(max(center.x, rect.minX), rect.maxX)
        let closestY = min(max(center.y, rect.minY), rect.maxY)
        let dx = center.x - closestX
        let dy = center.y - closestY
        return dx * dx + dy * dy <= radius * radius
    }

    private func distanceSquared(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return dx * dx + dy * dy
    }

    // MARK: - Efektler

    private func showNearMissSpark() {
        let ring = SKShapeNode(circleOfRadius: player.radius * 1.6)
        ring.position = player.position
        ring.strokeColor = .white
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
        flash.blendMode = .add
        effectsLayer.addChild(flash)
        flash.run(.sequence([.fadeOut(withDuration: 0.35), .removeFromParent()]))
    }

    private func shakeWorld() {
        let amplitude: CGFloat = 16
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
    // ekranın istediğin yerinden sürükleyebilirsin, gemi parmağa zıplamaz.

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        lastTouchX = touch.location(in: self).x
        targetX = player.position.x
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let x = touch.location(in: self).x
        targetX += (x - lastTouchX) * Tuning.dragSensitivity
        lastTouchX = x
    }
}
