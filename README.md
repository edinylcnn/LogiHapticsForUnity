# LogiHapticsForUnity

> MX Master 4 (ve destekleyen Logitech cihazlar) için Unity oyunlarına
> tek adımda haptic feedback desteği veren açık kaynak araç seti.

**Durum:** Aktif geliştirme — henüz release yok.

---

## Vizyon

Bir Unity geliştiricisi şu iki adımla haptic desteğini aktive eder:

1. GitHub Releases'ten `LogiHapticsUnity_x.y.lplug4` indir → çift tıkla (Logi Options+ kurar)
2. Unity Package Manager'a `com.logihapticsunity` ekle → `LogiHapticsUnity.Trigger(HapticEvent.BoxOpen)` yaz

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

Başlangıç seti (genişletilebilir):

| Event | Waveform |
|-------|----------|
| `box_open` | sharp_collision |
| `merge` | completed |
| `rare_drop` | firework |
| `level_up` | happy_alert |
| `error` | mad |
| `unlock` | damp_state_change |
| `tap` | subtle_collision |
| `purchase` | jingle |

Kendi event'lerini eklemek için: `HapticEvent` enum'una sabit ekle, `HapticMapper`'da waveform tanımla.

---

## Kullanım (hedef API)

```csharp
// Tek satır — her yerden
LogiHapticsUnity.Trigger(HapticEvent.BoxOpen);

// Manuel DI için
IHapticService haptic = new LogiHapticsService();
haptic.Trigger(HapticEvent.Merge);
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
