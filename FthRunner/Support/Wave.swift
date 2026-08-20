import CoreGraphics

/// Su yüzeyinin matematiği. Çizim, kayığın oturduğu yükseklik ve engellerin
/// yerleşimi hep buradan besleniyor — böylece hepsi aynı dalgada duruyor.
enum Wave {

    /// Dünya koordinatındaki `x` için su yüzeyinin sakin seviyeye göre yüksekliği.
    static func offset(atWorldX x: CGFloat, time: TimeInterval) -> CGFloat {
        let t = CGFloat(time)
        let first = sin(x / Tuning.waveLength * .pi * 2 + t * Tuning.waveSpeed) * Tuning.waveAmplitude
        let second = sin(x / Tuning.waveLength2 * .pi * 2 + t * Tuning.waveSpeed2) * Tuning.waveAmplitude2
        return first + second
    }

    /// Yüzeyin o noktadaki eğimi — kayığı dalgaya yatırmak için.
    static func slope(atWorldX x: CGFloat, time: TimeInterval) -> CGFloat {
        let delta: CGFloat = 6
        let ahead = offset(atWorldX: x + delta, time: time)
        let behind = offset(atWorldX: x - delta, time: time)
        return (ahead - behind) / (delta * 2)
    }
}
