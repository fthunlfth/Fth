# Oyunu başkasına nasıl gönderirim

Üç gerçekçi yol var. Hangisinin sana uyduğu, karşı tarafın kim olduğuna ve
99 dolarlık Apple geliştirici üyeliğini alıp almadığına bağlı.

> **Önce şunu yap:** Proje bu ortamda hiç derlenmedi. Kimseye göndermeden önce
> Xcode'da bir kez aç, kendi telefonunda çalıştır ve baştan sona bir bölüm oyna.

---

## Yol 1 — TestFlight (önerilen)

Apple'ın resmî beta dağıtım kanalı. Karşı taraf App Store'dan **TestFlight**
uygulamasını indirir, senin gönderdiğin bağlantıya tıklar, oyun kurulur.
Kablo yok, bilgisayar yok.

**Gereken:** [Apple Developer Program](https://developer.apple.com/programs/)
üyeliği — yılda 99 $.

### Adımlar

1. **Bundle ID'yi kendine ait bir şeye çevir.**
   Şu an `com.fth.fthrunner`. App Store Connect'te benzersiz olmak zorunda.
   Xcode → hedefi seç → *Signing & Capabilities* → **Bundle Identifier**,
   örneğin `com.fatihunal.hiraninmacerasi`.

2. **İmzalama.** Aynı sekmede *Automatically manage signing* işaretli olsun,
   **Team** olarak geliştirici hesabını seç.

3. **App Store Connect'te uygulamayı oluştur.**
   [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → *Apps* → **+**
   → *New App*. Platform iOS, ad "Hira'nın Macerası", birincil dil Türkçe,
   Bundle ID az önce yazdığın, SKU serbest (örn. `hira-001`).

4. **Arşivle.** Xcode'da üst çubuktan cihaz olarak **Any iOS Device (arm64)**
   seç (simülatör değil!) → *Product* → **Archive**.

5. **Yükle.** Arşiv bitince Organizer açılır → **Distribute App** →
   *App Store Connect* → *Upload*. Birkaç dakika sürer.

6. **Bekle.** Build "Processing" durumundan çıkması 10–30 dakika alır.
   Hazır olunca App Store Connect'te *TestFlight* sekmesinde görünür.

7. **Test grubunu seç:**

   | | Kişi sayısı | Apple incelemesi | Ne kadar sürer |
   |---|---|---|---|
   | **Internal Testing** | 100'e kadar, hesabına eklediğin kişiler | Yok | Anında |
   | **External Testing** | 10.000'e kadar, e-posta veya genel bağlantı | İlk build için Beta App Review | 1–2 gün |

   Aile/arkadaş için **Internal** yeterli ve anında: App Store Connect →
   *Users and Access* → kişiyi e-postasıyla ekle → TestFlight'ta iç gruba al.

   Tanımadığın kişilere de göndereceksen **External** kur ve **public link**
   üret; tek bağlantıyı herkese yollarsın.

8. **Karşı taraf:** App Store'dan TestFlight'ı indirir → senin bağlantına
   tıklar → *Accept* → *Install*.

### Bilmen gerekenler

- Her build **90 gün** sonra sona erer, sonra yeni build yüklemen gerekir.
- Her yüklemede **build numarasını artır** (`CURRENT_PROJECT_VERSION`),
  yoksa App Store Connect reddeder.
- Cihaz **iOS 17 veya üstü** olmalı. Daha eskiye inmek istersen
  `IPHONEOS_DEPLOYMENT_TARGET` değerini düşür (SpriteKit ve SwiftUI kodu
  iOS 16'da da çalışır, `FlowRow` için iOS 16 gerekiyor).

---

## Yol 2 — Ad Hoc `.ipa`

Yine 99 $ üyelik ister, ama TestFlight'tan zahmetli. Karşı tarafın cihaz
**UDID**'sini alıp geliştirici hesabına kaydedersin (yılda 100 cihaz),
Xcode'dan *Distribute App → Release Testing* ile `.ipa` çıkarırsın, dosyayı
Apple Configurator veya benzeri bir araçla kurdurursun.

TestFlight varken bunu tercih etmen için bir sebep yok.

---

## Yol 3 — Ücretsiz Apple ID ile kendi kurması

Üyelik gerekmez, ama karşı tarafın **Mac + Xcode**'u olmalı: depoyu klonlar,
telefonunu kabloyla bağlar, kendi Apple ID'siyle imzalayıp çalıştırır.

Kısıt: uygulama **7 gün** sonra açılmaz, yeniden kurulması gerekir.
Sadece teknik biriyse mantıklı.

---

## Yol 4 — App Store

Tam inceleme süreci. Çocuklara yönelik uygulamalarda yaş derecelendirmesi ve
gizlilik beyanları ek dikkat ister. Tek kişiye oynatmak için gereksiz;
oyunu gerçekten yayımlamak istediğinde konuşulur.

---

## Göndermeden önce kontrol listesi

- [ ] **Xcode'da derleyip cihazda bir bölüm oyna** — proje hiç derlenmedi
- [x] Uygulama simgesi var (`FthRunner/Assets.xcassets/AppIcon.appiconset/AppIcon.png`)
- [x] Şifreleme beyanı yapıldı (`ITSAppUsesNonExemptEncryption = NO`), böylece
      her yüklemede aynı soru sorulmaz
- [ ] Bundle ID kendine ait
- [ ] `MARKETING_VERSION` ve `CURRENT_PROJECT_VERSION` doğru
- [ ] Yatay ekranda açılıyor, dikeye dönmüyor

App Store Connect gizlilik bölümünde **"Data Not Collected"** işaretle:
oyun hiçbir veri toplamıyor, ağa çıkmıyor. Tek sakladığı şey cihazın kendi
`UserDefaults` alanındaki rekor ve bölüm ilerlemesi.

---

## Simgeyi değiştirmek

Simge `Tools/make_icon.py` ile üretiliyor — saf Python, harici kütüphane yok:

```bash
python3 Tools/make_icon.py FthRunner/Assets.xcassets/AppIcon.appiconset/AppIcon.png
```

Kendi çizdiğin 1024×1024 PNG'yi de aynı yere koyabilirsin.
**Alfa kanalı olmasın** — App Store saydamlıklı simge kabul etmiyor.
