# LogiHapticsForUnity

> MX Master 4 (ve destekleyen Logitech cihazlar) için Unity oyunlarına
> tek adımda haptic feedback desteği veren açık kaynak araç seti.

**Durum:** Aktif geliştirme — henüz release yok.

---

## Vizyon

Bir Unity geliştiricisi şu iki adımla haptic desteğini aktive eder:

1. GitHub Releases'ten `LogiHapticsUnity_x.y.lplug4` indir → çift tıkla (Logi Options+ kurar)
2. Unity Package Manager'a `com.logihapticsunity` ekle → `LogiHapticsUnity.Trigger(HapticEvent.Click)` yaz

Firewall onayı yok. Domain yok. Sertifika yok. Port ayarı yok.

---

## Mimari

```
Unity Oyunu
    │
    │  Named Pipe  →  LogiHapticsUnity  (Windows: \\.\pipe\LogiHapticsUnity)
    ▼                                   (macOS:   /tmp/logihapticsunity)
LogiHapticsUnity Plugin  (Logi Options+ içinde — .lplug4)
    │
    │  Logi Actions SDK haptic API
    ▼
MX Master 4 — haptic aktuatör
```

İki bileşenli bir monorepo:

| Klasör | İçerik | Dağıtım |
|---|---|---|
| [`logi-plugin/`](logi-plugin/) | Logi Options+ plugin (C#, Logi Actions SDK) | `.lplug4` — GitHub Releases |
| [`unity-package/`](unity-package/) | Unity Package (UPM) — `com.logihapticsunity` | Git URL / OpenUPM |

---

## Desteklenen Haptic Event'ler

Tür bağımsız, her oyunda kullanılabilecek genel amaçlı başlangıç seti (genişletilebilir):

| Event | Waveform | Tipik Kullanım |
|-------|----------|----------------|
| `Click` | subtle_collision | UI etkileşimi, buton, menü |
| `Confirm` | jingle | Onay, satın alma, kaydet |
| `Success` | completed | Başarılı işlem, görev tamamlama |
| `Failure` | mad | Hatalı aksiyon, yanlış giriş |
| `Warning` | damp_state_change | Uyarı, kritik eşik |
| `Notification` | happy_alert | Mesaj, bildirim, ipucu |
| `Achievement` | firework | Ödül, seviye atlama, nadir olay |
| `ImpactLight` | subtle_collision | Hafif temas, küçük etki |
| `ImpactMedium` | sharp_collision | Standart darbe, çarpışma |

Kendi event'lerini eklemek için: `HapticEvent` enum'una sabit ekle, `HapticMapper`'da waveform tanımla.

---

## Kullanım (hedef API)

```csharp
// Tek satır — her yerden
LogiHapticsUnity.Trigger(HapticEvent.Click);

// Manuel DI için
IHapticService haptic = new LogiHapticsService();
haptic.Trigger(HapticEvent.Success);
```

Plugin kurulu değilse `NullHapticsService`'e düşer — oyun normal şekilde çalışır, hata fırlatmaz.

---

## Yol Haritası

- [ ] **Faz 1 — Logi Plugin İskeleti:** Logi Actions SDK, Named Pipe server, event → waveform mapping, `.lplug4` build
- [ ] **Faz 2 — Unity Package:** `HapticEvent` enum, Named Pipe client, static façade, Editor test paneli, Samples
- [ ] **Faz 3 — Paketleme & Dağıtım:** GitHub Actions release otomasyonu, OpenUPM kaydı
- [ ] **Faz 4 — Dokümantasyon:** Kurulum gif'i, desteklenen cihaz listesi, event/waveform ekleme rehberi

Detaylı plan: `LogiHapticsForUnity-Plan.md` (repo dışında tutuluyor).

---

## Cihaz Uyumluluğu

- **İlk hedef:** MX Master 4
- **Sonraki sürümler:** Logi Actions SDK destekliyorsa MX Master 3S, MX Anywhere 3

---

## Lisans

MIT — detay için `LICENSE`.
