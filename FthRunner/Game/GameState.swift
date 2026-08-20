import Foundation
import Combine

enum GamePhase {
    /// Ana menü.
    case menu
    /// Bölüm tanıtım kartı.
    case levelIntro
    case playing
    /// Bölüm bitti, hayvan kayığa katıldı.
    case levelComplete
    case gameOver
    /// Bütün bölümler bitti.
    case journeyComplete
}

/// Sahne ile SwiftUI arayüzü arasındaki köprü.
/// Oyun mantığı GameScene'de; burada ekrana yansıyan ve kaydedilen durum var.
final class GameState: ObservableObject {

    @Published private(set) var phase: GamePhase = .menu
    @Published private(set) var levelIndex = 0
    @Published private(set) var score = 0
    @Published private(set) var starfish = 0
    @Published private(set) var lives = Tuning.livesPerLevel
    /// Bölümün ne kadarı geçildi (0...1).
    @Published private(set) var progress: Double = 0
    /// Kayığa katılmış hayvanlar — cihazda saklanıyor.
    @Published private(set) var companions: [AnimalKind] = []
    /// Bölüm sonu ekranında gösterilen yeni arkadaş.
    @Published private(set) var newestCompanion: AnimalKind?
    @Published private(set) var best = 0
    /// Ulaşılan en ileri bölüm — menüde buradan devam ediliyor.
    @Published private(set) var furthestLevel = 0

    var level: Level { Level.level(at: levelIndex) }
    var isFinalLevel: Bool { levelIndex >= Level.all.count - 1 }

    private enum Key {
        static let best = "fth.kayik.best"
        static let furthest = "fth.kayik.furthestLevel"
        static let companions = "fth.kayik.companions"
    }

    init() {
        let defaults = UserDefaults.standard
        best = defaults.integer(forKey: Key.best)
        furthestLevel = defaults.integer(forKey: Key.furthest)
        companions = (defaults.array(forKey: Key.companions) as? [String] ?? [])
            .compactMap(AnimalKind.init(rawValue:))
    }

    // MARK: - Menü

    /// Kaldığı yerden devam edilecek bölüm.
    var resumeLevelIndex: Int { min(furthestLevel, Level.all.count - 1) }

    func prepareLevel(_ index: Int) {
        levelIndex = min(max(index, 0), Level.all.count - 1)
        newestCompanion = nil
        phase = .levelIntro
    }

    func restartJourney() {
        companions = []
        furthestLevel = 0
        persistProgress()
        prepareLevel(0)
    }

    func returnToMenu() {
        newestCompanion = nil
        phase = .menu
    }

    // MARK: - Sahnenin çağırdıkları

    func beginLevel() {
        score = 0
        starfish = 0
        lives = Tuning.livesPerLevel
        progress = 0
        phase = .playing
    }

    func setScore(_ newValue: Int) {
        guard newValue != score else { return }
        score = newValue
    }

    func setProgress(_ newValue: Double) {
        let clamped = min(max(newValue, 0), 1)
        // Yüzdelik dilim değişmedikçe arayüzü boşuna tazelemeyelim.
        guard Int(clamped * 100) != Int(progress * 100) else { return }
        progress = clamped
    }

    func collectStarfish() {
        starfish += 1
    }

    /// Bir can eksilir. Canlar bittiyse `false` döner.
    func loseLife() -> Bool {
        lives = max(0, lives - 1)
        return lives > 0
    }

    func completeLevel() {
        if !companions.contains(level.reward) {
            companions.append(level.reward)
        }
        newestCompanion = level.reward
        furthestLevel = max(furthestLevel, levelIndex + 1)
        recordScore()
        persistProgress()
        phase = isFinalLevel ? .journeyComplete : .levelComplete
    }

    func advanceToNextLevel() {
        guard !isFinalLevel else { returnToMenu(); return }
        prepareLevel(levelIndex + 1)
    }

    func endRun() {
        recordScore()
        phase = .gameOver
    }

    // MARK: - Kayıt

    private func recordScore() {
        guard score > best else { return }
        best = score
        UserDefaults.standard.set(best, forKey: Key.best)
    }

    private func persistProgress() {
        let defaults = UserDefaults.standard
        defaults.set(furthestLevel, forKey: Key.furthest)
        defaults.set(companions.map(\.rawValue), forKey: Key.companions)
    }
}
