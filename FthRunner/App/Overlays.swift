import SwiftUI

// MARK: - Oyun içi göstergeler

struct HUDOverlay: View {
    let level: Level
    let score: Int
    /// Sıradaki cana kalan yıldız sayacı.
    let starfishTowardLife: Int
    let lives: Int
    let progress: Double

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center) {
                Text("\(score)")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .animation(.snappy(duration: 0.15), value: score)
                    .shadow(color: .black.opacity(0.35), radius: 4, y: 1)

                Spacer()

                // Sıradaki cana ne kadar kaldığı: çocuğun asıl merak ettiği sayı.
                HStack(spacing: 5) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.gold)
                    Text("\(starfishTowardLife)/\(Tuning.starfishPerExtraLife)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                }

                Spacer()

                HStack(spacing: 4) {
                    ForEach(0..<Tuning.maxLives, id: \.self) { index in
                        Image(systemName: index < lives ? "heart.fill" : "heart")
                            .font(.system(size: 15))
                            .foregroundStyle(index < lives ? Palette.life : .white.opacity(0.3))
                    }
                }
                .animation(.snappy(duration: 0.25), value: lives)
            }

            ProgressTrack(level: level, progress: progress)
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .frame(maxHeight: .infinity, alignment: .top)
        .allowsHitTesting(false)
    }
}

/// Bölümün ne kadarının geçildiğini gösteren şerit; sonunda ödül hayvanı bekliyor.
struct ProgressTrack: View {
    let level: Level
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text("BÖLÜM \(level.number)")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                Text(level.title.uppercased())
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .tracking(0.8)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.black.opacity(0.28))
                    Capsule()
                        .fill(Palette.accent)
                        .frame(width: max(4, proxy.size.width * progress))
                    Circle()
                        .fill(Color(level.reward.swatch))
                        .frame(width: 9, height: 9)
                        .overlay(Circle().stroke(.white.opacity(0.8), lineWidth: 1))
                        .offset(x: proxy.size.width - 9)
                }
            }
            .frame(height: 7)
            .animation(.linear(duration: 0.25), value: progress)
        }
    }
}

// MARK: - Ana menü

struct MenuOverlay: View {
    let best: Int
    let companions: [AnimalKind]
    let resumeLevel: Int
    let hasProgress: Bool
    let onContinue: () -> Void
    let onRestart: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 6) {
                    Text("HİRA'NIN\nMACERASI")
                        .font(.system(size: 46, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: Palette.accent.opacity(0.85), radius: 18)
                    Text("Hira, ayıcığı Tedi ve bir kayık.\n\(Level.all.count) bölüm, \(Level.all.count) yeni arkadaş.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.75))
                }

                if best > 0 {
                    Text("REKOR  \(best)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Palette.gold)
                }

                CrewStrip(companions: companions, title: "MÜRETTEBAT", alignment: .leading)

                Spacer(minLength: 0)

                VStack(spacing: 10) {
                    PrimaryButton(title: hasProgress ? "DEVAM ET — BÖLÜM \(resumeLevel + 1)" : "BAŞLA",
                                  tint: Palette.accent,
                                  action: onContinue)
                    if hasProgress {
                        SecondaryButton(title: "BAŞTAN BAŞLA", action: onRestart)
                    }
                }
            }
            .frame(maxWidth: 420, alignment: .leading)
            .padding(.horizontal, 40)
            .padding(.vertical, 28)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Sağ tarafı açık bırakıyoruz: Hira, ayıcığı ve kedisi orada duruyor.
        .background(
            LinearGradient(colors: [.black.opacity(0.6), .black.opacity(0.05)],
                           startPoint: .leading, endPoint: .trailing)
                .ignoresSafeArea()
        )
    }
}

// MARK: - Bölüm kartı

struct LevelIntroOverlay: View {
    let level: Level
    let showControls: Bool
    let onStart: () -> Void

    var body: some View {
        OverlayShell {
            Spacer()

            VStack(spacing: 8) {
                Text("BÖLÜM \(level.number)")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(Palette.accent)
                    .tracking(2)
                Text(level.title)
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 6) {
                Text("BÖLÜM SONUNDA")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.45))
                    .tracking(1.5)
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(level.reward.swatch))
                        .frame(width: 12, height: 12)
                        .overlay(Circle().stroke(.white.opacity(0.7), lineWidth: 1))
                    Text(level.reward.displayName)
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                // Adı olan arkadaşın türünü de söyleyelim: "Ted · beyaz kedi".
                if level.reward.name != nil {
                    Text(level.reward.species.lowercased())
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.55))
                }
            }

            if showControls {
                Text("Ekrana dokun: zıpla.\nBasılı tut: daha yükseğe.\n\n\(Tuning.starfishPerExtraLife) deniz yıldızı = 1 can (en fazla \(Tuning.maxLives)).")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            Spacer()

            PrimaryButton(title: "DENİZE AÇIL", tint: Palette.accent, action: onStart)
        }
    }
}

// MARK: - Bölüm sonu

struct LevelCompleteOverlay: View {
    let level: Level
    let companions: [AnimalKind]
    let score: Int
    let onNext: () -> Void
    let onMenu: () -> Void

    var body: some View {
        OverlayShell {
            Spacer()

            Text("BÖLÜM \(level.number) TAMAM")
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundStyle(Palette.accent)
                .tracking(2)

            Text(level.reward.greeting)
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            Text("\(score)")
                .font(.system(size: 50, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            CrewStrip(companions: companions, title: "KAYIKTAKİLER")

            Spacer()

            VStack(spacing: 12) {
                PrimaryButton(title: "SONRAKİ BÖLÜM", tint: Palette.accent, action: onNext)
                SecondaryButton(title: "MENÜ", action: onMenu)
            }
        }
    }
}

// MARK: - Yolculuk tamam

struct JourneyCompleteOverlay: View {
    let companions: [AnimalKind]
    let score: Int
    let best: Int
    let onRestart: () -> Void
    let onMenu: () -> Void

    var body: some View {
        OverlayShell {
            Spacer()

            Text("KARAYA VARDINIZ")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(Palette.gold)
                .multilineTextAlignment(.center)

            Text("\(Level.all.count) bölüm, \(Level.all.count) arkadaş.\nHepsi Hira'ya teşekkür etti.")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)

            CrewStrip(companions: companions, title: "MÜRETTEBAT")

            HStack(spacing: 26) {
                StatBadge(label: "SKOR", value: "\(score)", tint: .white)
                StatBadge(label: "REKOR", value: "\(best)", tint: Palette.gold)
            }

            Spacer()

            VStack(spacing: 12) {
                PrimaryButton(title: "BAŞTAN BAŞLA", tint: Palette.accent, action: onRestart)
                SecondaryButton(title: "MENÜ", action: onMenu)
            }
        }
    }
}

// MARK: - Oyun sonu

struct GameOverOverlay: View {
    let level: Level
    let score: Int
    let best: Int
    let onRetry: () -> Void
    let onMenu: () -> Void

    var body: some View {
        OverlayShell {
            Spacer()

            Text("BATTIN")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(Palette.danger)

            Text("Bölüm \(level.number) · \(level.title)")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))

            Text("Bölümün başına dönüyorsun.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.45))

            Text("\(score)")
                .font(.system(size: 72, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            StatBadge(label: "REKOR", value: "\(best)", tint: Palette.gold)

            Spacer()

            VStack(spacing: 12) {
                PrimaryButton(title: "BÖLÜM BAŞINA DÖN", tint: Palette.accent, action: onRetry)
                SecondaryButton(title: "MENÜ", action: onMenu)
            }
        }
    }
}

// MARK: - Ortak parçalar

/// Bütün tam ekran kartların ortak çerçevesi.
struct OverlayShell<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 18) {
            content
        }
        .padding(.horizontal, 36)
        .padding(.top, 60)
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.45).ignoresSafeArea())
    }
}

/// Kayıktakilerin listesi. Ayıcık Tedi hep başta duruyor; arkasından
/// bölüm bölüm katılan hayvanlar geliyor.
struct CrewStrip: View {
    let companions: [AnimalKind]
    let title: String
    var alignment: HorizontalAlignment = .center

    var body: some View {
        VStack(alignment: alignment, spacing: 8) {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.45))
                .tracking(1.5)

            FlowRow(spacing: 8) {
                CrewChip(name: Teddy.name, tint: Color(Palette.teddy))
                ForEach(companions, id: \.self) { animal in
                    CrewChip(name: animal.displayName, tint: Color(animal.swatch))
                }
            }

            if companions.isEmpty {
                Text("Ted'i bulmak için 1. bölümü bitir.")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
    }
}

struct CrewChip: View {
    let name: String
    let tint: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(tint)
                .frame(width: 9, height: 9)
                .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 0.8))
            Text(name)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.92))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(.white.opacity(0.14)))
    }
}

/// Sığmayan öğeleri alt satıra taşıyan basit akış yerleşimi.
struct FlowRow: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rowWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth > 0 && rowWidth + spacing + size.width > maxWidth {
                totalHeight += rowHeight + spacing
                rowWidth = size.width
                rowHeight = size.height
            } else {
                rowWidth += (rowWidth > 0 ? spacing : 0) + size.width
                rowHeight = max(rowHeight, size.height)
            }
        }
        return CGSize(width: maxWidth == .infinity ? rowWidth : maxWidth, height: totalHeight + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX && x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

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
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.45))
                .tracking(1)
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
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.85))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(tint)
                        .shadow(color: tint.opacity(0.45), radius: 16, y: 5)
                )
        }
        .buttonStyle(.plain)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

/// Sesi açıp kapatan küçük düğme. Tercih cihazda saklanıyor.
struct SoundToggle: View {
    @Binding var isMuted: Bool

    var body: some View {
        Button {
            isMuted.toggle()
            SoundEngine.shared.isMuted = isMuted
            if !isMuted { SoundEngine.shared.play(.button) }
            Haptics.tap()
        } label: {
            Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white.opacity(isMuted ? 0.5 : 0.9))
                .frame(width: 42, height: 42)
                .background(Circle().fill(.black.opacity(0.32)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isMuted ? "Sesi aç" : "Sesi kapat")
    }
}
