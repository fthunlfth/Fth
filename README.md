# Hira'nın Macerası — iOS yan kaydırmalı deniz oyunu

Hira, elinde küçük gri ayıcığı **Tedi** ile kayığında denizde ilerliyor.
Her bölümün sonunda bir hayvan kayığa katılıyor; ilki mavi gözlü beyaz
kedi **Ted**.

Yandan görünüş, tek dokunuşla zıplama, beş bölüm. SwiftUI + SpriteKit.
Harici bağımlılık yok, **hiç varlık dosyası yok** — Hira, ayıcığı, kedi, kayık
ve bütün engeller Swift içinde vektör şekillerle çiziliyor; sesler de aynı
şekilde kodla üretiliyor. Proje klonlar klonlamaz çalışır.

Açılış ekranında Hira kumsalda duruyor: elinde küçük gri ayıcığı, yanında
mavi gözlü beyaz kedisi.

## Çalıştırma

```bash
open FthRunner.xcodeproj
```

Xcode 16+ gerekiyor (proje "file system synchronized group" kullanıyor, yani
yeni Swift dosyası eklemek için `.xcodeproj`'a dokunmak gerekmiyor — dosyayı
klasöre koyman yeterli). Hedef: **iOS 17+, yatay ekran**.

İlk çalıştırmada Xcode imzalama için takım (team) isteyebilir:
**Signing & Capabilities → Team** kısmından kendi Apple ID'ni seç.

> Yatay ekran bir tercih değil zorunluluk: yan kaydırmalı bir zıplama oyununda
> dikey ekranda kayığın önünde ~340 nokta görünür, bu da saniyede 300 nokta
> akarken 1 saniyelik tepki süresi demek. Yatayda bu iki katına çıkıyor.

## Nasıl oynanıyor

Ekranın **herhangi bir yerine dokun**: kayık zıplar. **Basılı tutarsan** daha
yükseğe çıkar (Mario'daki gibi değişken zıplama). Sudan ayrıldıktan sonra kısa
bir tolerans (coyote time) ve havadayken erken basılan zıplamayı hatırlayan bir
tampon var — yani zamanlaman biraz şaşarsa oyun seni affediyor.

**İki canla başlarsın.** Çarptığında bir can gider ve kısa süre dokunulmaz
olursun; canlar bitince bölümün başına dönersin.

**10 deniz yıldızı bir can ediyor**, en fazla üç cana kadar. Göstergedeki
`★ 7/10` sıradaki cana ne kaldığını söylüyor. Canlar tavandayken sayaç yine
sıfırlanır — yıldızlar zaten tanesi +5 puan.

## Bölümler

Her bölüm **60 saniye**. `Level.duration` saniye cinsinden yazılı; uzunluk
hızla çarpılarak hesaplanıyor, yani hızı değiştirsen de bölüm aynı sürede bitiyor.

| # | Bölüm | Zaman | Yeni engeller | Ödül |
|---|---|---|---|---|
| 1 | Sabah Denizi | sabah | kaya, kütük, denizanası | **Ted** — mavi gözlü beyaz kedi |
| 2 | Martı Koyu | öğle | martı | Yavru fok |
| 3 | Gün Batımı Sığlığı | gün batımı | köpek balığı yüzgeci | Küçük penguen |
| 4 | Ay Işığı Geçidi | gece | balık ağı, girdap | Deniz kaplumbağası |
| 5 | Fırtına Burnu | fırtına | hepsi bir arada | Yavru köpek |

Her bölümün gökyüzü, deniz, bulut ve ada renkleri farklı. Bölüm sonunda küçük
bir ada var; üstündeki hayvan kayığa atlıyor ve ekranda **"Ted artık macerada!"**
şeridi beliriyor. **Mürettebat büyüdükçe kayık uzuyor.** İlerleme cihazda
saklanıyor; menüden kaldığın bölümden devam ediyorsun.

Mürettebat listesinde ayıcık **Tedi** hep başta duruyor (`Teddy.name`) —
o bir bölüm ödülü değil, yolculuğun başından beri kayıkta. Arkasından
bölüm bölüm katılan hayvanlar geliyor. Adı olan arkadaşlar `AnimalKind.name`
ile tanımlı (şimdilik sadece Ted); adı olmayanlar türüyle anılıyor.

## Engeller

| Engel | Davranışı |
|---|---|
| **Kaya** | Sudan çıkar, sabit. Üstünden zıplanır. |
| **Kütük** | Alçak ve geniş. Kolay zıplama. |
| **Köpek balığı** | Sırt yüzgeci suyu yarar ve **kayığa doğru yaklaşır** — zamanlama işi. |
| **Denizanası** | Yüzeyde süzülür; kubbesi üstte, dokungaçları altında. |
| **Balık ağı** | İki direk arası yüksek bariyer. Basılı tutarak zıplamak şart. |
| **Martı** | Tek "zıplamama" engeli: yerinde kalırsan altından geçersin, zıplarsan çarparsın. |
| **Girdap** | Alçak ama çok geniş. Kısa zıplama yetmez. |

Deniz yıldızları zıplama yayı boyunca üçlü diziliyor: hem +5 puan, hem
cana giden sayaç, hem de nereden atlaman gerektiğini gösteren bir işaret.

## Dosya düzeni

```
FthRunner/
  App/
    FthRunnerApp.swift        # uygulama girişi
    GameView.swift            # SpriteView + faz yönlendirmesi
    Overlays.swift            # menü, bölüm kartı, HUD, bölüm sonu
  Game/
    Tuning.swift              # >>> DENGE AYARLARI <<<
    Level.swift               # >>> BÖLÜMLER, GÖK TEMALARI, HAYVANLAR <<<
    GameState.swift           # skor, can, ilerleme, kayıt
    GameScene.swift           # oyun döngüsü, zıplama fiziği, üretim, çarpışma
    Nodes/
      BoatNode.swift          # kayık + Hira + ayıcık + mürettebat
      HiraNode.swift          # açılış ekranındaki ayakta duran Hira
      TitleSceneNode.swift    # kumsal + Hira + mavi gözlü beyaz kedi
      AnimalNode.swift        # kedi, fok, penguen, kaplumbağa, köpek
      SkyNode.swift           # gök, güneş/ay, yıldız, bulut, uzak ada, yağmur
      SeaNode.swift           # dalgalanan su yüzeyi, derinlik, köpük
      GoalIslandNode.swift    # bölüm sonu adası
      StarfishNode.swift      # toplanabilir deniz yıldızı
      Obstacles/
        ObstacleNode.swift    # ortak ata + çarpışma geometrisi
        RockNode.swift  DriftwoodNode.swift  SharkFinNode.swift
        JellyfishNode.swift  FishingNetNode.swift  SeagullNode.swift
        WhirlpoolNode.swift
  Support/
    Wave.swift                # su yüzeyi matematiği (tek kaynak)
    Fonts.swift               # sahne etiketleri için yuvarlak sistem fontu
    SoundEngine.swift         # AVAudioEngine hattı, ses havuzu, sessize alma
    Synth.swift               # bütün seslerin sıfırdan üretimi
    Palette.swift             # karakter ve engel renkleri
    Haptics.swift             # titreşim
    TextureFactory.swift      # kod ile doku üretimi
```

## Ses

Ses dosyası da yok. `Synth.swift` bütün efektleri örnek örnek hesaplıyor:
üçgen/sinüs/yumuşak kare dalgalar, üstel zarflar ve alçak geçiren süzgeçten
geçmiş gürültü. Rastgelelik sabit tohumlu, yani oyun her açılışta birebir
aynı sesi veriyor.

| Ses | Nasıl üretiliyor |
|---|---|
| Zıplama | 420 → 880 Hz yükselen üçgen + kısa hışırtı |
| Suya iniş | parlaktan boğuğa kapanan gürültü + tok bas vuruş |
| Deniz yıldızı | iki notalık parlak kıvılcım (C6 → G6) |
| Can kaybı | 520 → 150 Hz inen yumuşak kare + gürültü |
| Batış | inen üç nota (A4 → F4 → C4) |
| Bölüm sonu | yükselen dörtlü + uzun kapanış akoru |
| Yeni can | beşli aralıklarla yükselen üç nota, fanfardan kısa |
| Martı | iki hızlı inen cıvıltı, ara sıra duyuluyor |
| Deniz (döngü) | 8 saniyelik boğuk uğultu; salınımlar tam sayı çevrim yaptığı ve kuyruk başa karıştırıldığı için ek yeri duyulmuyor |

Sesler arka planda hesaplanıyor, açılışta takılma olmuyor. Ses oturumu
`.ambient` + `mixWithOthers`: kullanıcının müziğini kesmiyor ve telefonun
sessize alma düğmesine uyuyor. Menüdeki hoparlör düğmesi tercihi cihazda
saklıyor.

## Nasıl çalışıyor

**Su yüzeyi tek bir fonksiyondan geliyor.** `Wave.offset(atWorldX:time:)` iki
sinüsün toplamı; hem denizin çizimi, hem kayığın oturduğu yükseklik, hem de
engellerin dikey yerleşimi bu fonksiyonu kullanıyor. Bu yüzden her şey aynı
dalganın üstünde duruyor ve kayık dalganın eğimine yatıyor.

**Engeller dünya koordinatında yaşıyor.** Her karede ekran konumu kameradan
hesaplanıyor. Kamera sağa gittikçe gökyüzü katmanları (bulut 0.16, uzak ada
0.35) kendi hızlarında kayıp başa sarıyor.

**Fizik motoru yok.** Zıplama ve çarpışma elle hesaplanıyor
(`CollisionShape`: daire ve dikdörtgen). Bu yüzden `Tuning.swift`'te bir sayıyı
değiştirdiğinde sonuç birebir öngörülebilir oluyor.

## Ayar yapmak

- **Zıplama ağır/hafif** → `gravity`, `jumpImpulse`
- **Basılı tutma çok/az etkili** → `jumpHoldGravityScale`, `maxJumpHoldTime`
- **Zamanlama affetmiyor** → `coyoteTime`, `jumpBufferTime` yükselt
- **Bölüm uzun/kısa** → `Level.all` içindeki `duration` (saniye)
- **Bölüm zor/kolay** → `Level.all` içindeki `scrollSpeed` ve `gapRange`
- **Engeller çok sık** → `gapRange` aralığını genişlet
- **Çok çabuk ölüyorum** → `Tuning.startingLives` (şu an 2), `invulnerabilityTime`
- **Can kazanmak çok kolay/zor** → `Tuning.starfishPerExtraLife` (şu an 10),
  tavan için `Tuning.maxLives` (şu an 3)
- **Deniz çok/az dalgalı** → `waveAmplitude`, `waveLength`
- **Ses çok/az** → `SoundEngine.applyVolumes` içindeki iki değer
  (efektler 0.9, dalga sesi 0.30)
- **Bir sesi değiştirmek** → `Synth.swift` içinde o efektin tarifi tek fonksiyon

Hira'nın görünümü `Support/Palette.swift` renkleriyle değişiyor. Kayıktaki
hâli `BoatNode.swift` içindeki `buildOutfit` / `buildHead` / `buildDanglingLeg`
fonksiyonlarında; açılış ekranındaki ayakta duran hâli `HiraNode.swift` içinde.
Hayvanlar `AnimalNode.swift` içinde, her biri kendi `build...` fonksiyonunda.

## Yol haritası (fikir havuzu)

- [ ] Güçlendirmeler: can yeleği kalkanı, kürek hızlandırma, ayıcık mıknatısı
- [ ] Bölüm sonu canavarı (dev ahtapot?)
- [ ] Toplanan hayvanların oyun içinde işe yaraması (kedi yıldız çekiyor vb.)
- [ ] Game Center skor tablosu
- [ ] Daha fazla bölüm ve hayvan
