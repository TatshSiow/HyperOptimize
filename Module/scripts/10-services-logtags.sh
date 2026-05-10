#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

####################################
# Kill and Stop Services
####################################

kill_services_once() {
    for name in $1; do
        stop "$name" 2>/dev/null
        pkill -f "$name" 2>/dev/null
    done
}

suppress_dynamic_logtags() {
    local round tag
    round=0

    while [ "$round" -lt 90 ]; do
        logcat -d -v brief 2>/dev/null \
            | sed -n 's#^[VDIWEF]/\([^(: ]*\).*#\1#p' \
            | grep -E '^(RectFSpringAnim_[0-9]+|MultiSpringDynamicAnimation[0-9a-f]+|WindowElement[0-9a-f]+|VRI\[[^]]+\]|MediaSyncManager_[0-9]+_[0-9]+|VolumePanelViewController_(true|false)|TimeTracker_[0-9]+_[0-9]+|TimeTracker_[0-9]+|NavStubViewcom\..*|TaskViewThumbnail_[0-9]+|WindowElement[0-9A-Fa-f]+)$' \
            | sort -u \
            | while read -r tag; do
                [ -n "$tag" ] && resetprop -n "log.tag.$tag" S
            done

        sleep 10
        round=$((round + 1))
    done
}

retry_kill_services() {
    local retry_round

    sleep 10
    kill_services_once "$default_services"

    retry_round=0
    while [ "$retry_round" -lt 6 ]; do
        sleep 20
        kill_services_once "$default_services"
        retry_round=$((retry_round + 1))
    done
}

# Default: logging / diagnostics / tracing suppression.
default_services="charge_logger
vendor.tcpdump
vendor.atrace-hal-1-0"

# Optional:
# incidentd
# mediametrics
# vendor.mi_misight
# vendor.diag.tcpdump
# qlogd
# qseelogd
# logcatlog
# bootlog

# Experimental:
# qadaemon
# misight
# vendor.xiaomi.hardware.misight.service

# Run service-kill retries in the background so the modular service runner can
# finish without waiting for the full retry window.
retry_kill_services &

####################################
# SHUT UP !!! LOGTAGS !!!
####################################
# Keep broad platform tags visible enough for future debugging.
# Suppress vendor/UI spam first; avoid muting core Android tags unless the
# tag is consistently useless on this device.
resetprop -n log.tag.HWComposer S
resetprop -n log.tag.HWC2On1Adapter S
resetprop -n log.tag.SDM S
resetprop -n log.tag.vendor.qti.hardware.display.composer-service S
resetprop -n log.tag.libsensor-parseRGB S
resetprop -n log.tag.SyncRtSurfaceTransactionApplierCompat S
resetprop -n log.tag.MiuiSplitInputMethodImpl S
resetprop -n log.tag.RefreshRateSelector S
resetprop -n log.tag.NavStubView S
resetprop -n log.tag.AnimStateManager S
resetprop -n log.tag.GestureStateMachine S
resetprop -n log.tag.WindowAnimImplementorDispatcher S
resetprop -n log.tag.LocalWindowAnimImplementor S
resetprop -n log.tag.MIUIInput S
resetprop -n log.tag.BroadcastQueue S
resetprop -n log.tag.BarFollowAnimation S
resetprop -n log.tag.MiuiFreeformModeSettingsObserver S
resetprop -n log.tag.MiuiFreeformModeGestureHandler S
resetprop -n log.tag.TransitionImpl S
resetprop -n log.tag.MiuiRefreshRatePolicy S
resetprop -n log.tag.MiuiDecorationBottom S
resetprop -n log.tag.MiuiDecorationDot S
resetprop -n log.tag.MiuiDecorationHomeBottom S
resetprop -n log.tag.WallpaperControllerImpl S
resetprop -n log.tag.TransitionController S
resetprop -n log.tag.TransitionChain S
resetprop -n log.tag.RTMode S
resetprop -n log.tag.vendor.xiaomi.sensor.citsensorservice@2.0-service S
resetprop -n log.tag.BT_OneTrack_I/F S
resetprop -n log.tag.cnss-daemon S
resetprop -n log.tag.WifiHAL S
resetprop -n log.tag.wificond S
resetprop -n log.tag.QESDK_SESSION_MANAGER S
resetprop -n log.tag.modemManager S
resetprop -n log.tag.vendor.qti.bluetooth@1.1-wake_lock S
resetprop -n log.tag.DeviceGuardManagerService S
resetprop -n log.tag.AmlWifiScoreReportInjector S
resetprop -n log.tag.WifiStaIfaceHidlImpl S
resetprop -n log.tag.WifiOptimizationImpl S
resetprop -n log.tag.SlaveWifiManager S
resetprop -n log.tag.ActivityManagerServiceImpl S
resetprop -n log.tag.CachedAppOptimizer S
resetprop -n log.tag.MiuiStatusIconContainer S
resetprop -n log.tag.ControlCenterHeaderExpandController S
resetprop -n log.tag.ControlCenterControllerImpl S
resetprop -n log.tag.NotificationHeaderExpandController S
resetprop -n log.tag.NotificationPanelExpandController S
resetprop -n log.tag.MiuiClockController S
resetprop -n log.tag.MiuiClockController\ Aod S
resetprop -n log.tag.msys S
resetprop -n log.tag.secondary_dns S
resetprop -n log.tag.msgr.DeviceInfoPeriodicReporter S
resetprop -n log.tag.MI-SF S
resetprop -n log.tag.SLM-SRV-SLAService S
resetprop -n log.tag.Modem_ModemEnhanceMain S
resetprop -n log.tag.Modem_MEModuleSignal S
resetprop -n log.tag.QCNEA S
resetprop -n log.tag.Qesdkenv-info S
resetprop -n log.tag.LanguageHelper S
resetprop -n log.tag.BatteryHistoryManager S
resetprop -n log.tag.ServiceDeliveryReplaceHelper S
resetprop -n log.tag.ServiceDeliveryCompat S
resetprop -n log.tag.ServiceDeliveryCapability S
resetprop -n log.tag.ServiceDeliverSystemProvider S
resetprop -n log.tag.PowerSaveService S
resetprop -n log.tag.PowerManagerService S
resetprop -n log.tag.PowerRankHelperHolder S
resetprop -n log.tag.ThermalObserver S
resetprop -n log.tag.SmartPower S
resetprop -n log.tag.AccessibilityWindowsPopulator S
resetprop -n log.tag.AppCompatLetterboxPolicy S
resetprop -n log.tag.AnimInterruptController S
resetprop -n log.tag.MultiTaskingTaskInfo S
resetprop -n log.tag.DisplayPolicyStubImpl S
resetprop -n log.tag.FileUtil S
resetprop -n log.tag.SRE S
resetprop -n log.tag.backgroundBlur S
resetprop -n log.tag.qdgralloc S
resetprop -n log.tag.MulWinSwitchEventHandler S
resetprop -n log.tag.MultiTaskingTaskRepository S
resetprop -n log.tag.MiuiDecorationRootViewHost S
resetprop -n log.tag.OneHandedController S
resetprop -n log.tag.OnLongClickAgent S
resetprop -n log.tag.VibratorManagerService S
resetprop -n log.tag.GestureStubView_Left S
resetprop -n log.tag.GestureStubView_Right S
resetprop -n log.tag.GestureBackArrowView_Left S
resetprop -n log.tag.NotificationIconContainerInject S
resetprop -n log.tag.WindowManagerShell S
resetprop -n log.tag.InputMethodManagerServiceImpl S
resetprop -n log.tag.IME-account S
resetprop -n log.tag.TaskViewThumbnail S
resetprop -n log.tag.TaskSnapshotCompatVV S
resetprop -n log.tag.MultiTaskingAnimTarget S
resetprop -n log.tag.TransitionCallback S
resetprop -n log.tag.ReflectUtils S
resetprop -n log.tag.RemoteTransitionHandlerStubImpl S
resetprop -n log.tag.miuiElementAnimation S
resetprop -n log.tag.miuiBarFollowAnimation S
resetprop -n log.tag.BlurUtils S
resetprop -n log.tag.ShadeWindowBlurController S
resetprop -n log.tag.ScanManager S
resetprop -n log.tag.ScanController S
resetprop -n log.tag.bt_shim_scanner S
resetprop -n log.tag.BluetoothAdapter S
resetprop -n log.tag.BluetoothUtils S
resetprop -n log.tag.BluetoothPluginCloud S
resetprop -n log.tag.BluetoothLeScanner S
resetprop -n log.tag.WallpaperWindowTokenImpl S
resetprop -n log.tag.TaskStubImpl S
resetprop -n log.tag.MultiTaskingFolmeControl S
resetprop -n log.tag.Aurogon S
resetprop -n log.tag.CloudControlUtil S
resetprop -n log.tag.NetworkMetricsTracker S
resetprop -n log.tag.NetworkBoostStatusManager S
resetprop -n log.tag.NetworkScheduler.Stats S
resetprop -n log.tag.ProcessManager S
resetprop -n log.tag.MagicTether S
resetprop -n log.tag.MiuiNetworkPolicy S
resetprop -n log.tag.MiuiGallery2_AiCoreSupportHelper S
resetprop -n log.tag.MiuiGallery2_AlgoProgressManager S
resetprop -n log.tag.Wth2:WeatherProvider S
resetprop -n log.tag.ITouchFeature S
resetprop -n log.tag.CrossProfileSender S
resetprop -n log.tag.BroadcastExecutor S
resetprop -n log.tag.MultiSenceManagerInternalStub S
resetprop -n log.tag.DisplayContentStubImpl S
resetprop -n log.tag.ViewRootImplStubImpl S
resetprop -n log.tag.MiuiPerfServiceClient S
resetprop -n log.tag.PerfShielderService S
resetprop -n log.tag.JavaheapMonitor S
resetprop -n log.tag.ImeTracker S
resetprop -n log.tag.Launcher S
resetprop -n log.tag.VRI S
resetprop -n log.tag.ShortcutMenuLayerElement S
resetprop -n log.tag.EventBus S
resetprop -n log.tag.OnGlobalListenerError S
resetprop -n log.tag.TaskViewsElement S
resetprop -n log.tag.RecentsImpl S
resetprop -n log.tag.NavStubView_Touch S
resetprop -n log.tag.TaskStackLayoutAlgorithm S
resetprop -n log.tag.ANDR-PERF-LM S
resetprop -n log.tag.VolumeShowHideAnimator S
resetprop -n log.tag.VolumeExpandCollapsedAnimator S
resetprop -n log.tag.SearchOverlayTransitionController S
resetprop -n log.tag.FeedOverlayTransitionController S
resetprop -n log.tag.RecentsView S
resetprop -n log.tag.ScreenView_Workspace S
resetprop -n log.tag.ActivityManagerWrapper S
resetprop -n log.tag.RecentsTaskLoader S
resetprop -n log.tag.MulWinSwitchDecorViewModel S
resetprop -n log.tag.MiuiFreeformModeController S
resetprop -n log.tag.Launcher.UserPresentAnimation S
resetprop -n log.tag.BackGestureBreakController S
resetprop -n log.tag.SfAnimApiProxy S
resetprop -n log.tag.SfAnimController S
resetprop -n log.tag.PreviewDisappear S
resetprop -n log.tag.StateManager S
resetprop -n log.tag.SwipeDetector S
resetprop -n log.tag.RecentsContainer S
resetprop -n log.tag.TaskView S
resetprop -n log.tag.TaskStackViewTouchHandler S
resetprop -n log.tag.SystemWallpaperElement S
resetprop -n log.tag.LauncherStateManager S
resetprop -n log.tag.Launcher.Workspace S
resetprop -n log.tag.Launcher.StatusBarController S
resetprop -n log.tag.GestureDispatcher S
resetprop -n log.tag.GestureObserver S
resetprop -n log.tag.DynamicIslandWindowViewController S
resetprop -n log.tag.DynamicIslandWindowViewImpl S
resetprop -n log.tag.DynamicIslandEventCoordinator S
resetprop -n log.tag.DynamicIslandEventDebug S
resetprop -n log.tag.AssistantOverlaySwipeController S
resetprop -n log.tag.FeedSwipeController S
resetprop -n log.tag.NPVCInjector S
resetprop -n log.tag.Tile.MiuiCellularTile S
resetprop -n log.tag.Launcher.Boost S
resetprop -n log.tag.ControlCenterEventHandler S
resetprop -n log.tag.MiuiBubbleController S
resetprop -n log.tag.BlurController S
resetprop -n log.tag.VsyncModulator S
resetprop -n log.tag.IPCThreadState S
resetprop -n log.tag.egip S
resetprop -n log.tag.StateNotifyUtils S
resetprop -n log.tag.IBarFollowAnimationRunnerImpl S
resetprop -n log.tag.RecentBlurViewElement S
resetprop -n log.tag.ControlCenterExpandController S
resetprop -n log.tag.ControlCenterWindowViewImpl S
resetprop -n log.tag.VolumePanelViewController_true S
resetprop -n log.tag.VolumePanelViewController_false S
resetprop -n log.tag.ControlCenterWindowViewController S
resetprop -n log.tag.ControlCenterContainerController S
resetprop -n log.tag.ControlCenterItemAnimator S
resetprop -n log.tag.RecentsModel S
resetprop -n log.tag.PowerKeeperManager S
resetprop -n log.tag.JobScheduler.SSRU S
resetprop -n log.tag.MiuiGestureDetector S
resetprop -n log.tag.FinishToAppAndWaitTaskStackChange S
resetprop -n log.tag.ScenarioRecognitionUtil S
resetprop -n log.tag.TransitionUtil S
resetprop -n log.tag.AdapterProperties S
resetprop -n log.tag.PolicyMaker S
resetprop -n log.tag.BtGatt.GattService S
resetprop -n log.tag.ActionExecute S
resetprop -n log.tag.RotationHelper S
resetprop -n log.tag.GnssSsruImpl S
resetprop -n log.tag.SettingsProvider S
resetprop -n log.tag.NetlinkEvent S
resetprop -n log.tag.MiuiBatteryServiceImpl S
resetprop -n log.tag.MiuiBatteryStatsService S
resetprop -n log.tag.BatteryStatsImpl S
resetprop -n log.tag.MiuiDecorationController S
resetprop -n log.tag.MiuiWallpaperSurfaceAnimation S
resetprop -n log.tag.LockScreenMagazinePreView S
resetprop -n log.tag.ThemeUtils S
resetprop -n log.tag.EasternArtBAodClock S
resetprop -n log.tag.MiuiFaceManager S
resetprop -n log.tag.ClockPalette S
resetprop -n log.tag.DreamService[MiuiDozeService] S
resetprop -n log.tag.InetDiagMessage S
resetprop -n log.tag.MiuiNearbyOnScanResult_Plugin S
resetprop -n log.tag.MiuiMiHomeConnectController S
resetprop -n log.tag.MiuiFastConnectService_Plugin S
resetprop -n log.tag.MiuiConfigNetConnectController S
resetprop -n log.tag.MiuiBluetoothUtil_Plugin S
resetprop -n log.tag.DeviceNickName_Plugin S
resetprop -n log.tag.MiuiDataControllerImpl[0] S
resetprop -n log.tag.MiuiDataServiceManagerImpl[0] S
resetprop -n log.tag.PhoneAdapter S
resetprop -n log.tag.Phone-0 S
resetprop -n log.tag.RequestManager S
resetprop -n log.tag.qcrilNrd S
resetprop -n log.tag.Phone-1 S
resetprop -n log.tag.NetworkTypeController S
resetprop -n log.tag.QtiGsmCdmaPhone S
resetprop -n log.tag.QtiDSMGR-0 S
resetprop -n log.tag.QtiDSMGR-1 S
resetprop -n log.tag.RILJ S
resetprop -n log.tag.RILUtils S
resetprop -n log.tag.SST S
resetprop -n log.tag.DNC-0 S
resetprop -n log.tag.DNC-1 S
resetprop -n log.tag.DIC-1 S
resetprop -n log.tag.DN-103-C S
resetprop -n log.tag.DN-102-C S
resetprop -n log.tag.QOSCT-103 S
resetprop -n log.tag.QOSCT-102 S
resetprop -n log.tag.NitzStateMachineImpl S
resetprop -n log.tag.LocaleTracker-0 S
resetprop -n log.tag.DPM-0 S
resetprop -n log.tag.MiuiNetworkControllerImpl S
resetprop -n log.tag.MiuiNetworkControllerImpl[0] S
resetprop -n log.tag.PhoneReceiver S
resetprop -n log.tag.NRM-I-0 S
resetprop -n log.tag.NRM-C-0 S
resetprop -n log.tag.RILC S
resetprop -n log.tag.MiuiCellSignalStrength S
resetprop -n log.tag.GSSTInjector S
resetprop -n log.tag.ServiceProvider S
resetprop -n log.tag.RoamingUtils S
resetprop -n log.tag.PAL S
resetprop -n log.tag.AGM S
resetprop -n log.tag.AHAL S
resetprop -n log.tag.View S
resetprop -n persist.log.tag.misight S
resetprop -n log.tag.AF::MmapTrack S
resetprop -n log.tag.AF::OutputTrack S
resetprop -n log.tag.AF::PatchRecord S
resetprop -n log.tag.AF::PatchTrack S
resetprop -n log.tag.AF::RecordHandle S
resetprop -n log.tag.AF::RecordTrack S
resetprop -n log.tag.AF::Track S
resetprop -n log.tag.AF::TrackBase S
resetprop -n log.tag.AF::TrackHandle S
resetprop -n log.tag.APM::AudioCollections S
resetprop -n log.tag.APM::AudioInputDescriptor S
resetprop -n log.tag.APM::AudioOutputDescriptor S
resetprop -n log.tag.APM::AudioPatch S
resetprop -n log.tag.APM::AudioPolicyEngine S
resetprop -n log.tag.APM::AudioPolicyEngine::Base S
resetprop -n log.tag.APM::AudioPolicyEngine::Config S
resetprop -n log.tag.APM::AudioPolicyEngine::ProductStrategy S
resetprop -n log.tag.APM::AudioPolicyEngine::VolumeGroup S
resetprop -n log.tag.APM::Devices S
resetprop -n log.tag.APM::IOProfile S
resetprop -n log.tag.APM::Serializer S
resetprop -n log.tag.APM::VolumeCurve S
resetprop -n log.tag.APM_AudioPolicyManager S
resetprop -n log.tag.APM_ClientDescriptor S
resetprop -n log.tag.AudioAttributes S
resetprop -n log.tag.AudioEffect S
resetprop -n log.tag.AudioFlinger S
resetprop -n log.tag.AudioFlinger::DeviceEffectProxy S
resetprop -n log.tag.AudioFlinger::DeviceEffectProxy::ProxyCallback S
resetprop -n log.tag.AudioFlinger::EffectBase S
resetprop -n log.tag.AudioFlinger::EffectChain S
resetprop -n log.tag.AudioFlinger::EffectHandle S
resetprop -n log.tag.AudioFlinger::EffectModule S
resetprop -n log.tag.AudioFlingerImpl S
resetprop -n log.tag.AudioFlinger_Threads S
resetprop -n log.tag.AudioHwDevice S
resetprop -n log.tag.AudioPolicy S
resetprop -n log.tag.AudioPolicyEffects S
resetprop -n log.tag.AudioPolicyIntefaceImpl S
resetprop -n log.tag.AudioPolicyManagerImpl S
resetprop -n log.tag.AudioPolicyService S
resetprop -n log.tag.AudioProductStrategy S
resetprop -n log.tag.AudioRecord S
resetprop -n log.tag.AudioSystem S
resetprop -n log.tag.AudioTrack S
resetprop -n log.tag.AudioTrackImpl S
resetprop -n log.tag.AudioTrackShared S
resetprop -n log.tag.AudioVolumeGroup S
resetprop -n log.tag.FastCapture S
resetprop -n log.tag.FastMixer S
resetprop -n log.tag.FastMixerState S
resetprop -n log.tag.FastThread S
resetprop -n log.tag.IAudioFlinger S
resetprop -n log.tag.ToneGenerator S

# Current-boot dynamic MIUI Home animation tags seen in logs; optional and may
# change across boots, so they are not enabled by default.
# resetprop -n log.tag.RectFSpringAnim_58783152 S
# resetprop -n log.tag.MultiSpringDynamicAnimationee46c29 S
# resetprop -n log.tag.WindowElementecbbae S

# MIUI Home uses per-boot dynamic suffixes for several animation tags.
# Sweep the recent log buffer for a few minutes after boot and suppress the
# current-boot names automatically.
suppress_dynamic_logtags &

exit 0
