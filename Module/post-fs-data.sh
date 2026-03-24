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
            ;;
    esac
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
    resetprop persist.sys.qlogd 0
    resetprop vendor.bluetooth.startbtlogger false
    resetprop persist.vendor.sys.rawdump_copy 0
    resetprop persist.sys.qseelogd false
    resetprop persist.sys.ssr.enable_debug 0
    resetprop persist.vendor.ssr.enable_ramdumps 0

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
# Apply the same HWUI Vulkan force that would normally be tested manually with
# `setprop debug.hwui.renderer skiavk`, but do it persistently at boot. Keep
# RenderEngine aligned so the stack does not mix GL and Vulkan paths.
set_hwui_pipeline "skiavk"

exit
