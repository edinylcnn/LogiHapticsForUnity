namespace Loupedeck.LogiHapticsUnityPlugin
{
    using System;

    public class LogiHapticsUnityApplication : ClientApplication
    {
        protected override String GetProcessName() => "";
        protected override String GetBundleName() => "";
        public override ClientApplicationStatus GetApplicationStatus() => ClientApplicationStatus.Unknown;
    }
}
