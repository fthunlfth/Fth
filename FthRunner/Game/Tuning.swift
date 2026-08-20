import CoreGraphics
import Foundation

/// Oyunun tüm denge ayarları burada. Oyun hissini değiştirmek için
/// başka bir dosyaya dokunmaya gerek yok — sadece bu sayıları oynat.
/// (Bölüm uzunlukları ve engel karışımı `Level.swift` içinde.)
enum Tuning {

    // MARK: - Sahne yerleşimi
    /// Kayık ekranın solundan bu oranda duruyor; dünya sola akıyor.
    static let boatScreenXRatio: CGFloat = 0.30
    /// Sakin su seviyesi, ekran yüksekliğinin oranı olarak (alttan).
    static let waterLineRatio: CGFloat = 0.40

    // MARK: - Kayık
    static let boatLength: CGFloat = 96
    static let boatHeight: CGFloat = 36
    /// Çarpışma dikdörtgeni görsel gövdeden bu kadar içeride — "değmedim ki" dedirtmesin.
    static let boatCollisionInset: CGFloat = 7

    // MARK: - Zıplama
    static let gravity: CGFloat = 2700
    static let jumpImpulse: CGFloat = 800
    /// Parmağı basılı tutarken yükselişte yerçekimi bu oranda uygulanır.
    /// Küçük değer = basılı tutunca daha yükseğe zıplama.
    static let jumpHoldGravityScale: CGFloat = 0.42
    static let maxJumpHoldTime: TimeInterval = 0.26
    /// Sudan ayrıldıktan sonra hâlâ zıplayabildiğin küçük tolerans.
    static let coyoteTime: TimeInterval = 0.10
    /// Havadayken erken basılan zıplama bu süre boyunca hafızada tutulur.
    static let jumpBufferTime: TimeInterval = 0.12
    /// Zıplarken kayığın burnu ne kadar kalkıyor.
    static let jumpPitchAngle: CGFloat = 0.30

    // MARK: - Dalga
    // Su yüzeyi iki sinüsün toplamı. Hem çizim hem kayığın oturduğu yükseklik
    // hem de engellerin yerleşimi aynı fonksiyondan besleniyor.
    static let waveAmplitude: CGFloat = 9
    static let waveLength: CGFloat = 220
    static let waveSpeed: CGFloat = 1.4
    static let waveAmplitude2: CGFloat = 4
    static let waveLength2: CGFloat = 96
    static let waveSpeed2: CGFloat = 2.3

    // MARK: - Can
    /// Bölüme kaç canla başlanıyor. Canlar bitince bölüm baştan başlar.
    static let startingLives = 2
    /// Can göstergesindeki kalp sayısı ve tavan.
    static let maxLives = 3
    /// Kaç deniz yıldızı bir can ediyor.
    static let starfishPerExtraLife = 10
    /// Yedikten sonra dokunulmazlık süresi.
    static let invulnerabilityTime: TimeInterval = 1.5

    // MARK: - Puan
    /// Kaç nokta ilerleyince +1 skor.
    static let distancePerScorePoint: CGFloat = 16
    static let starfishScore = 5
    static let levelClearScore = 50
    static let starfishRadius: CGFloat = 13
    /// Bir engel aralığında deniz yıldızı çıkma olasılığı.
    static let starfishChance: Double = 0.55

    // MARK: - Bölüm sonu
    /// Bitişe bu kadar kala engel üretimi durur; ada rahatça görünsün.
    static let goalClearanceDistance: CGFloat = 700
    /// Adaya yaklaşınca kayığın yavaşladığı mesafe.
    static let goalSlowdownDistance: CGFloat = 320

    // MARK: - Deniz görüntüsü
    static let foamCount = 26
    static let cloudCount = 5
    static let farIslandCount = 4
}
