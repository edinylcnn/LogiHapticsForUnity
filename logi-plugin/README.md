# logi-plugin

Logi Options+ plugin — Named Pipe sunucusu açar, gelen event'i Logi Actions SDK ile haptic waveform'a çevirir.

**Durum:** İskelet — Faz 1.

## Yapı

```
logi-plugin/
├── src/
│   ├── Plugin.cs          ← Logi Actions SDK entry point
│   ├── PipeServer.cs      ← Named Pipe sunucusu
│   └── HapticMapper.cs    ← event → waveform eşleme
├── manifest/
│   ├── loupedeckPackage.yaml
│   └── icon256x256.png
└── build/
    └── LogiHapticsUnity_x.y.lplug4
```

## Build

TBD — Logi Actions SDK C# template kurulduktan sonra.

Referans: https://logitech.github.io/actions-sdk-docs/
