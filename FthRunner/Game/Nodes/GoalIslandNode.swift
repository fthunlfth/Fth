import SpriteKit

/// Bölümün sonundaki küçük ada. Üstünde o bölümün hayvanı bekliyor;
/// kayık yanaşınca hayvan atlayıp mürettebata katılıyor.
class GoalIslandNode: SKNode {

    /// Adanın üstünde bekleyen hayvan. Alt sınıflar da yerleştirebilsin diye açık.
    var animal: AnimalNode?
    /// Dünya koordinatındaki yeri; ekran konumu kameradan hesaplanıyor.
    var worldX: CGFloat = 0
    private let width: CGFloat = 150

    /// Kayık, hedefin bu kadar solunda durur. Geniş kıyılar için artırılıyor.
    var stopOffset: CGFloat { 130 }

    func build(reward: AnimalKind) {
        removeAllChildren()

        // Kum.
        let sand = CGMutablePath()
        sand.move(to: CGPoint(x: -width / 2, y: 0))
        sand.addQuadCurve(to: CGPoint(x: width / 2, y: 0),
                          control: CGPoint(x: 0, y: 76))
        sand.closeSubpath()
        let sandNode = SKShapeNode(path: sand)
        sandNode.fillColor = Palette.island
        sandNode.strokeColor = Palette.islandShade
        sandNode.lineWidth = 2
        addChild(sandNode)

        // Kıyıdaki köpük.
        let shore = SKShapeNode(ellipseOf: CGSize(width: width * 1.15, height: 16))
        shore.fillColor = .clear
        shore.strokeColor = Palette.foam
        shore.lineWidth = 2.5
        shore.alpha = 0.6
        addChild(shore)

        buildPalm(at: CGPoint(x: -width * 0.26, y: 22))

        // Hayvan adanın tepesinde bekliyor.
        let node = AnimalNode(kind: reward, height: 46)
        node.position = CGPoint(x: width * 0.12, y: 30)
        node.zPosition = 2
        addChild(node)
        animal = node
    }

    private func buildPalm(at base: CGPoint) {
        let trunk = CGMutablePath()
        trunk.move(to: base)
        trunk.addQuadCurve(to: CGPoint(x: base.x - 16, y: base.y + 78),
                           control: CGPoint(x: base.x - 2, y: base.y + 42))
        let trunkNode = SKShapeNode(path: trunk)
        trunkNode.strokeColor = Palette.driftwood
        trunkNode.lineWidth = 8
        trunkNode.lineCap = .round
        addChild(trunkNode)

        let top = CGPoint(x: base.x - 16, y: base.y + 78)
        for angle in stride(from: CGFloat.pi * 0.1, through: .pi * 0.9, by: .pi * 0.2) {
            let leaf = CGMutablePath()
            leaf.move(to: top)
            let tip = CGPoint(x: top.x + cos(angle) * 40, y: top.y + sin(angle) * 26)
            leaf.addQuadCurve(to: tip, control: CGPoint(x: top.x + cos(angle) * 20,
                                                        y: top.y + sin(angle) * 34))
            let leafNode = SKShapeNode(path: leaf)
            leafNode.strokeColor = Palette.palm
            leafNode.lineWidth = 7
            leafNode.lineCap = .round
            addChild(leafNode)
        }

        let coconut = SKShapeNode(circleOfRadius: 5)
        coconut.fillColor = Palette.driftwood
        coconut.strokeColor = .clear
        coconut.position = CGPoint(x: top.x + 5, y: top.y - 7)
        addChild(coconut)
    }

    /// Hayvan kayığa doğru zıplar; tamamlanınca kapanış çağrılır.
    func launchAnimal(to point: CGPoint, completion: @escaping () -> Void) {
        guard let animal else { completion(); return }
        let path = CGMutablePath()
        let start = animal.position
        path.move(to: start)
        path.addQuadCurve(to: point, control: CGPoint(x: (start.x + point.x) / 2,
                                                      y: max(start.y, point.y) + 90))
        animal.run(.sequence([
            .group([.follow(path, asOffset: false, orientToPath: false, duration: 0.55),
                    .scale(to: 0.7, duration: 0.55)]),
            .fadeOut(withDuration: 0.05),
            .run(completion)
        ]))
    }
}
