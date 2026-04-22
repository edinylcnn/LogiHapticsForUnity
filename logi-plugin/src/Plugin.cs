namespace Loupedeck.LogiHapticsUnityPlugin
{
    using System;
    using System.Threading.Tasks;

    public class LogiHapticsUnityPlugin : Plugin
    {
        public override Boolean UsesApplicationApiOnly => true;
        public override Boolean HasNoApplication => true;

        PipeServer _pipe;

        public LogiHapticsUnityPlugin()
        {
            PluginLog.Init(this.Log);
            PluginResources.Init(this.Assembly);
        }

        public override void Load()
        {
            RegisterHapticEvents();
            _pipe = new PipeServer(HandleEvent);
            _pipe.Start();
            PluginLog.Info($"LogiHapticsUnity pipe server listening on '{PipeServer.PipeName}'");
            this.OnPluginStatusChanged(Loupedeck.PluginStatus.Normal, null);
        }

        public override void Unload()
        {
            _pipe?.Dispose();
            _pipe = null;
        }

        void RegisterHapticEvents()
        {
            // Logi Options+ requires each haptic waveform to be registered as a plugin event.
            foreach (var waveform in HapticMapper.Waveforms)
            {
                this.PluginEvents.AddEvent(waveform, waveform, null);
            }
        }

        void HandleEvent(string eventName)
        {
            if (!HapticMapper.TryGetWaveform(eventName, out var waveform))
            {
                PluginLog.Warning($"unknown event from pipe: {eventName}");
                return;
            }

            // RaiseEvent drives the actual haptic pulse on the paired device (MX Master 4).
            Task.Run(() =>
            {
                try { this.PluginEvents.RaiseEvent(waveform); }
                catch (Exception ex) { PluginLog.Error(ex, $"haptic raise failed: {waveform}"); }
            });
        }
    }
}
