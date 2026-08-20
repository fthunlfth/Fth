import UIKit

/// Titreşim geri bildirimi. Ayarlardan kapatılabilsin diye tek noktadan geçiyor.
enum Haptics {

    static var isEnabled = true

    private static let light  = UIImpactFeedbackGenerator(style: .light)
    private static let medium = UIImpactFeedbackGenerator(style: .medium)
    private static let heavy  = UIImpactFeedbackGenerator(style: .heavy)
    private static let notice = UINotificationFeedbackGenerator()

    /// Oyun başlarken çağrılır; ilk titreşimin gecikmemesi için.
    static func prepare() {
        guard isEnabled else { return }
        light.prepare()
        medium.prepare()
        heavy.prepare()
    }

    static func pickup()    { guard isEnabled else { return }; light.impactOccurred(intensity: 0.7) }
    static func nearMiss()  { guard isEnabled else { return }; light.impactOccurred(intensity: 0.4) }
    static func jump()      { guard isEnabled else { return }; light.impactOccurred(intensity: 0.55) }
    static func land()      { guard isEnabled else { return }; medium.impactOccurred(intensity: 0.5) }
    static func tap()       { guard isEnabled else { return }; medium.impactOccurred() }
    static func hurt()      { guard isEnabled else { return }; heavy.impactOccurred(intensity: 0.8); notice.notificationOccurred(.warning) }
    static func crash()     { guard isEnabled else { return }; heavy.impactOccurred(); notice.notificationOccurred(.error) }
    static func celebrate() { guard isEnabled else { return }; notice.notificationOccurred(.success) }
}
