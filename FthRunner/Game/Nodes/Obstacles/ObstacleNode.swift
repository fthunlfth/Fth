import SpriteKit

/// Çarpışma testinde kullanılan basit geometriler. Düğüm-yerel koordinatta
/// tutulur; sahneye çevirirken sadece düğümün konumu eklenir. Bu yüzden
/// engelin görseli serbestçe dönebilir, çarpışma alanı bozulmaz.
enum CollisionShape {
    case circle(center: CGPoint, radius: CGFloat)
    case rect(CGRect)

    func offset(by delta: CGPoint) -> CollisionShape {
        switch self {
        case let .circle(center, radius):
            return .circle(center: CGPoint(x: center.x + delta.x, y: center.y + delta.y), radius: radius)
        case let .rect(rect):
            return .rect(rect.offsetBy(dx: delta.x, dy: delta.y))
        }
    }

    /// Kayığın çarpışma kutusuyla kesişiyor mu.
    func intersects(rect other: CGRect) -> Bool {
        switch self {
        case let .circle(center, radius):
            let closestX = min(max(center.x, other.minX), other.maxX)
            let closestY = min(max(center.y, other.minY), other.maxY)
            let dx = center.x - closestX
            let dy = center.y - closestY
            return dx * dx + dy * dy <= radius * radius
        case let .rect(rect):
            return rect.intersects(other)
        }
    }

    /// Şeklin en üst noktası — kıl payı zıplamayı ölçmek için.
    var topY: CGFloat {
        switch self {
        case let .circle(center, radius): return center.y + radius
        case let .rect(rect): return rect.maxY
        }
    }

    /// Şeklin en alt noktası — martının altından geçişi ölçmek için.
    var bottomY: CGFloat {
        switch self {
        case let .circle(center, radius): return center.y - radius
        case let .rect(rect): return rect.minY
        }
    }
}

/// Bütün engellerin ortak atası. Alt sınıflar `localCollisionShapes` yazar,
/// isterlerse `advance` ile kendi hareketini ekler.
class ObstacleNode: SKNode {

    /// Dünya koordinatındaki yeri. Ekran konumu her karede kameradan hesaplanıyor.
    var worldX: CGFloat = 0

    /// Kayık bu engelin hizasını geçti mi — kıl payı bir kez sayılsın diye.
    var hasBeenPassed = false

    /// Görsel kısım burada durur; döndürmek çarpışma alanını etkilemez.
    let visual = SKNode()

    override init() {
        super.init()
        addChild(visual)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) kullanılmıyor") }

    /// Su yüzeyine oturuyor mu. Martı gibi uçanlar için `false`.
    var ridesWave: Bool { true }

    /// Oturduğu hattan dikey kayma (martı gökyüzünde, kaya su hattında).
    var verticalOffset: CGFloat { 0 }

    /// Zıplayarak değil, altından geçilerek aşılan engel mi.
    var mustDuckUnder: Bool { false }

    /// Düğüm-yerel çarpışma geometrisi. Alt sınıflar doldurur.
    var localCollisionShapes: [CollisionShape] { [] }

    /// Sahne koordinatına taşınmış çarpışma geometrisi.
    final func sceneCollisionShapes() -> [CollisionShape] {
        localCollisionShapes.map { $0.offset(by: position) }
    }

    /// Engelin kendi hareketi. Kaydırma sahne tarafından yapılıyor;
    /// burada sadece ek hareket var (köpek balığının yaklaşması gibi).
    func advance(deltaTime: TimeInterval) {}
}
