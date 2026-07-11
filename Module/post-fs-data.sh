#!/system/bin/sh
MODDIR=${0%/*}
RUN_LOG="$MODDIR/config/hyperoptimize-post-fs.log"
HYPEROPTIMIZE_DEBUG=0
export RUN_LOG HYPEROPTIMIZE_DEBUG
. "$MODDIR/scripts/lib.sh"

ENABLE_VULKAN=0
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

if [ "$ENABLE_VULKAN" = 1 ]; then
    setprop_value ro.hwui.use_vulkan true
    setprop_value debug.hwui.renderer skiavk
    setprop_value debug.renderengine.backend skiavkthreaded
fi
