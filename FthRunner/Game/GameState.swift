import Foundation
import Combine

enum GamePhase {
    case menu
    case playing
    case gameOver
}

/// Sahne ile SwiftUI arayüzü arasındaki köprü.
/// Oyun mantığı GameScene'de; burada sadece ekrana yansıyan durum var.
final class GameState: ObservableObject {

    @Published private(set) var phase: GamePhase = .menu
    @Published private(set) var score: Int = 0
    @Published private(set) var coins: Int = 0
    @Published private(set) var best: Int = UserDefaults.standard.integer(forKey: GameState.bestKey)
    /// Son turda rekor kırıldı mı — oyun sonu ekranı bunu gösteriyor.
    @Published private(set) var didBeatBest = false
    /// Kıl payı geçişlerde arayüzün parlaması için sayaç.
    @Published private(set) var nearMissPulse = 0

    private static let bestKey = "fth.runner.bestScore"

    // MARK: - Sahnenin çağırdıkları

    func beginRun() {
        score = 0
        coins = 0
        didBeatBest = false
        phase = .playing
    }

    func setScore(_ newValue: Int) {
        guard newValue != score else { return }
        score = newValue
    }

    func collectCoin() {
        coins += 1
    }

    func registerNearMiss() {
        nearMissPulse &+= 1
    }

    func endRun() {
        if score > best {
            best = score
            didBeatBest = true
            UserDefaults.standard.set(best, forKey: GameState.bestKey)
        }
        phase = .gameOver
    }

    func returnToMenu() {
        phase = .menu
    }
}
