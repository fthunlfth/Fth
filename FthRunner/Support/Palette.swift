import SwiftUI

/// Oyunun tüm renkleri. Görsel kimliği değiştirmek için tek durak.
enum Palette {

    // MARK: - Deniz
    static let seaTop      = UIColor(red: 0.05, green: 0.28, blue: 0.42, alpha: 1)   // uzaktaki derin su
    static let seaBottom   = UIColor(red: 0.10, green: 0.52, blue: 0.62, alpha: 1)   // yakındaki sığ su
    static let foam        = UIColor(white: 1.0, alpha: 1)
    static let deepShadow  = UIColor(red: 0.02, green: 0.16, blue: 0.28, alpha: 1)

    // MARK: - Kayık
    static let hull        = UIColor(red: 0.62, green: 0.38, blue: 0.20, alpha: 1)   // ahşap gövde
    static let hullLight   = UIColor(red: 0.80, green: 0.56, blue: 0.33, alpha: 1)   // iç kısım
    static let hullDark    = UIColor(red: 0.40, green: 0.23, blue: 0.11, alpha: 1)   // kenar çizgisi

    // MARK: - Kız
    static let skin        = UIColor(red: 1.00, green: 0.84, blue: 0.72, alpha: 1)
    static let hair        = UIColor(red: 0.42, green: 0.26, blue: 0.14, alpha: 1)   // kahverengi saç
    static let hairShine   = UIColor(red: 0.55, green: 0.36, blue: 0.20, alpha: 1)
    static let dress       = UIColor(red: 0.98, green: 0.45, blue: 0.55, alpha: 1)
    static let lifeVest    = UIColor(red: 1.00, green: 0.68, blue: 0.20, alpha: 1)

    // MARK: - Ayıcık
    static let teddy       = UIColor(red: 0.66, green: 0.66, blue: 0.69, alpha: 1)   // küçük gri ayı
    static let teddyDark   = UIColor(red: 0.45, green: 0.45, blue: 0.49, alpha: 1)

    // MARK: - Engeller
    static let rock        = UIColor(red: 0.38, green: 0.39, blue: 0.44, alpha: 1)
    static let rockLight   = UIColor(red: 0.52, green: 0.54, blue: 0.58, alpha: 1)
    static let shark       = UIColor(red: 0.36, green: 0.44, blue: 0.52, alpha: 1)
    static let sharkBelly  = UIColor(red: 0.86, green: 0.89, blue: 0.92, alpha: 1)
    static let whirlpool   = UIColor(red: 0.03, green: 0.20, blue: 0.32, alpha: 1)
    static let driftwood   = UIColor(red: 0.45, green: 0.32, blue: 0.20, alpha: 1)
    static let jellyfish   = UIColor(red: 0.85, green: 0.52, blue: 0.92, alpha: 1)
    static let buoy        = UIColor(red: 0.95, green: 0.30, blue: 0.28, alpha: 1)
    static let net         = UIColor(red: 0.90, green: 0.88, blue: 0.72, alpha: 1)

    // MARK: - Toplanabilirler
    static let starfish    = UIColor(red: 1.00, green: 0.66, blue: 0.22, alpha: 1)

    // MARK: - SwiftUI karşılıkları
    static var accent:   Color { Color(lifeVest) }
    static var danger:   Color { Color(buoy) }
    static var gold:     Color { Color(starfish) }
    static var backdrop: Color { Color(seaTop) }
}
