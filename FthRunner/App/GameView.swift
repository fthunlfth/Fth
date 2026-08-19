import SwiftUI
import SpriteKit

/// SpriteKit sahnesini barındırır ve üstüne menü / HUD / oyun sonu ekranını koyar.
struct GameView: View {

    @StateObject private var state = GameState()
    @State private var scene: GameScene?

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Palette.backdrop.ignoresSafeArea()

                if let scene {
                    SpriteView(scene: scene, options: [.ignoresSiblingOrder])
                        .ignoresSafeArea()
                }

                overlay
            }
            .onAppear { makeSceneIfNeeded(size: proxy.size) }
        }
        .statusBarHidden()
    }

    @ViewBuilder
    private var overlay: some View {
        switch state.phase {
        case .menu:
            MenuOverlay(best: state.best, onStart: start)
                .transition(.opacity)
        case .playing:
            HUDOverlay(score: state.score, coins: state.coins, best: state.best)
                .transition(.opacity)
        case .gameOver:
            GameOverOverlay(score: state.score,
                            coins: state.coins,
                            best: state.best,
                            didBeatBest: state.didBeatBest,
                            onRetry: start,
                            onMenu: backToMenu)
                .transition(.opacity)
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

    private func start() {
        Haptics.tap()
        withAnimation(.easeOut(duration: 0.2)) {
            scene?.startRun()
        }
    }

    private func backToMenu() {
        Haptics.tap()
        scene?.resetToIdle()
        withAnimation(.easeOut(duration: 0.2)) {
            state.returnToMenu()
        }
    }
}

#Preview {
    GameView()
}
