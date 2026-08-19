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

    static func coin()     { guard isEnabled else { return }; light.impactOccurred(intensity: 0.7) }
    static func nearMiss() { guard isEnabled else { return }; light.impactOccurred(intensity: 0.4) }
    static func tap()      { guard isEnabled else { return }; medium.impactOccurred() }
    static func crash()    { guard isEnabled else { return }; heavy.impactOccurred(); notice.notificationOccurred(.error) }
    static func newBest()  { guard isEnabled else { return }; notice.notificationOccurred(.success) }
}
