import CoreGraphics
import Foundation

/// Oyunun tüm denge ayarları burada. Oyun hissini değiştirmek için
/// başka bir dosyaya dokunmaya gerek yok — sadece bu sayıları oynat.
enum Tuning {

    // MARK: - Akıntı hızı
    /// Oyunun başladığı kaydırma hızı (nokta/saniye).
    static let startScrollSpeed: CGFloat = 400
    static let maxScrollSpeed: CGFloat = 1080
    /// Saniyede ne kadar hızlanıyoruz.
    static let speedGainPerSecond: CGFloat = 12

    // MARK: - Kayık
    /// Çarpışma dairesinin yarıçapı. Görsel gövdeden biraz küçük tutuldu ki
    /// oyuncu "değmedim ki" dememesin.
    static let boatRadius: CGFloat = 19
    /// Kayığın çizim genişliği.
    static let boatWidth: CGFloat = 54
    /// Kayığın ekranın altından yüksekliği.
    static let boatBottomInset: CGFloat = 175
    /// Parmağı takip yumuşaklığı. Büyük = daha keskin/anında.
    static let boatFollowSharpness: CGFloat = 15
    /// Parmak hareketinin kayığa çarpanı. 1.0 = birebir.
    static let dragSensitivity: CGFloat = 1.15
    static let sideMargin: CGFloat = 10

    // MARK: - Engel dalgaları
    /// Ekran kaç sütuna bölünüyor. Engeller bu sütunlara yerleşir.
    static let slotCount = 5
    static let startSpawnInterval: TimeInterval = 1.05
    static let minSpawnInterval: TimeInterval = 0.52
    static let spawnIntervalDecayPerSecond: TimeInterval = 0.012
    /// Başlangıçta kaç sütun boş bırakılıyor (geçilecek koridor).
    static let startFreeSlots: CGFloat = 2.9
    static let minFreeSlots: CGFloat = 1.0
    static let freeSlotsShrinkPerSecond: CGFloat = 0.022
    /// Dolu sütunların gerçekten engel içerme olasılığı. Düşürürsen deniz seyrekleşir.
    static let slotFillChance: Double = 0.86
    /// Ardışık koridorlar arasındaki en fazla kayma (ekran genişliğinin oranı).
    /// Küçültürsen oyun daha adil, büyütürsen daha vahşi olur.
    static let maxCorridorShiftRatio: CGFloat = 0.6

    // MARK: - Engellerin sahneye girdiği saniyeler
    static let logUnlockTime: TimeInterval = 6
    static let jellyfishUnlockTime: TimeInterval = 13
    static let sharkUnlockTime: TimeInterval = 20
    static let netUnlockTime: TimeInterval = 32

    // MARK: - Köpek balığı
    static let sharkLength: CGFloat = 78
    static let sharkWidth: CGFloat = 30
    /// Saniyede yatay kaç nokta yol alır.
    static let sharkSwimSpeed: CGFloat = 95
    /// Doğduğu yerden ne kadar uzağa gidip geri döner.
    static let sharkSwimRange: CGFloat = 80

    // MARK: - Girdap
    static let whirlpoolUnlockTime: TimeInterval = 26
    static let whirlpoolInterval: TimeInterval = 7.5
    /// Bu yarıçapın içinde kayık merkeze doğru çekilir.
    static let whirlpoolPullRadius: CGFloat = 135
    /// Tam merkezde saniyede kaç nokta çeker (kenara doğru azalır).
    static let whirlpoolPullStrength: CGFloat = 330
    /// Bu yarıçapa girersen kayık devrilir.
    static let whirlpoolCoreRadius: CGFloat = 26

    // MARK: - Denizanası
    static let jellyfishRadius: CGFloat = 22
    /// Yanlara salınım genliği ve hızı.
    static let jellyfishSwayAmplitude: CGFloat = 34
    static let jellyfishSwaySpeed: CGFloat = 1.6

    // MARK: - Kütük ve ağ
    static let logLength: CGFloat = 130
    static let logThickness: CGFloat = 26
    static let netThickness: CGFloat = 20

    // MARK: - Kaya
    static let rockRadiusRange: ClosedRange<CGFloat> = 22...36

    // MARK: - Puan
    /// Kaç nokta ilerleyince +1 skor.
    static let distancePerScorePoint: CGFloat = 14
    static let starfishScore = 5
    static let nearMissScore = 2
    /// Engele bu kadar yakın geçersen "kıl payı" sayılır.
    static let nearMissDistance: CGFloat = 26
    /// Bir dalgada deniz yıldızı çıkma olasılığı.
    static let starfishChance: Double = 0.42
    static let starfishRadius: CGFloat = 13

    // MARK: - Deniz görüntüsü
    static let foamCount = 46
    /// Köpüklerin kaydırma hızına göre oranı (paralaks).
    static let foamParallaxRange: ClosedRange<CGFloat> = 0.18...0.55
    static let waveLineCount = 7
}
