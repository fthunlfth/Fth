import SpriteKit

/// Açılış ekranındaki tablo: küçük bir kumsalın üstünde Hira, elinde ayıcığı,
/// yanında mavi gözlü beyaz kedisi.
final class TitleSceneNode: SKNode {

    private var hira: HiraNode?
    private var cat: AnimalNode?

    func build(characterHeight: CGFloat) {
        removeAllChildren()

        let h = characterHeight

        // Üstünde durdukları kum tepeciği.
        let mound = CGMutablePath()
        let moundWidth = h * 1.30
        mound.move(to: CGPoint(x: -moundWidth / 2, y: 0))
        mound.addQuadCurve(to: CGPoint(x: moundWidth / 2, y: 0),
                           control: CGPoint(x: 0, y: h * 0.24))
        mound.closeSubpath()
        let moundNode = SKShapeNode(path: mound)
        moundNode.fillColor = Palette.sand
        moundNode.strokeColor = Palette.islandShade
        moundNode.lineWidth = 2
        moundNode.position = CGPoint(x: 0, y: -h * 0.045)
        moundNode.zPosition = -1
        addChild(moundNode)

        // Kıyıya vuran köpük.
        let shore = SKShapeNode(ellipseOf: CGSize(width: moundWidth * 1.12, height: h * 0.055))
        shore.fillColor = .clear
        shore.strokeColor = Palette.foam
        shore.lineWidth = 2.5
        shore.alpha = 0.6
        shore.position = CGPoint(x: 0, y: -h * 0.045)
        shore.zPosition = 0
        addChild(shore)

        // Ayaklarının altındaki yumuşak gölge.
        let shadow = SKShapeNode(ellipseOf: CGSize(width: h * 0.34, height: h * 0.05))
        shadow.fillColor = Palette.islandShade
        shadow.strokeColor = .clear
        shadow.alpha = 0.35
        shadow.position = CGPoint(x: h * 0.10, y: h * 0.012)
        shadow.zPosition = 1
        addChild(shadow)

        let character = HiraNode(height: h)
        character.position = CGPoint(x: h * 0.10, y: 0)
        character.zPosition = 3
        addChild(character)
        hira = character

        // Mavi gözlü beyaz kedi — Hira'ya dönük dursun diye aynalanıyor.
        let catHeight = h * 0.34
        let kitty = AnimalNode(kind: .cat, height: catHeight)
        kitty.xScale = -1
        kitty.position = CGPoint(x: -h * 0.30, y: h * 0.005)
        kitty.zPosition = 4
        addChild(kitty)
        cat = kitty

        let catShadow = SKShapeNode(ellipseOf: CGSize(width: catHeight * 0.85, height: catHeight * 0.16))
        catShadow.fillColor = Palette.islandShade
        catShadow.strokeColor = .clear
        catShadow.alpha = 0.3
        catShadow.position = CGPoint(x: -h * 0.30, y: h * 0.012)
        catShadow.zPosition = 2
        addChild(catShadow)
    }
}
