# unity-package — `com.logihapticsunity`

Unity tarafındaki UPM paketi. Named Pipe üzerinden `logi-plugin`'e event gönderir.

**Durum:** İskelet — Faz 2.

## Kurulum (hedef)

Package Manager → `+` → Add package from git URL:

```
https://github.com/edinylcnn/LogiHapticsForUnity.git?path=/unity-package
```

## Kullanım

```csharp
LogiHapticsUnity.Trigger(HapticEvent.BoxOpen);
```

## Yapı

```
unity-package/
├── Runtime/
│   ├── IHapticService.cs
│   ├── LogiHapticsService.cs       ← Named Pipe client
│   ├── NullHapticsService.cs       ← fallback
│   ├── HapticEvent.cs              ← enum
│   └── LogiHapticsUnity.cs         ← static façade
├── Editor/
│   └── LogiHapticsUnityChecker.cs  ← test paneli
├── Samples~/
│   └── MergeGameExample/
└── package.json
```
