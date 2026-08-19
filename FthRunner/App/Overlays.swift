import SwiftUI

// MARK: - Oyun içi göstergeler

struct HUDOverlay: View {
    let score: Int
    let starfish: Int
    let best: Int

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(score)")
                        .font(.system(size: 46, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .animation(.snappy(duration: 0.15), value: score)
                    Text("REKOR \(best)")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.45))
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.gold)
                    Text("\(starfish)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)

            Spacer()
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Açılış menüsü

struct MenuOverlay: View {
    let best: Int
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            VStack(spacing: 8) {
                Text("KAYIK")
                    .font(.system(size: 62, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: Palette.accent.opacity(0.7), radius: 22)

                Text("Parmağını sürükle, denizde yolunu bul.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }

            if best > 0 {
                Text("REKOR  \(best)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Palette.gold)
            }

            Spacer()

            PrimaryButton(title: "BAŞLA", tint: Palette.accent, action: onStart)

            Text("Kıl payı geçişler ve deniz yıldızları ekstra puan.")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.35))
                .padding(.bottom, 34)
        }
        .padding(.horizontal, 40)
        .background(Color.black.opacity(0.35).ignoresSafeArea())
    }
}

// MARK: - Oyun sonu

struct GameOverOverlay: View {
    let score: Int
    let starfish: Int
    let best: Int
    let didBeatBest: Bool
    let onRetry: () -> Void
    let onMenu: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text(didBeatBest ? "YENİ REKOR" : "DEVRİLDİN")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(didBeatBest ? Palette.gold : Palette.danger)

            Text("\(score)")
                .font(.system(size: 84, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            HStack(spacing: 26) {
                StatBadge(label: "REKOR", value: "\(best)", tint: .white.opacity(0.75))
                StatBadge(label: "YILDIZ", value: "\(starfish)", tint: Palette.gold)
            }

            Spacer()

            VStack(spacing: 12) {
                PrimaryButton(title: "TEKRAR", tint: Palette.accent, action: onRetry)

                Button(action: onMenu) {
                    Text("MENÜ")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.55))
                }
            }
            .padding(.bottom, 34)
        }
        .padding(.horizontal, 40)
        .background(Color.black.opacity(0.5).ignoresSafeArea())
    }
}

// MARK: - Küçük parçalar

struct StatBadge: View {
    let label: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(tint)
            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
        }
    }
}

struct PrimaryButton: View {
    let title: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 19, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.85))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(tint)
                        .shadow(color: tint.opacity(0.5), radius: 18, y: 6)
                )
        }
        .buttonStyle(.plain)
    }
}
