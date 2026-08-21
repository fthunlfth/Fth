import UIKit

/// Bölümün gökyüzü ve deniz rengi. Her bölüm günün başka bir saatinde geçiyor.
struct SkyTheme {
    let skyTop: UIColor
    let skyBottom: UIColor
    let seaSurface: UIColor
    let seaDeep: UIColor
    /// Gökteki cisim (güneş veya ay). Yoksa çizilmez.
    let orb: UIColor?
    let orbIsMoon: Bool
    let cloud: UIColor
    let farIsland: UIColor
    let hasStars: Bool
    let hasRain: Bool
}

/// Bölüm sonunda kayığa katılan hayvan.
/// Hira'nın hiç bırakmadığı ayıcık. Bölüm ödülü değil — yolculuğun başından
/// beri kayıkta olduğu için mürettebatın sabit üyesi.
enum Teddy {
    static let name = "Tedi"
}

enum AnimalKind: String, CaseIterable {
    case cat, seal, penguin, turtle, puppy
    case owl, crab, arcticFox, octopus, otter

    /// Hayvanın türü.
    var species: String {
        switch self {
        case .cat:     return "Beyaz kedi"
        case .seal:    return "Yavru fok"
        case .penguin: return "Küçük penguen"
        case .turtle:  return "Deniz kaplumbağası"
        case .puppy:     return "Yavru köpek"
        case .owl:       return "Baykuş"
        case .crab:      return "Yengeç"
        case .arcticFox: return "Kutup tilkisi"
        case .octopus:   return "Yavru ahtapot"
        case .otter:     return "Su samuru"
        }
    }

    /// Adı olan arkadaşlar. Adı olmayanlar türüyle anılıyor.
    var name: String? {
        switch self {
        case .cat: return "Ted"
        default:   return nil
        }
    }

    /// Arayüzde görünen ad.
    var displayName: String { name ?? species }

    /// Kayığa katıldığı anda ekranda beliren cümle.
    var greeting: String { "\(displayName) artık macerada!" }

    /// Arayüzdeki küçük renk noktası.
    var swatch: UIColor {
        switch self {
        case .cat:     return Palette.catFur
        case .seal:    return Palette.sealFur
        case .penguin: return Palette.penguinBeak
        case .turtle:  return Palette.turtleShell
        case .puppy:     return Palette.puppyFur
        case .owl:       return Palette.owlFeather
        case .crab:      return Palette.crabShell
        case .arcticFox: return Palette.foxFur
        case .octopus:   return Palette.octopus
        case .otter:     return Palette.otterFur
        }
    }
}

/// Sahnede üretilebilen engel çeşitleri.
enum ObstacleKind: CaseIterable {
    /// Sudan çıkan kaya — zıplayarak aşılır.
    case rock
    /// Suda yüzen kütük — alçak, kolay engel.
    case driftwood
    /// Suyu yaran sırt yüzgeci; kayığa doğru geliyor.
    case sharkFin
    /// Yüzeyde parlayan denizanası.
    case jellyfish
    /// Şamandıralı ağ — yüksek zıplama ister.
    case net
    /// Alçak uçan martı; zıplarsan çarparsın, altından geçmen gerek.
    case seagull
    /// Yüzeydeki girdap — geniş ve alçak, uzun bir zıplama ister.
    case whirlpool
    /// Buzdağı: çok yüksek, tam zamanında ve basılı tutarak zıplamak gerek.
    case iceberg
    /// Deniz mayını: aşağı yukarı zıplayarak süzülüyor, yüksekliği kestirilmiyor.
    case seaMine
    /// Uçan balık: sudan fırlayıp yay çizerek kayığa doğru geliyor.
    case flyingFish
}

/// Bir bölümün tarifi.
struct Level {
    let index: Int
    let title: String
    /// Bölümün hedef süresi (saniye). Uzunluk bundan hesaplanıyor,
    /// böylece hız değişse de bölüm aynı sürede bitiyor.
    let duration: TimeInterval
    let scrollSpeed: CGFloat
    /// Ardışık engeller arası mesafe aralığı. Daraldıkça bölüm zorlaşır.
    let gapRange: ClosedRange<CGFloat>
    let kinds: [ObstacleKind]
    let sky: SkyTheme
    let reward: AnimalKind

    var number: Int { index + 1 }

    /// Bölümün uzunluğu (dünya noktası).
    var length: CGFloat { scrollSpeed * CGFloat(duration) }

    // MARK: - Bölümler

    static let all: [Level] = [
        Level(index: 0,
              title: "Sabah Denizi",
              duration: 60,
              scrollSpeed: 300,
              gapRange: 380...560,
              kinds: [.rock, .rock, .driftwood, .jellyfish],
              sky: .morning,
              reward: .cat),

        Level(index: 1,
              title: "Martı Koyu",
              duration: 60,
              scrollSpeed: 335,
              gapRange: 330...500,
              kinds: [.rock, .driftwood, .seagull, .jellyfish],
              sky: .noon,
              reward: .seal),

        Level(index: 2,
              title: "Gün Batımı Sığlığı",
              duration: 60,
              scrollSpeed: 370,
              gapRange: 300...450,
              kinds: [.rock, .driftwood, .sharkFin, .seagull, .jellyfish],
              sky: .sunset,
              reward: .penguin),

        Level(index: 3,
              title: "Ay Işığı Geçidi",
              duration: 60,
              scrollSpeed: 405,
              gapRange: 280...420,
              kinds: [.rock, .sharkFin, .seagull, .net, .whirlpool],
              sky: .night,
              reward: .turtle),

        Level(index: 4,
              title: "Fırtına Burnu",
              duration: 60,
              scrollSpeed: 445,
              gapRange: 250...380,
              kinds: [.rock, .driftwood, .sharkFin, .jellyfish, .net, .seagull, .whirlpool],
              sky: .storm,
              reward: .puppy),

        Level(index: 5,
              title: "Sisli Geçit",
              duration: 60,
              scrollSpeed: 465,
              gapRange: 250...380,
              kinds: [.rock, .driftwood, .sharkFin, .seagull, .jellyfish, .seaMine],
              sky: .fog,
              reward: .owl),

        Level(index: 6,
              title: "Mercan Sığlığı",
              duration: 60,
              scrollSpeed: 480,
              gapRange: 245...370,
              kinds: [.rock, .driftwood, .jellyfish, .seagull, .whirlpool, .flyingFish],
              sky: .coral,
              reward: .crab),

        Level(index: 7,
              title: "Buz Denizi",
              duration: 60,
              scrollSpeed: 500,
              gapRange: 240...360,
              kinds: [.iceberg, .rock, .driftwood, .sharkFin, .seagull, .seaMine],
              sky: .ice,
              reward: .arcticFox),

        Level(index: 8,
              title: "Kuzey Işıkları",
              duration: 60,
              scrollSpeed: 520,
              gapRange: 235...350,
              kinds: [.iceberg, .seaMine, .flyingFish, .net, .whirlpool, .seagull, .jellyfish],
              sky: .aurora,
              reward: .octopus),

        Level(index: 9,
              title: "Şafak Dönüşü",
              duration: 60,
              scrollSpeed: 540,
              gapRange: 230...345,
              kinds: ObstacleKind.allCases,
              sky: .dawn,
              reward: .otter)
    ]

    static func level(at index: Int) -> Level {
        all[min(max(index, 0), all.count - 1)]
    }
}

// MARK: - Gökyüzü temaları

extension SkyTheme {

    static let morning = SkyTheme(
        skyTop: UIColor(red: 0.55, green: 0.79, blue: 0.93, alpha: 1),
        skyBottom: UIColor(red: 0.90, green: 0.93, blue: 0.85, alpha: 1),
        seaSurface: UIColor(red: 0.29, green: 0.68, blue: 0.78, alpha: 1),
        seaDeep: UIColor(red: 0.06, green: 0.30, blue: 0.44, alpha: 1),
        orb: UIColor(red: 1.00, green: 0.95, blue: 0.75, alpha: 1),
        orbIsMoon: false,
        cloud: UIColor(white: 1.0, alpha: 1),
        farIsland: UIColor(red: 0.44, green: 0.58, blue: 0.60, alpha: 1),
        hasStars: false,
        hasRain: false)

    static let noon = SkyTheme(
        skyTop: UIColor(red: 0.29, green: 0.62, blue: 0.92, alpha: 1),
        skyBottom: UIColor(red: 0.72, green: 0.88, blue: 0.96, alpha: 1),
        seaSurface: UIColor(red: 0.18, green: 0.62, blue: 0.76, alpha: 1),
        seaDeep: UIColor(red: 0.04, green: 0.26, blue: 0.42, alpha: 1),
        orb: UIColor(red: 1.00, green: 0.97, blue: 0.82, alpha: 1),
        orbIsMoon: false,
        cloud: UIColor(white: 1.0, alpha: 1),
        farIsland: UIColor(red: 0.38, green: 0.55, blue: 0.56, alpha: 1),
        hasStars: false,
        hasRain: false)

    static let sunset = SkyTheme(
        skyTop: UIColor(red: 0.32, green: 0.30, blue: 0.56, alpha: 1),
        skyBottom: UIColor(red: 0.99, green: 0.62, blue: 0.40, alpha: 1),
        seaSurface: UIColor(red: 0.62, green: 0.40, blue: 0.48, alpha: 1),
        seaDeep: UIColor(red: 0.14, green: 0.13, blue: 0.32, alpha: 1),
        orb: UIColor(red: 1.00, green: 0.76, blue: 0.42, alpha: 1),
        orbIsMoon: false,
        cloud: UIColor(red: 1.00, green: 0.80, blue: 0.72, alpha: 1),
        farIsland: UIColor(red: 0.34, green: 0.28, blue: 0.42, alpha: 1),
        hasStars: false,
        hasRain: false)

    static let night = SkyTheme(
        skyTop: UIColor(red: 0.04, green: 0.06, blue: 0.18, alpha: 1),
        skyBottom: UIColor(red: 0.12, green: 0.20, blue: 0.40, alpha: 1),
        seaSurface: UIColor(red: 0.12, green: 0.31, blue: 0.48, alpha: 1),
        seaDeep: UIColor(red: 0.02, green: 0.08, blue: 0.20, alpha: 1),
        orb: UIColor(red: 0.96, green: 0.96, blue: 0.90, alpha: 1),
        orbIsMoon: true,
        cloud: UIColor(red: 0.60, green: 0.66, blue: 0.80, alpha: 1),
        farIsland: UIColor(red: 0.10, green: 0.15, blue: 0.28, alpha: 1),
        hasStars: true,
        hasRain: false)

    static let storm = SkyTheme(
        skyTop: UIColor(red: 0.11, green: 0.13, blue: 0.19, alpha: 1),
        skyBottom: UIColor(red: 0.30, green: 0.34, blue: 0.40, alpha: 1),
        seaSurface: UIColor(red: 0.18, green: 0.30, blue: 0.36, alpha: 1),
        seaDeep: UIColor(red: 0.04, green: 0.10, blue: 0.15, alpha: 1),
        orb: nil,
        orbIsMoon: false,
        cloud: UIColor(red: 0.34, green: 0.37, blue: 0.43, alpha: 1),
        farIsland: UIColor(red: 0.14, green: 0.18, blue: 0.22, alpha: 1),
        hasStars: false,
        hasRain: true)

    /// Sis: alçak kontrast, solmuş renkler, güneş perdenin ardında.
    static let fog = SkyTheme(
        skyTop: UIColor(red: 0.66, green: 0.71, blue: 0.72, alpha: 1),
        skyBottom: UIColor(red: 0.82, green: 0.85, blue: 0.83, alpha: 1),
        seaSurface: UIColor(red: 0.48, green: 0.57, blue: 0.61, alpha: 1),
        seaDeep: UIColor(red: 0.20, green: 0.27, blue: 0.31, alpha: 1),
        orb: UIColor(red: 0.91, green: 0.92, blue: 0.89, alpha: 1),
        orbIsMoon: false,
        cloud: UIColor(red: 0.77, green: 0.80, blue: 0.79, alpha: 1),
        farIsland: UIColor(red: 0.54, green: 0.60, blue: 0.61, alpha: 1),
        hasStars: false,
        hasRain: false)

    /// Mercan sığlığı: fırtınadan sonra gelen parlak, renkli bir nefes.
    static let coral = SkyTheme(
        skyTop: UIColor(red: 0.21, green: 0.71, blue: 0.84, alpha: 1),
        skyBottom: UIColor(red: 0.74, green: 0.92, blue: 0.95, alpha: 1),
        seaSurface: UIColor(red: 0.18, green: 0.79, blue: 0.76, alpha: 1),
        seaDeep: UIColor(red: 0.04, green: 0.43, blue: 0.50, alpha: 1),
        orb: UIColor(red: 1.00, green: 0.97, blue: 0.80, alpha: 1),
        orbIsMoon: false,
        cloud: UIColor(white: 1.0, alpha: 1),
        farIsland: UIColor(red: 0.24, green: 0.55, blue: 0.48, alpha: 1),
        hasStars: false,
        hasRain: false)

    /// Buz denizi: alçak güneş, soğuk mavi, ufukta buz kütleleri.
    static let ice = SkyTheme(
        skyTop: UIColor(red: 0.58, green: 0.72, blue: 0.84, alpha: 1),
        skyBottom: UIColor(red: 0.88, green: 0.93, blue: 0.96, alpha: 1),
        seaSurface: UIColor(red: 0.44, green: 0.63, blue: 0.74, alpha: 1),
        seaDeep: UIColor(red: 0.12, green: 0.27, blue: 0.38, alpha: 1),
        orb: UIColor(red: 1.00, green: 0.94, blue: 0.83, alpha: 1),
        orbIsMoon: false,
        cloud: UIColor(red: 0.95, green: 0.97, blue: 0.98, alpha: 1),
        farIsland: UIColor(red: 0.72, green: 0.83, blue: 0.89, alpha: 1),
        hasStars: false,
        hasRain: false)

    /// Kuzey ışıkları: gecenin üstünde yeşil perdeler.
    /// Bulut rengi yeşile çekildiği için bulutlar ışık perdesi gibi okunuyor.
    static let aurora = SkyTheme(
        skyTop: UIColor(red: 0.03, green: 0.07, blue: 0.17, alpha: 1),
        skyBottom: UIColor(red: 0.09, green: 0.32, blue: 0.25, alpha: 1),
        seaSurface: UIColor(red: 0.08, green: 0.26, blue: 0.29, alpha: 1),
        seaDeep: UIColor(red: 0.01, green: 0.05, blue: 0.10, alpha: 1),
        orb: UIColor(red: 0.86, green: 0.95, blue: 0.88, alpha: 1),
        orbIsMoon: true,
        cloud: UIColor(red: 0.31, green: 0.66, blue: 0.55, alpha: 1),
        farIsland: UIColor(red: 0.05, green: 0.13, blue: 0.21, alpha: 1),
        hasStars: true,
        hasRain: false)

    /// Şafak: yolculuğun sonu, eve dönüş.
    static let dawn = SkyTheme(
        skyTop: UIColor(red: 0.29, green: 0.36, blue: 0.59, alpha: 1),
        skyBottom: UIColor(red: 1.00, green: 0.77, blue: 0.54, alpha: 1),
        seaSurface: UIColor(red: 0.79, green: 0.53, blue: 0.42, alpha: 1),
        seaDeep: UIColor(red: 0.18, green: 0.17, blue: 0.32, alpha: 1),
        orb: UIColor(red: 1.00, green: 0.85, blue: 0.54, alpha: 1),
        orbIsMoon: false,
        cloud: UIColor(red: 1.00, green: 0.84, blue: 0.75, alpha: 1),
        farIsland: UIColor(red: 0.29, green: 0.24, blue: 0.36, alpha: 1),
        hasStars: false,
        hasRain: false)
}
