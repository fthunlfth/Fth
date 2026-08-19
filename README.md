# Kaçış — iOS endless dodge

SwiftUI + SpriteKit ile yazılmış, sonsuz kaçış oyunu. Harici bağımlılık yok,
görsel dosya yok — bütün grafikler kod ile üretiliyor, proje klonlar klonlamaz çalışır.

## Çalıştırma

```bash
open FthRunner.xcodeproj
```

Xcode 16+ gerekiyor (proje "file system synchronized group" kullanıyor, yani
yeni Swift dosyası eklemek için `.xcodeproj`'a dokunmak gerekmiyor — dosyayı
klasöre koyman yeterli). Hedef: iOS 17+, sadece dikey mod.

İlk çalıştırmada Xcode imzalama için takım (team) isteyebilir:
**Signing & Capabilities → Team** kısmından kendi Apple ID'ni seç.

## Nasıl oynanıyor

- Ekranın **herhangi bir yerinden** parmağını sürükle; gemi parmağın hareketini takip eder
  (parmağın altına zıplamaz, o yüzden gemiyi elin kapatmaz).
- Kırmızı duvarlardaki geçitlerden geç.
- Zaman geçtikçe hız artar, geçitler daralır, 22. saniyeden sonra çift geçitli sıralar gelir.

### Puanlama
| Kaynak | Puan |
|---|---|
| Mesafe | her 14 nokta için +1 |
| Altın | +5 |
| Kıl payı geçiş (duvar kenarına 24 noktadan yakın) | +2 |

Rekor `UserDefaults` içinde saklanıyor.

## Dosya düzeni

```
FthRunner/
  App/
    FthRunnerApp.swift     # uygulama girişi
    GameView.swift         # SpriteView + arayüz katmanı
    Overlays.swift         # menü, HUD, oyun sonu ekranı
  Game/
    Tuning.swift           # >>> BÜTÜN DENGE AYARLARI BURADA <<<
    GameState.swift        # skor/rekor/faz — arayüze yansıyan durum
    GameScene.swift        # oyun döngüsü, üretim, çarpışma, efektler
    Nodes/
      PlayerNode.swift     # gemi, iz, patlama
      WallRow.swift        # geçitli duvar sırası
      CoinNode.swift       # toplanabilir altın
      Starfield.swift      # paralaks arka plan
  Support/
    Palette.swift          # renkler
    Haptics.swift          # titreşim
    TextureFactory.swift   # kod ile doku üretimi
```

## Ayar yapmak

Oyun hissini değiştirmek için neredeyse her zaman tek dosya yeter: `Game/Tuning.swift`.

- **Çok zor geliyor** → `speedGainPerSecond` düşür, `startGapRatio` / `minGapRatio` yükselt,
  `spawnIntervalDecayPerSecond` düşür.
- **Gemi ağır hissettiriyor** → `playerFollowSharpness` veya `dragSensitivity` yükselt.
- **Çok çabuk sıkıcılaşıyor** → `doubleGapAfterSeconds` düşür, `doubleGapChance` yükselt.
- **Kıl payı bonusu çok kolay** → `nearMissDistance` düşür.

Çarpışma ve hareket fizik motoruyla değil elle hesaplanıyor; bu yüzden bu sayıları
değiştirdiğinde sonuç birebir öngörülebilir oluyor.

## Yol haritası (fikir havuzu)

- [ ] Güçlendirmeler: kalkan, yavaşlatma, mıknatıs
- [ ] Farklı duvar desenleri (zikzak, hareketli duvar, daralan koridor)
- [ ] Ses ve müzik
- [ ] Game Center skor tablosu
- [ ] Gemi seçimi / altınla açılan kaplamalar
- [ ] Günlük görev
