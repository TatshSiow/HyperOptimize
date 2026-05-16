#!/system/bin/sh
MODDIR=${0%/*}

set_hwui_pipeline() {
    local renderer="$1"

    case "$renderer" in
        skiavk)
            # HWUI explicitly recognizes debug.hwui.renderer, while ro.hwui.use_vulkan
            # is used as the default when the renderer property is absent.
            resetprop ro.hwui.use_vulkan true
            resetprop debug.hwui.renderer skiavk

            # RenderEngine exposes a separate backend property. We keep it aligned
            # with HWUI so Xiaomi builds do not mix GL and Vulkan paths.
            resetprop debug.renderengine.backend skiavkthreaded
            ;;
        *)
            resetprop ro.hwui.use_vulkan false
            resetprop debug.hwui.renderer skiagl
            resetprop debug.renderengine.backend skiaglthreaded
            ;;
    esac
}

load_user_options() {
    ENABLE_VULKAN=0

    if [ -f "$MODDIR/config/user_options" ]; then
        . "$MODDIR/config/user_options"
    fi
}

####################################
# Additional Props Config
####################################

# SoC Config
if [ "$(getprop ro.hardware)" = "qcom" ]; then

    # Qualcomm stm events
    resetprop persist.debug.coresight.config ""

    # Qualcomm WCD (audio) driver power optimization
    resetprop vendor.qc2audio.suspend.enabled true

    # Enable APTX Adaptive 2.2 Support (only for 8gen1 or higher)
    # Credit : The Voyager
    resetprop persist.vendor.qcom.bluetooth.aptxadaptiver2_2_support true

    resetprop persist.debug.trace 0
    resetprop persist.logd.diag.tcpdump false
    resetprop persist.logd.diag.bootup false
    resetprop persist.logd.diag.networklog false
    resetprop persist.logd.diag.mobilelog false
    resetprop persist.logd.diag.newlocation false
    resetprop persist.sys.qlogd 0
    resetprop vendor.bluetooth.startbtlogger false
    resetprop persist.vendor.sys.rawdump_copy 0
    resetprop persist.sys.qseelogd false
    resetprop persist.sys.ssr.enable_debug 0
    resetprop persist.vendor.ssr.enable_ramdumps 0
    resetprop persist.sys.debug.app.mtbf_test false

    # Xiaomi RT scheduler boost / SPTM guards. Some values are persisted by
    # the ROM, so reassert them early instead of relying only on system.prop.
    resetprop persist.sys.debug_rtmode false
    resetprop persist.sys.enable_rtmode false
    resetprop persist.sys.enable_sched_gesture false
    resetprop persist.sys.enable_ignorecloud_rtmode true
    resetprop persist.sys.miui_sptm.enable_pl_type 0

    # Xiaomi Scout/native-hang diagnostics. These are still enabled as persisted
    # values on some HyperOS builds even when system.prop contains false values.
    resetprop persist.sys.miui_scout_debug false
    resetprop persist.sys.stability.nativehangII.enable false
    resetprop persist.sys.stability.nativehangII.resume false
    resetprop persist.sys.miui_scout_binder_full_kill_process false
    resetprop persist.sys.scout_binder_gki false
    resetprop persist.sys.stability.scout.enable false
    resetprop persist.sys.stability.scout.check_frozen false
    resetprop persist.sys.sysrqOnAnr_D_state false
    resetprop persist.sys.panicOnAnr_D_state false
    resetprop persist.sys.panicOnWatchdog_D_state false

    # Qualcomm IMS/radio logging controls. These are vendor-stack dependent,
    # but reduce IMS debug, ADB, QXDM, and radio ramdump logging when honored.
    resetprop persist.ims.disableDebugLogs 1
    resetprop persist.ims.disableADBLogs 1
    resetprop persist.ims.disableQXDMLogs 1
    resetprop persist.ims.disableIMSLogs 1
    resetprop persist.radio.ramdump 0
    resetprop vidc.debug.level 0
    resetprop vendor.vidc.debug.level 0
    resetprop vendor.swvdec.log.level 0

    # Qualcomm multimedia prefetch toggle.
    resetprop persist.mm.enable.prefetch false

    # trims or optimizes of render nodes (overhead)
    resetprop persist.sys.trim_rendernode.enable true

    
else
    #MediaTeK
    resetprop ro.vendor.mtk_prefer_64bit_proc 1
    # resetprop persist.vendor.duraspeed.support 0
    # resetprop persist.vendor.duraspeed.lowmemory.enable 0
    # resetprop persist.vendor.duraeverything.support 0
    # resetprop persist.vendor.duraeverything.lowmemory.enable 0
    # resetprop persist.system.powerhal.applist_enable 0
    # MPBE I/O Boosting
    # resetprop vendor.mi.mpbe.enable 1
    # resetprop vendor.mi.mpbe.ioboost.enable 1
    # resetprop vendor.mi.mpbe.ioturbo.enable 1
fi

# Vulkan selection.
# Default to GL unless the installer option explicitly enabled Vulkan. Keep
# RenderEngine aligned so the stack does not mix GL and Vulkan paths.
load_user_options
if [ "$ENABLE_VULKAN" = "1" ]; then
    set_hwui_pipeline "skiavk"
else
    set_hwui_pipeline "skiagl"
fi

exit
