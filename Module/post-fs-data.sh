#!/system/bin/sh
MODDIR=${0%/*}

load_user_options() {
    ENABLE_VULKAN=0
    [ -f "$MODDIR/config/user_options" ] && . "$MODDIR/config/user_options"
}

# No post-fs property produced a confirmed multi-metric power/CPU win on this
# device. Preserve the explicit user Vulkan option, but do not force GL when
# Vulkan is disabled; the stock renderer choice performed better than forced GL.
load_user_options
if [ "$ENABLE_VULKAN" = 1 ]; then
    resetprop ro.hwui.use_vulkan true
    resetprop debug.hwui.renderer skiavk
    resetprop debug.renderengine.backend skiavkthreaded
fi

# Five-round CoreSight confirmation rejected the initial noisy result.
# resetprop persist.debug.coresight.config ""

# Already enabled on this device, but not safely A/B tested with audio playback.
# resetprop vendor.qc2audio.suspend.enabled true

# Feature support rather than an optimization.
# resetprop persist.vendor.qcom.bluetooth.aptxadaptiver2_2_support true

# Live A/B tests found no reliable wins; most are service-start/reboot scoped.
# resetprop persist.sys.qseelogd false
# resetprop persist.vendor.ssr.enable_ramdumps 0
# resetprop persist.sys.debug.app.mtbf_test false
# resetprop persist.sys.miui_sptm.enable_pl_type 0
# resetprop persist.sys.stability.nativehangII.enable false
# resetprop persist.sys.stability.nativehangII.resume false
# resetprop persist.sys.miui_scout_binder_full_kill_process false
# resetprop persist.sys.scout_binder_gki false
# resetprop persist.sys.stability.scout.enable false
# resetprop persist.sys.stability.scout.check_frozen false
# resetprop persist.mm.enable.prefetch false
# resetprop persist.sys.trim_rendernode.enable true

# Absent/already-disabled logging and crash properties do not need reassertion.
exit 0
