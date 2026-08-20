import SwiftUI

/// Karakterlerin ve engellerin renkleri. Gökyüzü ve deniz renkleri
/// bölümden bölüme değiştiği için `Level.swift` içindeki `SkyTheme`'de.
enum Palette {

    // MARK: - Kayık
    static let hull        = UIColor(red: 0.62, green: 0.38, blue: 0.20, alpha: 1)
    static let hullLight   = UIColor(red: 0.80, green: 0.56, blue: 0.33, alpha: 1)
    static let hullDark    = UIColor(red: 0.34, green: 0.19, blue: 0.09, alpha: 1)

    // MARK: - Kız
    static let skin        = UIColor(red: 1.00, green: 0.84, blue: 0.72, alpha: 1)
    static let skinShade   = UIColor(red: 0.92, green: 0.72, blue: 0.60, alpha: 1)
    static let hair        = UIColor(red: 0.42, green: 0.26, blue: 0.14, alpha: 1)
    static let hairShine   = UIColor(red: 0.56, green: 0.37, blue: 0.21, alpha: 1)
    static let dress       = UIColor(red: 0.98, green: 0.45, blue: 0.55, alpha: 1)
    static let lifeVest    = UIColor(red: 1.00, green: 0.68, blue: 0.20, alpha: 1)

    // MARK: - Ayıcık
    static let teddy       = UIColor(red: 0.66, green: 0.66, blue: 0.69, alpha: 1)
    static let teddyDark   = UIColor(red: 0.44, green: 0.44, blue: 0.48, alpha: 1)

    // MARK: - Yol arkadaşları
    static let catFur      = UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1)
    static let catShade    = UIColor(red: 0.86, green: 0.88, blue: 0.92, alpha: 1)
    static let catEye      = UIColor(red: 0.26, green: 0.58, blue: 0.95, alpha: 1)
    static let catNose     = UIColor(red: 0.98, green: 0.66, blue: 0.72, alpha: 1)
    static let sealFur     = UIColor(red: 0.60, green: 0.64, blue: 0.70, alpha: 1)
    static let sealShade   = UIColor(red: 0.46, green: 0.50, blue: 0.57, alpha: 1)
    static let penguin     = UIColor(red: 0.16, green: 0.19, blue: 0.26, alpha: 1)
    static let penguinBeak = UIColor(red: 1.00, green: 0.72, blue: 0.22, alpha: 1)
    static let turtleShell = UIColor(red: 0.38, green: 0.55, blue: 0.30, alpha: 1)
    static let turtleSkin  = UIColor(red: 0.56, green: 0.74, blue: 0.45, alpha: 1)
    static let puppyFur    = UIColor(red: 0.78, green: 0.55, blue: 0.30, alpha: 1)
    static let puppyShade  = UIColor(red: 0.60, green: 0.40, blue: 0.20, alpha: 1)
    static let animalEye   = UIColor(red: 0.14, green: 0.13, blue: 0.16, alpha: 1)

    // MARK: - Engeller
    static let rock        = UIColor(red: 0.38, green: 0.39, blue: 0.44, alpha: 1)
    static let rockLight   = UIColor(red: 0.54, green: 0.56, blue: 0.60, alpha: 1)
    static let rockDark    = UIColor(red: 0.24, green: 0.25, blue: 0.30, alpha: 1)
    static let shark       = UIColor(red: 0.36, green: 0.44, blue: 0.52, alpha: 1)
    static let sharkDark   = UIColor(red: 0.22, green: 0.29, blue: 0.36, alpha: 1)
    static let driftwood   = UIColor(red: 0.45, green: 0.32, blue: 0.20, alpha: 1)
    static let jellyfish   = UIColor(red: 0.85, green: 0.52, blue: 0.92, alpha: 1)
    static let buoy        = UIColor(red: 0.95, green: 0.30, blue: 0.28, alpha: 1)
    static let net         = UIColor(red: 0.90, green: 0.88, blue: 0.72, alpha: 1)
    static let seagull     = UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1)
    static let seagullBeak = UIColor(red: 1.00, green: 0.72, blue: 0.25, alpha: 1)
    static let whirlpool   = UIColor(red: 0.04, green: 0.18, blue: 0.30, alpha: 1)

    // MARK: - Ortak
    static let foam        = UIColor.white
    static let starfish    = UIColor(red: 1.00, green: 0.66, blue: 0.22, alpha: 1)
    static let island      = UIColor(red: 0.86, green: 0.76, blue: 0.52, alpha: 1)
    static let islandShade = UIColor(red: 0.72, green: 0.62, blue: 0.40, alpha: 1)
    static let palm        = UIColor(red: 0.30, green: 0.58, blue: 0.34, alpha: 1)
    static let heart       = UIColor(red: 0.98, green: 0.34, blue: 0.40, alpha: 1)

    // MARK: - SwiftUI karşılıkları
    static var accent: Color { Color(lifeVest) }
    static var danger: Color { Color(buoy) }
    static var gold:   Color { Color(starfish) }
    static var life:   Color { Color(heart) }
}
