import SpriteKit
import UIKit

/// Görsel dosyaya ihtiyaç duymadan, kod ile doku üretir.
/// Böylece proje tek başına çalışır; asset eklemek zorunda değiliz.
enum TextureFactory {

    /// Merkezden dışa doğru saydamlaşan yumuşak daire. Parlama ve parçacıklar için.
    static func softCircle(diameter: CGFloat, color: UIColor) -> SKTexture {
        let size = CGSize(width: diameter, height: diameter)
        let image = UIGraphicsImageRenderer(size: size).image { ctx in
            let cg = ctx.cgContext
            let colors = [color.withAlphaComponent(1).cgColor,
                          color.withAlphaComponent(0).cgColor] as CFArray
            guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                            colors: colors,
                                            locations: [0, 1]) else { return }
            let center = CGPoint(x: diameter / 2, y: diameter / 2)
            cg.drawRadialGradient(gradient,
                                  startCenter: center, startRadius: 0,
                                  endCenter: center, endRadius: diameter / 2,
                                  options: [])
        }
        return SKTexture(image: image)
    }

    /// Dikey degrade. Arka plan için.
    static func verticalGradient(size: CGSize, top: UIColor, bottom: UIColor) -> SKTexture {
        let image = UIGraphicsImageRenderer(size: size).image { ctx in
            let cg = ctx.cgContext
            let colors = [top.cgColor, bottom.cgColor] as CFArray
            guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                            colors: colors,
                                            locations: [0, 1]) else { return }
            cg.drawLinearGradient(gradient,
                                  start: CGPoint(x: 0, y: 0),
                                  end: CGPoint(x: 0, y: size.height),
                                  options: [])
        }
        return SKTexture(image: image)
    }
}
