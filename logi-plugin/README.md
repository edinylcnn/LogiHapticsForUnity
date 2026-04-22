# logi-plugin

[English](README.md) · [Türkçe](README.tr.md)

Logi Options+ plugin — opens a pipe server, forwards events to Logi Actions SDK haptic waveforms on the MX Master 4.

## Requirements

1. **Logi Options+** installed (provides the Logi Plugin Service + `PluginApi.dll`)
   - Windows: `C:\Program Files\Logi\LogiPluginService\PluginApi.dll`
   - macOS: `/Applications/Utilities/LogiPluginService.app/Contents/MonoBundle/PluginApi.dll`
2. **.NET 8 SDK**
3. **LogiPluginTool** global .NET tool (for packaging):

   ```bash
   dotnet tool install --global LogiPluginTool
   ```

## Layout

```
logi-plugin/
├── src/
│   ├── Plugin.cs                         ← Loupedeck.Plugin entry
│   ├── Application.cs                    ← ClientApplication companion
│   ├── PipeServer.cs                     ← Named Pipe / Unix socket server
│   ├── HapticMapper.cs                   ← event → waveform mapping
│   ├── PluginLog.cs                      ← SDK log wrapper
│   ├── LogiHapticsUnity.Plugin.csproj
│   └── package/
│       ├── metadata/
│       │   ├── LoupedeckPackage.yaml     ← manifest (plugin4, HasHapticsMapping)
│       │   └── Icon256x256.png           ← placeholder
│       └── events/
│           ├── DefaultEventSource.yaml   ← 15 waveform events
│           └── extra/
│               └── eventMapping.yaml     ← haptic UI registration (haptics block)
└── build/                                ← .lplug4 output
```

## Development

```bash
cd logi-plugin/src
dotnet build -c Release
```

The csproj automatically writes a `.link` file into the Logi Plugin Service's `Plugins/` directory and triggers `loupedeck:plugin/LogiHapticsUnity/reload`, so Logi Options+ hot-reloads the plugin.

## Packaging (.lplug4)

```bash
cd logi-plugin/src
dotnet build -c Release
logiplugintool pack ../bin/Release ../build/LogiHapticsUnity_0.0.1.lplug4
```

Output: `logi-plugin/build/LogiHapticsUnity_<version>.lplug4` — double-clickable installer.

## Releasing

`PluginApi.dll` ships with Logi Options+, so it cannot be fetched in CI. Releases are cut locally from the repo root:

```bash
./scripts/release-plugin.sh 0.1.0
```

The script:
1. Syncs the manifest version and pushes the commit
2. Runs `dotnet build -c Release`
3. Packs the `.lplug4`
4. Creates and pushes `plugin-v<version>` tag
5. Creates a GitHub Release with the `.lplug4` attached as an asset

Requirements: `dotnet`, `logiplugintool`, `gh` (GitHub CLI), a clean working tree.

## How it works

1. `Load()` registers the 15 haptic waveforms via `PluginEvents.AddEvent` and starts the pipe server.
2. The Unity client writes an event name (e.g. `"success"`) to the pipe.
3. `HapticMapper` resolves it to an SDK waveform (e.g. `success → completed`).
4. `PluginEvents.RaiseEvent("completed")` fires the haptic pulse on the MX Master 4.

## Haptic UI registration

Two files must line up or Logi Options+ will not show the plugin on its **Haptic Feedback** screen:

1. `LoupedeckPackage.yaml` → `pluginCapabilities` must include **`HasHapticsMapping`** (note the plural "s"). `HasHapticMapping` alone is not enough.
2. `events/extra/eventMapping.yaml` → a `haptics:` block with `DEFAULT: <waveform>` for every waveform the plugin registers.

Without both, events still flow through the pipe but the mouse never vibrates, because the user has no way to enable them in Logi Options+.

## macOS note

`.NET`'s `NamedPipeServerStream` opens a Unix Domain Socket at `$TMPDIR/CoreFxPipe_<name>` on macOS. `Dispose()` does not remove the socket file, which blocks the next plugin instance from binding (`IO_AllPipeInstancesAreBusy`). `PipeServer` catches that error, unlinks the socket explicitly, and retries.

## Waveforms

15 SDK waveforms: `sharp_collision`, `sharp_state_change`, `knock`, `damp_collision`, `mad`, `ringing`, `subtle_collision`, `completed`, `jingle`, `damp_state_change`, `firework`, `happy_alert`, `wave`, `angry_alert`, `square`.

The Unity side can use the `HapticEvent` enum (9 generic events) or `TriggerRaw("firework")` to send a waveform name directly.

SDK docs: https://logitech.github.io/actions-sdk-docs/
