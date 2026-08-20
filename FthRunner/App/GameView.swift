import SwiftUI
import SpriteKit

/// SpriteKit sahnesini barındırır; üstüne menü, bölüm kartı, HUD ve
/// bölüm sonu ekranlarını koyar.
struct GameView: View {

    @StateObject private var state = GameState()
    @State private var scene: GameScene?

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.ignoresSafeArea()

                if let scene {
                    SpriteView(scene: scene, options: [.ignoresSiblingOrder])
                        .ignoresSafeArea()
                }

                overlay
                    .animation(.easeInOut(duration: 0.22), value: phaseKey)
            }
            .onAppear { makeSceneIfNeeded(size: proxy.size) }
        }
        .statusBarHidden()
    }

    /// Faz değişimlerinde geçiş animasyonu tetiklemek için sade bir anahtar.
    private var phaseKey: Int {
        switch state.phase {
        case .menu: return 0
        case .levelIntro: return 1
        case .playing: return 2
        case .levelComplete: return 3
        case .gameOver: return 4
        case .journeyComplete: return 5
        }
    }

    @ViewBuilder
    private var overlay: some View {
        switch state.phase {
        case .menu:
            MenuOverlay(best: state.best,
                        companions: state.companions,
                        resumeLevel: state.resumeLevelIndex,
                        hasProgress: state.furthestLevel > 0,
                        onContinue: { prepare(level: state.resumeLevelIndex) },
                        onRestart: restartJourney)

        case .levelIntro:
            LevelIntroOverlay(level: state.level,
                              showControls: state.levelIndex == 0,
                              onStart: startLevel)

        case .playing:
            HUDOverlay(level: state.level,
                       score: state.score,
                       starfish: state.starfish,
                       lives: state.lives,
                       progress: state.progress)

        case .levelComplete:
            LevelCompleteOverlay(level: state.level,
                                 companions: state.companions,
                                 score: state.score,
                                 onNext: nextLevel,
                                 onMenu: backToMenu)

        case .gameOver:
            GameOverOverlay(level: state.level,
                            score: state.score,
                            best: state.best,
                            onRetry: { prepare(level: state.levelIndex) },
                            onMenu: backToMenu)

        case .journeyComplete:
            JourneyCompleteOverlay(companions: state.companions,
                                   score: state.score,
                                   best: state.best,
                                   onRestart: restartJourney,
                                   onMenu: backToMenu)
        }
    }

    // MARK: - Eylemler

    private func makeSceneIfNeeded(size: CGSize) {
        guard scene == nil, size.width > 0, size.height > 0 else { return }
        let newScene = GameScene(size: size)
        newScene.scaleMode = .resizeFill
        newScene.state = state
        scene = newScene
    }

    private func prepare(level index: Int) {
        Haptics.tap()
        state.prepareLevel(index)
        scene?.prepare(level: index)
    }

    private func startLevel() {
        Haptics.tap()
        scene?.startLevel(state.levelIndex)
    }

    private func nextLevel() {
        Haptics.tap()
        state.advanceToNextLevel()
        scene?.prepare(level: state.levelIndex)
    }

    private func restartJourney() {
        Haptics.tap()
        state.restartJourney()
        scene?.prepare(level: state.levelIndex)
    }

    private func backToMenu() {
        Haptics.tap()
        state.returnToMenu()
        scene?.resetToIdle()
    }
}

#Preview {
    GameView()
}
