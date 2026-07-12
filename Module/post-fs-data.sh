#!/system/bin/sh
MODDIR=${0%/*}
RUN_LOG="$MODDIR/config/hyperoptimize-post-fs.log"
HYPEROPTIMIZE_DEBUG=0
export RUN_LOG HYPEROPTIMIZE_DEBUG
. "$MODDIR/scripts/lib.sh"

ENABLE_VULKAN=0
ENABLE_NEAR_WIN_EXPERIMENTS=0
[ -f "$MODDIR/config/user_options" ] && . "$MODDIR/config/user_options"

# CPU-only winners accepted under the user's relaxed promotion rule.
setprop_value debug.hwui.trace_gpu_resources false
setprop_value debug.hwui.use_partial_updates true
setprop_value debug.sf.enable_transaction_tracing false

# Preserve efficient renderer defaults when a ROM explicitly overrides them.
setprop_if_present debug.hwui.skip_empty_damage true
setprop_if_present debug.hwui.use_buffer_age true
setprop_if_present debug.hwui.use_gpu_pixel_buffers true
setprop_if_present renderthread.skia.reduceopstasksplitting true

# Keep ROM-exposed tracing and verbose diagnostic controls disabled.
setprop_if_present debug.atrace.tags.enableflags 0
setprop_if_present persist.traced.enable 0
setprop_if_present persist.vendor.wifienhancelog 0
setprop_if_present persist.wpa_supplicant.debug false
setprop_if_present persist.sys.offlinelog.logcatkernel false
setprop_if_present persist.sys.offlinelog.logcat false
setprop_if_present debug.mdpcomp.logs 0
setprop_if_present persist.vendor.radio.adb_log_on 0
setprop_if_present persist.data.qmi.adb_logmask 0
setprop_if_present vendor.gralloc.enable_logs 0
setprop_if_present persist.sys.miui_scout_debug false
setprop_if_present persist.sys.perf.debug false

# Research near-wins. Disabled by default; enable only for controlled drain A/B.
if [ "$ENABLE_NEAR_WIN_EXPERIMENTS" = 1 ]; then
    # Scheduler/renderer candidates with launch or device-specific trade-offs.
    setprop_if_present persist.sys.enable_sched_gesture false
    setprop_if_present persist.sys.miui_sptm.enable false
    setprop_if_present persist.sys.miui_sptm.enable_pl_type 0
    setprop_if_present persist.sys.preload.enable false
    setprop_if_present persist.sys.prestart.proc false
    setprop_if_present persist.sys.procprophet.enable false
    setprop_if_present persist.sys.miuibooster.launch.rtmode false
    setprop_if_present persist.sys.turbosched.setstartvip.enable false
    setprop_if_present persist.sys.turbosched.local.policy_list ""
    setprop_if_present persist.sys.turbosched.enable.coreApp.optimizer false
    setprop_if_present persist.sys.activity_helper.enable false
    setprop_if_present persist.miui.extm.dm_opt.enable true
    setprop_if_present persist.miui.gpu.partition.enable false
    setprop_if_present persist.sys.mirim.enable false
    setprop_if_present persist.sys.gnss_back.opt true

    # Stability/scout/trace diagnostics; these reduce observability.
    setprop_if_present persist.debug.coresight.config ""
    setprop_if_present persist.sys.debug.enable_scout_memory_monitor false
    setprop_if_present persist.sys.debug.enable_scout_memory_resume false
    setprop_if_present persist.sys.scout_dumpbysocket false
    setprop_if_present persist.sys.stability.scout.enable false
    setprop_if_present persist.sys.stability.enable_sentinel_resource_monitor false
    setprop_if_present persist.sys.stability.nativehangII.resume false

    # Logging/debug candidates.
    setprop_if_present media.stagefright.log-uri 0
    setprop_if_present persist.bluetooth.btsnooplogmode disabled
    setprop_if_present persist.logd.logpersistd.count 1
    setprop_if_present persist.sys.log_time_gap_sec 65535
    setprop_if_present persist.vendor.camera.logstate 0
    setprop_if_present vendor.hardware.wlan.runtcpdump stop
    setprop_if_present service.offlinelog.bootloader false
    setprop_if_present sys.lmk.reportkills 0

    # Device-local VM near-win; the original value is ledger-restored on uninstall.
    write_if_writable "/proc/sys/vm/dirty_background_ratio" "6"
fi

if [ "$ENABLE_VULKAN" = 1 ]; then
    setprop_value ro.hwui.use_vulkan true
    setprop_value debug.hwui.renderer skiavk
    setprop_value debug.renderengine.backend skiavkthreaded
fi
