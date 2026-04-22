# logi-plugin

Logi Options+ plugin — Named Pipe sunucusu açar, gelen event'i Logi Actions SDK ile haptic waveform olarak MX Master 4'e tetikler.

## Gereksinimler

1. **Logi Options+** kurulu olmalı (Logi Plugin Service + `PluginApi.dll` için)
   - Win: `C:\Program Files\Logi\LogiPluginService\PluginApi.dll`
   - macOS: `/Applications/Utilities/LogiPluginService.app/Contents/MonoBundle/PluginApi.dll`
2. **.NET 8 SDK**
3. **LogiPluginTool** global aracı (paketleme için):

   ```bash
   dotnet tool install --global LogiPluginTool
   ```

## Yapı

```
logi-plugin/
├── src/
│   ├── Plugin.cs                         ← Loupedeck.Plugin entry
│   ├── Application.cs                    ← ClientApplication companion
│   ├── PipeServer.cs                     ← Named Pipe / Unix socket sunucusu
│   ├── HapticMapper.cs                   ← event → waveform eşleme
│   ├── PluginLog.cs                      ← SDK log wrapper
│   ├── LogiHapticsUnity.Plugin.csproj
│   └── package/
│       ├── metadata/
│       │   ├── LoupedeckPackage.yaml     ← manifest (plugin4, HasHapticsMapping)
│       │   └── Icon256x256.png           ← placeholder
│       └── events/
│           ├── DefaultEventSource.yaml   ← 15 waveform event'i
│           └── extra/
│               └── eventMapping.yaml    ← haptic UI kaydı (haptics block)
└── build/                                ← .lplug4 çıktıları
```

## Geliştirme

```bash
cd logi-plugin/src
dotnet build -c Release
```

Build tamamlanınca csproj otomatik olarak Logi Plugin Service'in `Plugins/` dizinine bir `.link` dosyası yazar ve `loupedeck:plugin/LogiHapticsUnity/reload` URL'sini tetikler. Logi Options+ plugin'i anında reload eder.

## Paketleme (.lplug4)

```bash
cd logi-plugin/src
dotnet build -c Release
logiplugintool pack ../bin/Release
```

Çıktı: `logi-plugin/build/LogiHapticsUnity_<version>.lplug4`. Çift tıklayarak kurulabilir.

## Nasıl Çalışır?

1. `Load()` → 15 haptic waveform'u `PluginEvents.AddEvent` ile kaydeder, Named Pipe server başlatır
2. Unity tarafından `"success"` gibi bir event adı pipe'a yazılır
3. `HapticMapper` event adını SDK waveform'una çevirir (`success → completed`)
4. `PluginEvents.RaiseEvent("completed")` → MX Master 4 haptic aktuatör tetiklenir

## Haptic UI Kaydı İçin Gerekli Meta

Logi Options+'ın **Haptic Feedback** ekranında plugin'in görünmesi için manifest ve event tarafında ikisi de olmalı:

1. `LoupedeckPackage.yaml` → `pluginCapabilities` listesinde **`HasHapticsMapping`** (plural "s") — `HasHapticMapping` tek başına yeterli değil
2. `events/extra/eventMapping.yaml` → `haptics:` block'u her waveform için `DEFAULT: <waveform>` eşlemesi içerir

Bu ikisi olmadan event'ler pipe'a düşer ama cihaz haptic tetiklemez, çünkü kullanıcı Logi Options+'dan plugin'i haptic çıkışına bağlayamaz.

## Platform Notu (macOS)

`.NET`'in `NamedPipeServerStream`'i macOS'ta `$TMPDIR/CoreFxPipe_<name>` path'inde Unix Domain Socket açar. `Dispose()` socket dosyasını silmez — plugin reload'larında yeni instance bind edemez (`IO_AllPipeInstancesAreBusy`). `PipeServer` bu durumu yakalayıp socket'ı explicit unlink edip retry yapıyor.

## Waveform Listesi

15 SDK waveform'u: `sharp_collision`, `sharp_state_change`, `knock`, `damp_collision`, `mad`, `ringing`, `subtle_collision`, `completed`, `jingle`, `damp_state_change`, `firework`, `happy_alert`, `wave`, `angry_alert`, `square`.

Unity tarafı ister `HapticEvent` enum'u kullanır (9 generic event), ister `TriggerRaw("firework")` ile doğrudan waveform adı gönderir.

SDK dokümantasyonu: https://logitech.github.io/actions-sdk-docs/
