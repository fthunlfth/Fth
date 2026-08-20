import UIKit

/// SpriteKit etiketleri font adıyla çalışıyor; arayüzdeki yuvarlak sistem
/// fontunun adını buradan alıyoruz ki sahne ile arayüz aynı tipografiyi kullansın.
enum Fonts {

    static func roundedName(size: CGFloat, weight: UIFont.Weight) -> String {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        guard let descriptor = base.fontDescriptor.withDesign(.rounded) else {
            return base.fontName
        }
        return UIFont(descriptor: descriptor, size: size).fontName
    }
}
