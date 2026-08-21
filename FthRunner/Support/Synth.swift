import Foundation

/// Sesleri sıfırdan üreten küçük sentezleyici. Hiçbir ses dosyası yok;
/// bütün efektler burada örnek örnek hesaplanıyor.
///
/// Rastgelelik sabit tohumlu — böylece oyun her açılışta aynı sesi veriyor.
enum Synth {

    static let rate: Double = 44_100

    // MARK: - Temel dalga biçimleri

    static func sine(_ phase: Double) -> Float {
        Float(sin(phase * 2 * .pi))
    }

    /// Üçgen: sinüsten parlak, kareden yumuşak. Oyunun genel tınısı.
    static func triangle(_ phase: Double) -> Float {
        let p = phase - floor(phase)
        return Float(4 * abs(p - 0.5) - 1)
    }

    /// Yumuşatılmış kare dalga — sert ama cırlak değil.
    static func softSquare(_ phase: Double) -> Float {
        let p = phase - floor(phase)
        let raw: Double = p < 0.5 ? 1 : -1
        return Float(raw * 0.7 + sin(p * 2 * .pi) * 0.3)
    }

    /// Hızlı vuruş, üstel sönümlenen kuyruk.
    static func envelope(_ t: Double, attack: Double, decay: Double) -> Float {
        guard t >= 0 else { return 0 }
        if t < attack { return Float(t / attack) }
        return Float(exp(-(t - attack) / decay))
    }

    // MARK: - Yapı taşları

    /// Frekansı süre boyunca kayan tek ses.
    static func tone(duration: Double,
                     from: Double,
                     to: Double? = nil,
                     wave: (Double) -> Float = Synth.triangle,
                     attack: Double = 0.004,
                     decay: Double = 0.09,
                     gain: Float = 0.5) -> [Float] {
        let count = max(1, Int(duration * rate))
        var out = [Float](repeating: 0, count: count)
        var phase = 0.0
        let target = to ?? from

        for index in 0..<count {
            let t = Double(index) / rate
            let progress = duration > 0 ? t / duration : 0
            let frequency = from + (target - from) * progress
            phase += frequency / rate
            out[index] = wave(phase) * envelope(t, attack: attack, decay: decay) * gain
        }
        return out
    }

    /// Alçak geçiren süzgeçten geçmiş gürültü — su, köpük, çarpma.
    static func noise(duration: Double,
                      cutoffFrom: Double,
                      cutoffTo: Double,
                      attack: Double = 0.002,
                      decay: Double = 0.12,
                      gain: Float = 0.5,
                      seed: UInt64 = 1) -> [Float] {
        let count = max(1, Int(duration * rate))
        var out = [Float](repeating: 0, count: count)
        var random = SplitMix64(seed: seed)
        var lowpass = 0.0

        for index in 0..<count {
            let t = Double(index) / rate
            let progress = duration > 0 ? t / duration : 0
            let cutoff = cutoffFrom + (cutoffTo - cutoffFrom) * progress
            // Tek kutuplu süzgeç katsayısı.
            let alpha = min(1.0, cutoff / (rate / 2))
            let white = random.nextUnit()
            lowpass += alpha * (white - lowpass)
            out[index] = Float(lowpass) * envelope(t, attack: attack, decay: decay) * gain
        }
        return out
    }

    /// Katmanları üst üste bindirir; taşmayı yumuşak kırparak engeller.
    static func mix(_ layers: [[Float]]) -> [Float] {
        let count = layers.map(\.count).max() ?? 0
        var out = [Float](repeating: 0, count: count)
        for layer in layers {
            for index in layer.indices { out[index] += layer[index] }
        }
        for index in out.indices { out[index] = softClip(out[index]) }
        return out
    }

    /// Parçaları verilen saniyelerde arka arkaya dizer.
    static func sequence(_ parts: [(at: Double, samples: [Float])]) -> [Float] {
        var length = 0
        for part in parts {
            length = max(length, Int(part.at * rate) + part.samples.count)
        }
        var out = [Float](repeating: 0, count: max(1, length))
        for part in parts {
            let offset = Int(part.at * rate)
            for index in part.samples.indices {
                out[offset + index] += part.samples[index]
            }
        }
        for index in out.indices { out[index] = softClip(out[index]) }
        return out
    }

    private static func softClip(_ value: Float) -> Float {
        tanh(value)
    }

    /// Döngünün ek yerini gizlemek için kuyruğu başa çapraz karıştırır.
    private static func seamlessLoop(_ samples: [Float], fade: Double) -> [Float] {
        let fadeCount = min(Int(fade * rate), samples.count / 3)
        guard fadeCount > 0 else { return samples }

        var out = samples
        for index in 0..<fadeCount {
            let mixAmount = Float(index) / Float(fadeCount)
            let tail = samples[samples.count - fadeCount + index]
            out[index] = out[index] * mixAmount + tail * (1 - mixAmount)
        }
        return Array(out[0..<(samples.count - fadeCount)])
    }

    // MARK: - Hepsini bir kerede üret

    /// Arka planda hesaplanıp motora teslim edilen ham örnekler.
    struct Rendered {
        let effects: [SoundEngine.Effect: [Float]]
        let ambience: [Float]
    }

    static func renderAll() -> Rendered {
        Rendered(effects: [
            .jump: jump(),
            .splash: splash(),
            .pickup: pickup(),
            .hurt: hurt(),
            .gameOver: gameOver(),
            .fanfare: fanfare(),
            .sparkle: sparkle(),
            .button: button(),
            .seagull: seagull(),
            .extraLife: extraLife(),
            .homecoming: homecoming()
        ], ambience: waves())
    }

    // MARK: - Efektler

    /// Zıplama: yukarı kayan yumuşak ses ve küçük bir hışırtı.
    static func jump() -> [Float] {
        mix([
            tone(duration: 0.20, from: 420, to: 880, wave: triangle,
                 attack: 0.003, decay: 0.07, gain: 0.42),
            noise(duration: 0.10, cutoffFrom: 5_000, cutoffTo: 1_200,
                  attack: 0.002, decay: 0.035, gain: 0.14, seed: 7)
        ])
    }

    /// Suya iniş: parlaktan boğuğa kapanan köpük ve altında tok bir vuruş.
    static func splash() -> [Float] {
        mix([
            noise(duration: 0.40, cutoffFrom: 9_000, cutoffTo: 700,
                  attack: 0.002, decay: 0.13, gain: 0.34, seed: 11),
            tone(duration: 0.18, from: 120, to: 70, wave: sine,
                 attack: 0.003, decay: 0.06, gain: 0.30)
        ])
    }

    /// Deniz yıldızı: iki notalık parlak kıvılcım.
    static func pickup() -> [Float] {
        sequence([
            (0.00, tone(duration: 0.10, from: 1_046, wave: triangle, decay: 0.05, gain: 0.34)),
            (0.07, tone(duration: 0.14, from: 1_568, wave: triangle, decay: 0.07, gain: 0.30))
        ])
    }

    /// Can kaybı: aşağı kayan sert ses.
    static func hurt() -> [Float] {
        mix([
            tone(duration: 0.34, from: 520, to: 150, wave: softSquare,
                 attack: 0.003, decay: 0.13, gain: 0.34),
            noise(duration: 0.20, cutoffFrom: 2_600, cutoffTo: 400,
                  attack: 0.002, decay: 0.08, gain: 0.20, seed: 23)
        ])
    }

    /// Batış: inen üç nota.
    static func gameOver() -> [Float] {
        sequence([
            (0.00, tone(duration: 0.20, from: 440, wave: triangle, decay: 0.11, gain: 0.32)),
            (0.16, tone(duration: 0.20, from: 349, wave: triangle, decay: 0.11, gain: 0.32)),
            (0.32, tone(duration: 0.45, from: 262, wave: triangle, decay: 0.22, gain: 0.34))
        ])
    }

    /// Bölüm sonu: yükselen dörtlü ve üstüne uzun bir kapanış.
    static func fanfare() -> [Float] {
        sequence([
            (0.00, tone(duration: 0.16, from: 523, wave: triangle, decay: 0.09, gain: 0.30)),
            (0.12, tone(duration: 0.16, from: 659, wave: triangle, decay: 0.09, gain: 0.30)),
            (0.24, tone(duration: 0.16, from: 784, wave: triangle, decay: 0.09, gain: 0.30)),
            (0.36, tone(duration: 0.55, from: 1_046, wave: triangle, decay: 0.26, gain: 0.34)),
            (0.36, tone(duration: 0.55, from: 1_318, wave: sine, decay: 0.26, gain: 0.18))
        ])
    }

    /// Yeni arkadaş kayığa binerken çalan kısa parıltı.
    static func sparkle() -> [Float] {
        sequence([
            (0.00, tone(duration: 0.09, from: 1_318, wave: triangle, decay: 0.045, gain: 0.24)),
            (0.06, tone(duration: 0.09, from: 1_760, wave: triangle, decay: 0.045, gain: 0.22)),
            (0.12, tone(duration: 0.22, from: 2_093, wave: sine, decay: 0.10, gain: 0.20))
        ])
    }

    /// Onuncu deniz yıldızı bir can kazandırdı: sıcak, yükselen üç nota.
    /// Bölüm sonu fanfarından kısa ve farklı olsun diye beşli aralıklarla.
    static func extraLife() -> [Float] {
        sequence([
            (0.00, tone(duration: 0.12, from: 784, wave: triangle, decay: 0.06, gain: 0.30)),
            (0.09, tone(duration: 0.12, from: 1_046, wave: triangle, decay: 0.06, gain: 0.30)),
            (0.18, tone(duration: 0.42, from: 1_318, wave: triangle, decay: 0.20, gain: 0.32)),
            (0.18, tone(duration: 0.42, from: 659, wave: sine, decay: 0.20, gain: 0.20))
        ])
    }

    /// Menü dokunuşu.
    static func button() -> [Float] {
        tone(duration: 0.09, from: 680, to: 760, wave: triangle,
             attack: 0.002, decay: 0.035, gain: 0.26)
    }

    /// Yolculuğun sonu: geniş, sıcak bir akor. Bölüm sonu fanfarından
    /// uzun ve daha dolgun — bir kez duyulacak.
    static func homecoming() -> [Float] {
        sequence([
            (0.00, tone(duration: 0.22, from: 262, wave: triangle, decay: 0.12, gain: 0.26)),
            (0.14, tone(duration: 0.22, from: 330, wave: triangle, decay: 0.12, gain: 0.26)),
            (0.28, tone(duration: 0.24, from: 392, wave: triangle, decay: 0.13, gain: 0.26)),
            (0.42, tone(duration: 0.26, from: 523, wave: triangle, decay: 0.14, gain: 0.28)),
            // Kapanış akoru: hepsi birlikte, uzun kuyrukla.
            (0.58, tone(duration: 1.60, from: 262, wave: sine, decay: 0.75, gain: 0.20)),
            (0.58, tone(duration: 1.60, from: 392, wave: sine, decay: 0.75, gain: 0.18)),
            (0.58, tone(duration: 1.60, from: 523, wave: triangle, decay: 0.75, gain: 0.22)),
            (0.58, tone(duration: 1.60, from: 659, wave: sine, decay: 0.75, gain: 0.16))
        ])
    }

    /// Martı çığlığı: iki hızlı inen cıvıltı.
    static func seagull() -> [Float] {
        sequence([
            (0.00, tone(duration: 0.16, from: 1_500, to: 900, wave: triangle,
                        attack: 0.01, decay: 0.07, gain: 0.16)),
            (0.20, tone(duration: 0.20, from: 1_350, to: 780, wave: triangle,
                        attack: 0.012, decay: 0.09, gain: 0.14))
        ])
    }

    /// Arka plandaki deniz: yavaşça kabarıp inen boğuk uğultu.
    /// Döngü uzunluğu 8 saniye; salınımlar tam sayı çevrim yaptığı ve
    /// kuyruk başa karıştırıldığı için ek yeri duyulmuyor.
    static func waves() -> [Float] {
        let duration = 8.0
        let count = Int(duration * rate)
        var out = [Float](repeating: 0, count: count)
        var random = SplitMix64(seed: 99)
        var lowpass = 0.0
        var deepPass = 0.0

        for index in 0..<count {
            let t = Double(index) / rate
            let white = random.nextUnit()
            lowpass += 0.020 * (white - lowpass)
            deepPass += 0.0018 * (lowpass - deepPass)

            // İki yavaş salınım: biri 2, diğeri 3 çevrim yapıyor.
            let swellA = 0.5 + 0.5 * sin(t / duration * 2 * .pi * 2)
            let swellB = 0.5 + 0.5 * sin(t / duration * 2 * .pi * 3 + 1.1)
            let swell = 0.35 + 0.65 * (swellA * 0.6 + swellB * 0.4)

            out[index] = Float((lowpass - deepPass) * swell * 2.6)
        }

        return seamlessLoop(out, fade: 0.5)
    }
}

/// Küçük, hızlı ve tekrarlanabilir rastgele sayı üreteci.
/// Sabit tohumla çalıştığı için sesler her açılışta birebir aynı.
struct SplitMix64 {
    private var state: UInt64

    init(seed: UInt64) { state = seed &* 0x9E37_79B9_7F4A_7C15 }

    mutating func next() -> UInt64 {
        state = state &+ 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    /// -1...1 arasında düzgün dağılım.
    mutating func nextUnit() -> Double {
        Double(next() >> 11) / Double(1 << 53) * 2 - 1
    }
}
