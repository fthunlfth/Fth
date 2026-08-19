import SpriteKit

/// Ekranı boydan boya kesen, içinde bir veya iki geçit olan duvar sırası.
/// Çarpışma testi için parçaların dikdörtgenlerini kendi içinde tutar.
final class WallRow: SKNode {

    /// Sıra-yerel koordinatlarda duvar parçaları (y ekseni sıfırda ortalı).
    private(set) var segments: [CGRect] = []
    /// Geçitlerin yatay aralıkları — altın yerleştirmek ve kıl payı ölçmek için.
    private(set) var gaps: [ClosedRange<CGFloat>] = []

    /// Oyuncu bu sırayı geçtiğinde bir kez işaretlenir.
    var hasBeenPassed = false

    private(set) var coin: CoinNode?

    /// - Parameters:
    ///   - width: Ekran genişliği.
    ///   - gaps: Geçitlerin `0...width` aralığındaki yatay yerleri.
    ///   - height: Duvar kalınlığı.
    func build(width: CGFloat, gaps: [ClosedRange<CGFloat>], height: CGFloat) {
        removeAllChildren()
        segments.removeAll()
        coin = nil
        hasBeenPassed = false
        self.gaps = gaps.sorted { $0.lowerBound < $1.lowerBound }

        // Geçitlerin tümleyeni = dolu duvar parçaları.
        var cursor: CGFloat = 0
        for gap in self.gaps {
            if gap.lowerBound > cursor {
                addSegment(from: cursor, to: gap.lowerBound, height: height)
            }
            cursor = max(cursor, gap.upperBound)
        }
        if cursor < width {
            addSegment(from: cursor, to: width, height: height)
        }
    }

    private func addSegment(from minX: CGFloat, to maxX: CGFloat, height: CGFloat) {
        let rect = CGRect(x: minX, y: -height / 2, width: maxX - minX, height: height)
        segments.append(rect)

        let shape = SKShapeNode(rect: rect, cornerRadius: min(Tuning.wallCornerRadius, height / 2))
        shape.fillColor = Palette.wallFill
        shape.strokeColor = Palette.wallStroke
        shape.lineWidth = 1.5
        shape.glowWidth = 2
        addChild(shape)
    }

    func attachCoin(at x: CGFloat) {
        let node = CoinNode(radius: Tuning.coinRadius)
        node.position = CGPoint(x: x, y: 0)
        addChild(node)
        coin = node
    }

    func removeCoin() {
        coin?.collect()
        coin = nil
    }

    /// Duvar parçalarının sahne koordinatındaki dikdörtgenleri.
    func sceneSegments() -> [CGRect] {
        segments.map { $0.offsetBy(dx: position.x, dy: position.y) }
    }

    /// Verilen x'in en yakın duvar kenarına yatay uzaklığı.
    /// Geçidin ortasındaysan büyük, kenarını sıyırıyorsan küçük çıkar.
    func horizontalClearance(at x: CGFloat) -> CGFloat {
        guard let gap = gaps.first(where: { $0.contains(x - position.x) }) else { return .greatestFiniteMagnitude }
        let local = x - position.x
        return min(local - gap.lowerBound, gap.upperBound - local)
    }
}
