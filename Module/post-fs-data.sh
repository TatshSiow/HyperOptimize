#!/system/bin/sh
MODDIR=${0%/*}

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

# Vulkan Enabler
if [ -f "/system/vendor/etc/permissions/android.hardware.vulkan.version-1_3.xml" ] && [[ $(getprop ro.build.version.sdk) -ge 33 ]]; then
    resetprop debug.hwui.renderer skiavkthreaded
    resetprop ro.hwui.use_vulkan true
    resetprop ro.hardware.vulkan adreno
    # resetprop debug.renderengine.graphite true
    resetprop debug.renderengine.vulkan true
    resetprop debug.renderengine.backend skiavkthreaded
    # Below is MTK Vulkan, skiavkthreaded doesn't make a huge difference and i felt the phone being more unstable, so i took it out 
elif [ -f "/system/vendor/etc/permissions/android.hardware.vulkan.version-1_3.prebuilt.xml" ] && [[ $(getprop ro.build.version.sdk) -ge 33 ]]; then
    resetprop debug.hwui.renderer skiavk
    resetprop ro.hwui.use_vulkan true
    resetprop debug.renderengine.backend skiavk
else
    resetprop debug.renderengine.backend skiaglthreaded
fi;

exit