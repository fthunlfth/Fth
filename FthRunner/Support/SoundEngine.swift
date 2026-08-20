import AVFoundation
import UIKit

/// Oyunun bütün sesleri. Ses dosyası yok — dalga biçimleri açılışta
/// hesaplanıp bellekte tutuluyor, tıpkı grafiklerin kodla çizilmesi gibi.
///
/// Tek bir AVAudioEngine üstünde iki hat var: kısa efektler için sırayla
/// kullanılan bir ses havuzu ve arka planda dönen dalga sesi.
final class SoundEngine {

    static let shared = SoundEngine()

    enum Effect {
        case jump
        case splash
        case pickup
        case hurt
        case gameOver
        case fanfare
        case sparkle
        case button
        case seagull
    }

    /// Sessize alma tercihi cihazda saklanıyor.
    var isMuted: Bool {
        didSet {
            UserDefaults.standard.set(isMuted, forKey: Self.muteKey)
            applyVolumes()
        }
    }

    private static let muteKey = "fth.kayik.muted"

    private let engine = AVAudioEngine()
    private let effectMixer = AVAudioMixerNode()
    private let ambienceMixer = AVAudioMixerNode()
    private var voices: [AVAudioPlayerNode] = []
    private let ambienceVoice = AVAudioPlayerNode()
    private var nextVoice = 0

    private var buffers: [Effect: AVAudioPCMBuffer] = [:]
    private var ambienceBuffer: AVAudioPCMBuffer?
    private var isRunning = false
    private var isPreparing = false

    /// 44.1 kHz tek kanal — bu ayarla asla nil dönmez.
    private let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!

    private init() {
        isMuted = UserDefaults.standard.bool(forKey: Self.muteKey)
    }

    // MARK: - Kurulum

    /// Uygulama açılırken bir kez çağrılır. Tekrar çağrılması zararsız.
    ///
    /// Dalga biçimlerini hesaplamak yarım saniye sürebiliyor; bu iş arka
    /// planda yapılıyor ki açılışta kare düşmesin. Hazır olana kadar
    /// `play` çağrıları sessizce yok sayılır.
    func start() {
        guard !isRunning, !isPreparing else { return }
        isPreparing = true

        configureSession()
        buildGraph()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let rendered = Synth.renderAll()
            DispatchQueue.main.async { self?.finishStart(with: rendered) }
        }
    }

    private func finishStart(with rendered: Synth.Rendered) {
        for (effect, samples) in rendered.effects {
            buffers[effect] = makeBuffer(samples)
        }
        ambienceBuffer = makeBuffer(rendered.ambience)

        do {
            try engine.start()
        } catch {
            // Ses açılamazsa oyun sessiz devam etsin; oynanışı engellemesin.
            isPreparing = false
            return
        }

        isRunning = true
        isPreparing = false
        applyVolumes()
        for voice in voices { voice.play() }
        startAmbience()
        observeLifecycle()
    }

    private func configureSession() {
        let session = AVAudioSession.sharedInstance()
        // .ambient + mixWithOthers: kullanıcının müziğini kesmiyoruz ve
        // sessize alma düğmesi bizim sesimizi de susturuyor.
        try? session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
    }

    private func buildGraph() {
        engine.attach(effectMixer)
        engine.attach(ambienceMixer)
        engine.connect(effectMixer, to: engine.mainMixerNode, format: format)
        engine.connect(ambienceMixer, to: engine.mainMixerNode, format: format)

        // Sekiz ses: üst üste binen efektler birbirini kesmesin.
        for _ in 0..<8 {
            let voice = AVAudioPlayerNode()
            engine.attach(voice)
            engine.connect(voice, to: effectMixer, format: format)
            voices.append(voice)
        }

        engine.attach(ambienceVoice)
        engine.connect(ambienceVoice, to: ambienceMixer, format: format)
    }

    private func applyVolumes() {
        effectMixer.outputVolume = isMuted ? 0 : 0.9
        ambienceMixer.outputVolume = isMuted ? 0 : 0.30
    }

    private func startAmbience() {
        guard let ambienceBuffer else { return }
        ambienceVoice.scheduleBuffer(ambienceBuffer, at: nil, options: .loops, completionHandler: nil)
        ambienceVoice.play()
    }

    // MARK: - Yaşam döngüsü

    private func observeLifecycle() {
        let center = NotificationCenter.default
        center.addObserver(forName: UIApplication.didBecomeActiveNotification,
                           object: nil, queue: .main) { [weak self] _ in
            self?.resume()
        }
        center.addObserver(forName: AVAudioSession.interruptionNotification,
                           object: nil, queue: .main) { [weak self] note in
            guard let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: raw) else { return }
            if type == .ended { self?.resume() }
        }
    }

    /// Arka plandan dönüşte motor durmuş olabilir; sessizce ayağa kaldır.
    private func resume() {
        guard isRunning, !engine.isRunning else { return }
        try? AVAudioSession.sharedInstance().setActive(true)
        try? engine.start()
        for voice in voices { voice.play() }
        startAmbience()
    }

    // MARK: - Çalma

    func play(_ effect: Effect, volume: Float = 1) {
        guard isRunning, !isMuted, let buffer = buffers[effect] else { return }

        let voice = voices[nextVoice]
        nextVoice = (nextVoice + 1) % voices.count
        voice.volume = volume
        voice.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        if !voice.isPlaying { voice.play() }
    }

    // MARK: - Dalga biçimlerinin üretimi

    private func makeBuffer(_ samples: [Float]) -> AVAudioPCMBuffer? {
        guard !samples.isEmpty,
              let buffer = AVAudioPCMBuffer(pcmFormat: format,
                                            frameCapacity: AVAudioFrameCount(samples.count)),
              let channel = buffer.floatChannelData?[0] else { return nil }
        buffer.frameLength = AVAudioFrameCount(samples.count)
        for index in samples.indices { channel[index] = samples[index] }
        return buffer
    }
}
