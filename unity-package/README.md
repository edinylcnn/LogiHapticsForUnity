# unity-package — `com.logihapticsunity`

Unity tarafındaki UPM paketi. Windows'ta Named Pipe, macOS/Linux'ta Unix Domain Socket üzerinden [`logi-plugin`](../logi-plugin)'e event gönderir.

**Durum:** Çalışır — gerçek MX Master 4 cihazında doğrulandı.

## Kurulum

Unity Package Manager → `+` → **Add package from git URL**:

```
https://github.com/edinylcnn/LogiHapticsForUnity.git?path=/unity-package
```

## Kullanım

```csharp
using LogiHaptics;

// Tek satır
LogiHapticsUnity.Trigger(HapticEvent.Click);

// Ham waveform adı (15 SDK waveform'undan biri)
LogiHapticsUnity.TriggerRaw("firework");

// Manuel DI için
IHapticService haptic = new LogiHapticsService();
haptic.Trigger(HapticEvent.Success);
```

`LogiHapticsUnity.IsAvailable` ile plugin kurulu mu diye kontrol edebilirsin — `false` ise kullanıcıya kurulum linki göster.

## Editor Test Paneli

Menü: **Window → LogiHaptics → Test Panel**

- Pipe bağlantı durumu + Last error
- Temp path gösterimi
- Her event için tetik butonu

Plugin kurulu değilse `Could not connect — ...` hatası burada görünür.

## Yapı

```
unity-package/
├── Runtime/
│   ├── IHapticService.cs
│   ├── HapticEvent.cs                ← 9 generic event enum'u
│   ├── LogiHapticsService.cs         ← Pipe (Windows) / Unix Socket (mac/linux) client
│   ├── NullHapticsService.cs         ← fallback
│   ├── LogiHapticsUnity.cs           ← static façade
│   └── LogiHaptics.Runtime.asmdef
├── Editor/
│   ├── LogiHapticsUnityChecker.cs    ← test paneli
│   └── LogiHaptics.Editor.asmdef
├── Samples~/
│   └── BasicUsage/                   ← 1-5 tuşlarıyla event demo
└── package.json
```

## Desteklenen Event'ler

| Event | Waveform |
|---|---|
| `Click` | subtle_collision |
| `Confirm` | jingle |
| `Success` | completed |
| `Failure` | mad |
| `Warning` | damp_state_change |
| `Notification` | happy_alert |
| `Achievement` | firework |
| `ImpactLight` | subtle_collision |
| `ImpactMedium` | sharp_collision |

Ham waveform olarak gönderilebilecek 15 SDK waveform'u: `sharp_collision`, `sharp_state_change`, `knock`, `damp_collision`, `mad`, `ringing`, `subtle_collision`, `completed`, `jingle`, `damp_state_change`, `firework`, `happy_alert`, `wave`, `angry_alert`, `square`.

## Platform Matrisi

| Platform | Haptic |
|---|:-:|
| Windows Standalone + Editor | ✅ |
| macOS Standalone + Editor | ✅ |
| Linux Standalone + Editor | ✅ |
| iOS / Android / WebGL / Console | ➖ (sessiz fallback) |

Runtime asmdef `noEngineReferences: true` — saf .NET, hem Mono hem IL2CPP'te derlenir.
