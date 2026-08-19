import CoreGraphics
import Foundation

/// Oyunun tüm denge ayarları burada. Oyun hissini değiştirmek için
/// başka bir dosyaya dokunmaya gerek yok — sadece bu sayıları oynat.
enum Tuning {

    // MARK: - Hız
    /// Oyunun başladığı kaydırma hızı (nokta/saniye).
    static let startScrollSpeed: CGFloat = 430
    /// Hızın çıkabileceği tavan.
    static let maxScrollSpeed: CGFloat = 1150
    /// Saniyede ne kadar hızlanıyoruz.
    static let speedGainPerSecond: CGFloat = 13

    // MARK: - Oyuncu
    static let playerRadius: CGFloat = 16
    /// Geminin ekranın altından yüksekliği.
    static let playerBottomInset: CGFloat = 170
    /// Parmağı takip yumuşaklığı. Büyük = daha keskin/anında.
    static let playerFollowSharpness: CGFloat = 16
    /// Parmak hareketinin gemiye çarpanı. 1.0 = birebir.
    static let dragSensitivity: CGFloat = 1.15
    /// Geminin ekran kenarına yaklaşabileceği mesafe.
    static let sideMargin: CGFloat = 12

    // MARK: - Duvarlar
    static let startSpawnInterval: TimeInterval = 0.95
    static let minSpawnInterval: TimeInterval = 0.40
    /// Saniyede doğma aralığının ne kadar kısaldığı.
    static let spawnIntervalDecayPerSecond: TimeInterval = 0.013
    static let wallHeight: CGFloat = 26
    static let wallCornerRadius: CGFloat = 8

    // MARK: - Geçit (gap)
    /// Geçit genişliği, ekran genişliğinin oranı olarak.
    static let startGapRatio: CGFloat = 0.44
    static let minGapRatio: CGFloat = 0.20
    static let gapShrinkPerSecond: CGFloat = 0.0065
    /// Bu saniyeden sonra bazen iki geçitli sıralar gelir.
    static let doubleGapAfterSeconds: TimeInterval = 22
    static let doubleGapChance: Double = 0.22
    /// İki geçit arasında kalması gereken en az duvar genişliği.
    static let minWallBetweenGaps: CGFloat = 70
    /// Çift geçitte bir geçidin inebileceği en dar ölçü.
    static let minDoubleGapWidth: CGFloat = 62
    /// Ardışık geçit merkezleri arasındaki en fazla kayma (ekran genişliğinin oranı).
    /// Küçültürsen oyun daha adil, büyütürsen daha vahşi olur.
    static let maxGapShiftRatio: CGFloat = 0.62

    // MARK: - Puan
    /// Kaç nokta ilerleyince +1 skor.
    static let distancePerScorePoint: CGFloat = 14
    static let coinScore = 5
    static let nearMissScore = 2
    /// Duvarın kenarına bu kadar yakın geçersen "kıl payı" sayılır.
    static let nearMissDistance: CGFloat = 24
    /// Bir sırada altın çıkma olasılığı.
    static let coinChance: Double = 0.45
    static let coinRadius: CGFloat = 11

    // MARK: - Arka plan
    static let starCount = 70
    /// Yıldızların kaydırma hızına göre oranı (paralaks).
    static let starParallaxRange: ClosedRange<CGFloat> = 0.12...0.45
}
