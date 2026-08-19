# Kayık — iOS deniz kaçış oyunu

Kahverengi kâkküllü saçlı, kucağında küçük gri ayıcık tutan bir kız çocuğu,
kayığıyla akıntıda ilerliyor. Kayalar, köpek balıkları, girdaplar…

SwiftUI + SpriteKit ile yazıldı. Harici bağımlılık yok, görsel dosya yok —
kayık, kız, ayıcık ve bütün engeller kod ile çiziliyor, proje klonlar klonlamaz çalışır.

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

Ekranın **herhangi bir yerinden** parmağını sürükle; kayık parmağın hareketini takip eder
(parmağın altına zıplamaz, o yüzden kayığı elin kapatmaz).

## Engeller

| Engel | Girdiği an | Davranışı |
|---|---|---|
| **Kaya** | baştan | Sabit. Etrafında köpük halkası kırılır. |
| **Kütük** | 6. sn | Geniş ve yatay, iki sütun kaplar. Dolaşmak gerek. |
| **Denizanası** | 13. sn | Sağa sola salınır, yerini kestirmek zor. |
| **Köpek balığı** | 20. sn | Sırt yüzgeci suyun üstünde. Gezinerek koridora dalabilir. |
| **Girdap** | 26. sn | Dokunmak öldürmez — **çeker**. Yarıçapına girersen kayık merkeze kayar ve dönmeye başlar; gözüne girersen devrilirsin. |
| **Balık ağı** | 32. sn | İki şamandıra arasına gerili geniş bariyer. |

### Puanlama
| Kaynak | Puan |
|---|---|
| Mesafe | her 14 nokta için +1 |
| Deniz yıldızı | +5 |
| Kıl payı geçiş (engele 26 noktadan yakın) | +2 |

Rekor `UserDefaults` içinde saklanıyor.

## Dosya düzeni

```
FthRunner/
  App/
    FthRunnerApp.swift        # uygulama girişi
    GameView.swift            # SpriteView + arayüz katmanı
    Overlays.swift            # menü, HUD, oyun sonu ekranı
  Game/
    Tuning.swift              # >>> BÜTÜN DENGE AYARLARI BURADA <<<
    GameState.swift           # skor/rekor/faz — arayüze yansıyan durum
    GameScene.swift           # oyun döngüsü, dalga üretimi, çarpışma, efektler
    Nodes/
      BoatNode.swift          # kayık + kız + ayıcık, su izi, devrilme
      Ocean.swift             # derinlik degradesi, dalga bantları, köpük paralaksı
      StarfishNode.swift      # toplanabilir deniz yıldızı
      Obstacles/
        ObstacleNode.swift    # ortak ata + çarpışma geometrisi (daire/dikdörtgen)
        RockNode.swift
        DriftwoodNode.swift
        JellyfishNode.swift
        SharkNode.swift
        WhirlpoolNode.swift
        FishingNetNode.swift
  Support/
    Palette.swift             # renkler
    Haptics.swift             # titreşim
    TextureFactory.swift      # kod ile doku üretimi
```

## Nasıl çalışıyor

Ekran `slotCount` (5) sütuna bölünüyor. Her dalgada bitişik birkaç sütun
**koridor** olarak boş bırakılıyor, kalanlara engel yerleşiyor. Koridor zamanla
daralıyor ama bir önceki koridora göre çok uzağa kaçamıyor — yoksa yüksek hızda
geçmek imkânsız olurdu. Köpek balıkları ve denizanaları bu koridora sonradan
girebildiği için garanti güvenli yol yok, sadece adil bir başlangıç var.

Fizik motoru kullanılmıyor; hareket ve çarpışma elle hesaplanıyor
(`CollisionShape`: daire ve dikdörtgen). Bu yüzden `Tuning.swift`'te bir sayıyı
değiştirdiğinde sonuç birebir öngörülebilir oluyor.

## Ayar yapmak

Oyun hissini değiştirmek için neredeyse her zaman tek dosya yeter: `Game/Tuning.swift`.

- **Çok zor geliyor** → `speedGainPerSecond` düşür, `startFreeSlots` yükselt,
  `freeSlotsShrinkPerSecond` düşür, `slotFillChance` düşür.
- **Kayık ağır hissettiriyor** → `boatFollowSharpness` veya `dragSensitivity` yükselt.
- **Girdaplar çok zalim** → `whirlpoolPullStrength` düşür veya `whirlpoolInterval` yükselt.
- **Köpek balıkları çok saldırgan** → `sharkSwimRange` veya `sharkSwimSpeed` düşür.
- **Engeller geç geliyor** → `logUnlockTime` / `sharkUnlockTime` gibi açılış saniyelerini düşür.
- **Kıl payı bonusu çok kolay** → `nearMissDistance` düşür.

Kızın görünümü (saç, elbise, can yeleği, ayıcık) `Support/Palette.swift` renkleriyle
ve `Nodes/BoatNode.swift` içindeki `buildGirl` / `buildTeddy` / `buildHeadAndHair`
fonksiyonlarıyla değişiyor.

## Yol haritası (fikir havuzu)

- [ ] Yeni engeller: buzdağı, deniz mayını, yosun tarlası, akıntı şeridi, fırtına
- [ ] Güçlendirmeler: can yeleği kalkanı, kürek hızlandırma, ayıcık mıknatısı
- [ ] Hava/zaman döngüsü: gündüz → gün batımı → gece → fırtına
- [ ] Ses ve müzik (dalga sesi, martı, girdap uğultusu)
- [ ] Game Center skor tablosu
- [ ] Yıldızla açılan kayık ve kıyafet seçenekleri
