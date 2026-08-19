import SwiftUI

/// Oyunun tüm renkleri. Görsel kimliği değiştirmek için tek durak.
enum Palette {

    // Arka plan degradesi (üstten alta)
    static let skyTop     = UIColor(red: 0.04, green: 0.05, blue: 0.12, alpha: 1)
    static let skyBottom  = UIColor(red: 0.10, green: 0.06, blue: 0.24, alpha: 1)

    // Oyuncu
    static let player      = UIColor(red: 0.35, green: 0.85, blue: 0.95, alpha: 1)
    static let playerGlow  = UIColor(red: 0.35, green: 0.85, blue: 0.95, alpha: 1)

    // Duvarlar
    static let wallFill    = UIColor(red: 0.98, green: 0.29, blue: 0.42, alpha: 1)
    static let wallStroke  = UIColor(red: 1.00, green: 0.62, blue: 0.70, alpha: 1)

    // Toplanabilirler
    static let coin        = UIColor(red: 1.00, green: 0.82, blue: 0.28, alpha: 1)

    // Yıldızlar / parçacıklar
    static let star        = UIColor(white: 1.0, alpha: 1)

    // SwiftUI karşılıkları
    static var accent: Color { Color(player) }
    static var danger: Color { Color(wallFill) }
    static var gold:   Color { Color(coin) }
    static var backdrop: Color { Color(skyTop) }
}
