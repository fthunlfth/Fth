import SpriteKit

/// Çarpışma testinde kullanılan basit geometriler. Düğüm-yerel koordinatta tutulur,
/// sahneye çevirirken sadece düğümün konumu eklenir — bu yüzden engellerin
/// görsel kısmı serbestçe dönebilir, çarpışma alanı bozulmaz.
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

    /// Verilen daire bu şeklin içine giriyor mu.
    func intersects(circleAt point: CGPoint, radius: CGFloat) -> Bool {
        switch self {
        case let .circle(center, ownRadius):
            let dx = point.x - center.x
            let dy = point.y - center.y
            let sum = ownRadius + radius
            return dx * dx + dy * dy <= sum * sum
        case let .rect(rect):
            let closestX = min(max(point.x, rect.minX), rect.maxX)
            let closestY = min(max(point.y, rect.minY), rect.maxY)
            let dx = point.x - closestX
            let dy = point.y - closestY
            return dx * dx + dy * dy <= radius * radius
        }
    }

    /// Daire ile bu şekil arasındaki en kısa mesafe. Kıl payı ölçmek için.
    func distance(toCircleAt point: CGPoint, radius: CGFloat) -> CGFloat {
        switch self {
        case let .circle(center, ownRadius):
            let dx = point.x - center.x
            let dy = point.y - center.y
            return max(0, sqrt(dx * dx + dy * dy) - ownRadius - radius)
        case let .rect(rect):
            let closestX = min(max(point.x, rect.minX), rect.maxX)
            let closestY = min(max(point.y, rect.minY), rect.maxY)
            let dx = point.x - closestX
            let dy = point.y - closestY
            return max(0, sqrt(dx * dx + dy * dy) - radius)
        }
    }
}

/// Bütün deniz engellerinin ortak atası.
/// Alt sınıflar `localCollisionShapes` ve isterlerse `advance` / `pull` yazar.
class ObstacleNode: SKNode {

    /// Oyuncu bu engelin hizasını geçti mi — kıl payı bir kez sayılsın diye.
    var hasBeenPassed = false

    /// Görsel kısım burada durur; döndürmek çarpışma alanını etkilemez.
    let visual = SKNode()

    override init() {
        super.init()
        addChild(visual)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) kullanılmıyor") }

    /// Düğüm-yerel çarpışma geometrisi. Alt sınıflar doldurur.
    var localCollisionShapes: [CollisionShape] { [] }

    /// Sahne koordinatına taşınmış çarpışma geometrisi.
    final func sceneCollisionShapes() -> [CollisionShape] {
        localCollisionShapes.map { $0.offset(by: position) }
    }

    /// Engelin kendi hareketi: yüzmek, salınmak, dönmek.
    /// Akıntıyla aşağı kayma sahne tarafından yapılıyor, burada sadece ek hareket var.
    func advance(deltaTime: TimeInterval, sceneSize: CGSize) {}

    /// Kayığa uygulanacak yatay çekim (nokta/saniye). Sağa çekiyorsa pozitif.
    func horizontalPull(towards point: CGPoint) -> CGFloat { 0 }

    /// Kayığın anında battığı ölümcül çekirdek (girdabın gözü gibi). Yoksa nil.
    var lethalCore: CollisionShape? { nil }
}
