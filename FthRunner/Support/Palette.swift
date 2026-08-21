import SwiftUI

/// Karakterlerin ve engellerin renkleri. Gökyüzü ve deniz renkleri
/// bölümden bölüme değiştiği için `Level.swift` içindeki `SkyTheme`'de.
enum Palette {

    // MARK: - Kayık
    static let hull        = UIColor(red: 0.62, green: 0.38, blue: 0.20, alpha: 1)
    static let hullLight   = UIColor(red: 0.80, green: 0.56, blue: 0.33, alpha: 1)
    static let hullDark    = UIColor(red: 0.34, green: 0.19, blue: 0.09, alpha: 1)

    // MARK: - Hira
    static let skin        = UIColor(red: 0.94, green: 0.79, blue: 0.65, alpha: 1)
    static let skinShade   = UIColor(red: 0.86, green: 0.68, blue: 0.53, alpha: 1)
    static let blush       = UIColor(red: 0.95, green: 0.62, blue: 0.56, alpha: 1)
    static let hair        = UIColor(red: 0.23, green: 0.17, blue: 0.13, alpha: 1)
    static let hairShine   = UIColor(red: 0.36, green: 0.27, blue: 0.21, alpha: 1)
    static let eyeBrown    = UIColor(red: 0.42, green: 0.29, blue: 0.18, alpha: 1)
    /// Püsküllü beyaz askılı üst.
    static let top         = UIColor(red: 0.98, green: 0.98, blue: 0.97, alpha: 1)
    static let topShade    = UIColor(red: 0.87, green: 0.87, blue: 0.84, alpha: 1)
    static let topMotif    = UIColor(red: 0.50, green: 0.78, blue: 0.91, alpha: 1)
    /// Fıstık yeşili şort.
    static let shorts      = UIColor(red: 0.84, green: 0.92, blue: 0.29, alpha: 1)
    static let shortsShade = UIColor(red: 0.72, green: 0.80, blue: 0.20, alpha: 1)
    static let sockStripe  = UIColor(red: 0.14, green: 0.15, blue: 0.18, alpha: 1)
    /// Sarı terlik.
    static let clog        = UIColor(red: 0.96, green: 0.88, blue: 0.13, alpha: 1)
    static let clogShade   = UIColor(red: 0.80, green: 0.72, blue: 0.06, alpha: 1)
    static let lifeVest    = UIColor(red: 1.00, green: 0.68, blue: 0.20, alpha: 1)
    static let sand        = UIColor(red: 0.93, green: 0.86, blue: 0.68, alpha: 1)

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
    static let owlFeather  = UIColor(red: 0.62, green: 0.48, blue: 0.36, alpha: 1)
    static let owlBelly    = UIColor(red: 0.88, green: 0.80, blue: 0.68, alpha: 1)
    static let owlBeak     = UIColor(red: 0.96, green: 0.74, blue: 0.30, alpha: 1)
    static let crabShell   = UIColor(red: 0.92, green: 0.36, blue: 0.28, alpha: 1)
    static let crabShade   = UIColor(red: 0.74, green: 0.24, blue: 0.18, alpha: 1)
    static let foxFur      = UIColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1)
    static let foxShade    = UIColor(red: 0.80, green: 0.84, blue: 0.90, alpha: 1)
    static let octopus     = UIColor(red: 0.86, green: 0.44, blue: 0.62, alpha: 1)
    static let octopusDark = UIColor(red: 0.68, green: 0.30, blue: 0.48, alpha: 1)
    static let otterFur    = UIColor(red: 0.55, green: 0.40, blue: 0.29, alpha: 1)
    static let otterBelly  = UIColor(red: 0.78, green: 0.66, blue: 0.53, alpha: 1)
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
    static let ice         = UIColor(red: 0.85, green: 0.93, blue: 0.97, alpha: 1)
    static let iceShade    = UIColor(red: 0.62, green: 0.78, blue: 0.88, alpha: 1)
    static let iceDeep     = UIColor(red: 0.44, green: 0.63, blue: 0.76, alpha: 1)
    static let mine        = UIColor(red: 0.20, green: 0.22, blue: 0.26, alpha: 1)
    static let mineSpike   = UIColor(red: 0.36, green: 0.38, blue: 0.42, alpha: 1)
    static let mineLight   = UIColor(red: 0.95, green: 0.28, blue: 0.24, alpha: 1)
    static let flyingFish  = UIColor(red: 0.42, green: 0.68, blue: 0.86, alpha: 1)
    static let flyingFin   = UIColor(red: 0.72, green: 0.88, blue: 0.96, alpha: 1)

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
