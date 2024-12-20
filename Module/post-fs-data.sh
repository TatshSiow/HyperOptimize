#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
# This script will be executed in post-fs-data mode
# More info in the main Magisk thread
MODDIR=${0%/*}
####################################
# General Optimization
####################################

# Memory Management
resetprop -n persist.miui.extm.enable 0
resetprop -n persist.sys.spc.enabled false
resetprop -n persist.sys.spc.bindvisible true
resetprop -n persist.sys.mfz.enable false
resetprop -n persist.miui.boot.mopt.enable false

# Faster game loading
resetprop -n debug.game.video.support true

# GPU Acceleration
resetprop -n debug.game.video.speed true

# Disables Preload/Prefetch
resetprop -n persist.zygote.preload false
resetprop -n persist.sys.prestart.proc false
resetprop -n persist.sys.preload.enable false
resetprop -n persist.sys.precache.enable false
resetprop -n persist.sys.prestart.feedback.enable false
resetprop -n persist.sys.app_dexfile_preload.enable false
resetprop -n persist.mm.enable.prefetch false
resetprop -n persist.sys.dynamic_usap_enabled false

# Disable Screen Dim and Reduced Refresh Rate when overheat
resetprop -n ro.vendor.display.hwc_thermal_dimming false
resetprop -n ro.vendor.fps.switch.thermal false
resetprop -n ro.vendor.thermal.dimming.enable false

# Sched
resetprop -n persist.sys.miuibooster.rtmode false
resetprop -n persist.sys.miuibooster.launch.rtmode false
resetprop -n persist.sys.launch_response_optimization.enable true

# Debug
resetprop -n persist.sys.debug.app.mtbf_test false

# Power Management Dynamic sampling
resetprop -n dev.pm.dyn_samplingrate 1

# Wifi Tuning (Powersaving)
resetprop -n wifi.supplicant_scan_interval 180
resetprop -n persist.wifi.scan_power_saving true

# USAP Pool (Android Runtime Optimization)
resetprop -n persist.device_config.runtime_native.usap_pool_enabled true

# Unified Bandwidth Compression (Lower Power Consumption)
resetprop -n vendor.gralloc.disable_ubwc false
resetprop -n debug.gralloc.enable_fb_ubwc 1

# Dynamic Refresh Rate Support (RC=RefreshrateControl)
resetprop -n vendor.display.enable_rc_support 1

# Radio Interface Layer (RIL) Powersaving State
resetprop -n ro.ril.power.collapse 1
resetprop -n ro.ril.disable.power.collapse 0

# Disables profiling for app launches
resetprop -n profiler.launch false

# Disable whetstone benchmark tool
resetprop -n persist.sys.whetstone.level 0

# Disable P2P/Wi-Fi Direct
resetprop -n wifiP2pEnabled 0

# Hardware Power Saving  
resetprop -n ro.config.hw_power_saving true

# Allows the kernel to suspend operations when idle
resetprop -n ro.kernel.power_suspend 1

# Testing
resetprop -n persist.sys.purgeable_assets 1
resetprop -n persist.sys.use_dithering 0
resetprop -n dalvik.vm.dexopt-flags "m=y"
resetprop -n persist.sys.enable_cache_fusion 0
resetprop -n ro.bluetooth.request.master false
resetprop -n ro.bluetooth.keep_alive false
resetprop -n ro.wifi.power_management 1

# AppCompact
resetprop -n persist.sys.use_boot_compact false

# Disallow framepacing in favor of FAS algorithms
resetprop -n vendor.perf.framepacing.enable false

# CoreSight
resetprop -n persist.debug.coresight.config ""

# Strict mode (for developers only)
resetprop -n persist.android.strictmode 0
####################################
# Graphics and Rendering
####################################

# Testing
resetprop -n debug.hwui.render_dirty_regions false
resetprop -n ro.surface_flinger.max_frame_buffer_acquired_buffers 2


# General Optimization
resetprop -n ro.zygote.disable_gl_preload false
resetprop -n debug.sf.enable_hwc_vds 0
resetprop -n debug.sf.disable_backpressure 1
resetprop -n debug.sf.enable_gl_backpressure 0

# Optimize Layout Compilation (reducing UI tasks CPU usage)
resetprop -n dev.pm.precompile_layouts 1

# Hardware Acceleration
resetprop -n video.accelerate.hw 1
resetprop -n persist.sys.ui.hwlayer_power_saving 1
resetprop -n persist.sys.force_hw_accel true
resetprop -n persist.sys.ui.hw_layers true
resetprop -n accelerated_enabled_for_all true
resetprop -n debug.egl.hw 1
resetprop -n debug.egl.profiler 1
resetprop -n persist.sys.ui.hw 1

# Optimize Surface Flinger
resetprop -n debug.sf.hw 1
resetprop -n debug.sf.latch_unsignaled 0
resetprop -n debug.sf.auto_latch_unsignaled 1

# Disable surfaceflinger managed dynamic fps
resetprop -n ro.surface_flinger.use_content_detection_for_refresh_rate true

# Surface Flinger Optimization
resetprop -n debug.sf.enable_transaction_tracing false
resetprop -n debug.sf.enable_advanced_sf_phase_offset 0
resetprop -n debug.sf.region_sampling_period_ns 500000000
resetprop -n debug.sf.set_idle_timer_ms 500
resetprop -n debug.sf.use_phase_offsets_as_durations 1
resetprop -n persist.sys.sf.partial_updates 1
resetprop -n debug.sf.frame_rate_divisor 2
resetprop -n persist.sys.sf.enable_gpu_offload 1
resetprop -n debug.sf.enable_frame_rate_hinting 1
resetprop -n debug.sf.partial_update true

# Software GLES
resetprop -n persist.sys.force_sw_gles 0

# Vulkan
resetprop -n debug.sf.vulkan true
resetprop -n debug.hwui.disable_vulkan false
resetprop -n debug.hwui.overdraw false
resetprop -n debug.hwui.renderer vulkan
resetprop -n debug.hwui.use_hwc true
resetprop -n debug.hwui.use_vulkan true
resetprop -n debug.hwui.vulkan_cache true
resetprop -n debug.hwui.vulkan_disable_rt false
resetprop -n debug.hwui.vulkan_prefetch true  
resetprop -n debug.renderengine.backend skiaglthreaded
resetprop -n renderthread.skia.reduceopstasksplitting true

# Logging and Debugging
resetprop -n debug.hwui.skia_atrace_enabled false
resetprop -n debug.enable.gpu.debuglayers 0
resetprop -n persist.sys.debug.sf.debug false
resetprop -n debug.sys.fw.debug false
resetprop -n debug.vendor.power false
resetprop -n debug.sf.dump_hw_layers 0
resetprop -n vendor.swvdec.log.level 0
resetprop -n debug.hwc.otf 0
resetprop -n debug.hwc_dump_en 0
resetprop -n debug.sf.ddms 0
resetprop -n debug.sf.disable_client_composition_cache 0
resetprop -n debug.sf.dump 0
resetprop -n debug.sf.gles_log 0
resetprop -n persist.vendor.graphics.debug 0
resetprop -n persist.vendor.graphics.log 0
resetprop -n debug.sf.enable_egl_image_tracker 0
resetprop -n persist.debug.sf.statistics 0

####################################
# Dalvik VM 
####################################
# Dalvik/ART Memory Management
resetprop -n dalvik.vm.foreground-heap-growth-multiplier 2.5
resetprop -n dalvik.vm.heapgrowthlimit 512m
resetprop -n dalvik.vm.heapmaxfree 32m
resetprop -n dalvik.vm.heapminfree 512k
resetprop -n dalvik.vm.heapsize 512m
resetprop -n dalvik.vm.heapstartsize 2m
resetprop -n dalvik.vm.heaptargetutilization 0.8

# Ahead-of-Time (AOT) Compilation
resetprop -n dalvik.vm.dex2oat-flags "--compiler-filter=speed-profile"
resetprop -n dalvik.vm.dex2oat-resolve-startup-strings true
resetprop -n dalvik.vm.dex2oat-swap true
resetprop -n dalvik.vm.systemservercompilerfilter speed-profile
resetprop -n dalvik.vm.systemuicompilerfilter speed-profile

# # Multithreaded dex2oat
# resetprop -n dalvik.vm.background-dex2oat-cpu-set 2,3,4,5,6,7
# resetprop -n dalvik.vm.bg-dex2oat-threads 6
# resetprop -n dalvik.vm.boot-dex2oat-cpu-set 2,3,4,5,6,7
# resetprop -n dalvik.vm.boot-dex2oat-threads 6
# resetprop -n dalvik.vm.default-dex2oat-cpu-set 2,3,4,5,6,7
# resetprop -n dalvik.vm.dex2oat-cpu-set 2,3,4,5,6,7
# resetprop -n dalvik.vm.dex2oat-threads 6
# resetprop -n dalvik.vm.image-dex2oat-cpu-set 2,3,4,5,6,7
# resetprop -n dalvik.vm.image-dex2oat-threads 6

# # Memory Allocation
# resetprop -n dalvik.vm.usap_pool_enabled true
# resetprop -n dalvik.vm.jit.code_cache_size 1MB
# resetprop -n dalvik.vm.usap_pool_refill_delay_ms 3000
# resetprop -n dalvik.vm.usap_pool_size_max 3
# resetprop -n dalvik.vm.usap_pool_size_min 1
# resetprop -n dalvik.vm.usap_refill_threshold 1

# Debugging and Verification
resetprop -n dalvik.vm.dex2oat-minidebuginfo false
resetprop -n dalvik.vm.check-dex-sum true
resetprop -n dalvik.vm.checkjni false
resetprop -n dalvik.vm.verify-bytecode true
resetprop -n dalvik.vm.minidebuginfo false

# Garbage Collection (GC)
resetprop -n dalvik.gc.type generational_cc

# Just-In-Time (JIT)
resetprop -n dalvik.vm.usejit true

####################################
# Debug & Logging
####################################

# Enable this if you want to use Digital Wellbeing (Usage Stats)
resetprop -n ro.sys.usage_stats false

# General
resetprop -n persist.sys.logtag 0
resetprop -n persist.sys.logging_enabled 0
resetprop -n persist.sys.debuggable 0
resetprop -n persist.sys.init.debug 0
resetprop -n persist.sys.bionic.debug 0
resetprop -n persist.sys.debug.enable 0
resetprop -n persist.sys.qemu.debug 0
resetprop -n persist.sys.debug.svc false
resetprop -n debug.power.monitor_tools false
resetprop -n av.debug.disable.pers.cache true
resetprop -n debug.atrace.tags.enableflags false
resetprop -n debug.enable.gamed false
resetprop -n config.disable_rtt true
resetprop -n config.stats 0
resetprop -n db.log.slow_query_threshold 0
resetprop -n debug.mdpcomp.logs 0
resetprop -n debug_test 0
resetprop -n libc.debug.malloc 0
resetprop -n log.shaders 0
resetprop -n log_ao 0
resetprop -n log_frame_info 0
#resetprop -n persist.debug.sensors.hal 0 
resetprop -n persist.debug.wfd.enable false
resetprop -n persist.sys.perf.debug false
resetprop -n persist.sys.ssr.enable_debug false
resetprop -n persist.sys.ssr.restart_level 1
resetprop -n persist.sys.strictmode.disable true
resetprop -n persist.traced.enable false
resetprop -n persist.traced_perf.enable false
resetprop -n persist.vendor.crash.cnt 0
resetprop -n persist.vendor.crash.detect false
resetprop -n persist.vendor.sys.modem.logging.enable false
resetprop -n persist.vendor.sys.reduce_qdss_log 1
resetprop -n persist.vendor.verbose_logging_enabled false
resetprop -n persist.wpa_supplicant.debug false
resetprop -n ro.statsd.enable false
resetprop -n rw.logger 0
resetprop -n sys.miui.ndcd off
resetprop -n debugtool.anrhistory 0

# Logd
resetprop -n logd.disable 1
resetprop -n logd.statistics 0
resetprop -n persist.logd disable
resetprop -n persist.sys.qlogd 0
resetprop -n ro.logd.kernel false
resetprop -n ro.logdumpd.enabled false
resetprop -n logd.logpersistd.enable false
resetprop -n persist.service.logd.enable false
resetprop -n ro.logd.size.stats OFF
resetprop -n persist.logd.limit OFF
resetprop -n persist.logd.size OFF
resetprop -n persist.logd.size.crash OFF
resetprop -n persist.logd.size.main OFF
resetprop -n persist.logd.size.radio OFF
resetprop -n persist.logd.size.system OFF

# Qualcomm Logging
resetprop -n persist.sys.qseelogd false
resetprop -n debug.qualcomm.sns.daemon 0
resetprop -n debug.qualcomm.sns.libsensor1 0

# Logcat
resetprop -n logcat.live disable

# SystemCTL
resetprop -n persist.sys.sysctl.enable_timing false
resetprop -n persist.sys.sysctl.enable_logging false

# Audio & Video Debugging
resetprop -n persist.audio.debug 0
resetprop -n persist.video.debug 0
resetprop -n vendor.vidc.debug.level 0
resetprop -n vidc.debug.level 0
resetprop -n media.metrics.enabled false
resetprop -n media.metrics 0
resetprop -n media.stagefright.log-uri 0

# Connectivity
resetprop -n persist.ipacm.diag.enable 0 # IP Architecture and Control Module
resetprop -n persist.wifi.debugging 0
resetprop -n vendor.bluetooth.startbtlogger false
resetprop -n debug.enable.wl_log false
resetprop -n persist.vendor.radio.adb_log_on 0
resetprop -n persist.vendor.radio.snapshot_enabled false
resetprop -n persist.vendor.radio.snapshot_timer 0
resetprop -n net.ipv4.tcp_no_metrics_save 1
resetprop -n ro.telephony.call_ring.multiple false
resetprop -n persist.telephony.debug 0
resetprop -n sys.wifitracing.started 0
resetprop -n ro.vendor.connsys.dedicated.log 0
resetprop -n persist.data.qmi.adb_logmask 0

# IMS
resetprop -n persist.vendor.ims.debug.enabled 0
resetprop -n persist.vendor.ims.loglevel 0
resetprop -n persist.radio.imsloglevel 0
resetprop -n persist.ims.disableADBLogs true
resetprop -n persist.ims.disableDebugLogs true
resetprop -n persist.ims.disableIMSLogs true
resetprop -n persist.ims.disableQXDMLogs true
resetprop -n persist.vendor.carrier.ims.debug 0
resetprop -n persist.sys.ims.logging OFF

# Dumps
resetprop -n persist.sys.dumpstate 0
resetprop -n profiler.hung.dumpdobugreport false
resetprop -n persist.radio.ramdump 0
resetprop -n ro.boot.ramdump disable
resetprop -n persist.vendor.ssr.enable_ramdumps 0
resetprop -n persist.anr.dumpthr 0
resetprop -n persist.oem.dump 0

# Device Power Management (DPM) 
resetprop -n persist.vendor.dpm.loglevel 0
resetprop -n persist.vendor.dpmhalservice.loglevel 0

# Dropbox (not that Dropbox APP!!!)
settings put global dropbox:dumpsys:procstats disabled
settings put global dropbox:dumpsys:usagestats disabled

# Offline Log
resetprop -n persist.sys.offlinelog 0

# SQLite
resetprop -n debug.sqlite.journalmode OFF
resetprop -n debug.sqlite.syncmode OFF
resetprop -n debug.sqlite.wal.syncmode OFF

# Kernel
resetprop -n ro.kernel.android.checkjni 0
resetprop -n ro.kernel.checkjni 0
resetprop -n persist.sys.kernel.log false
resetprop -n persist.kernel.debug.disable true
resetprop -n persist.kernel.logging 0
resetprop -n persist.vendor.kernel.debug_level 0
resetprop -n ro.config.ksm.support false
resetprop -n ro.config.nocheckin 1
resetprop -n ro.debuggable 0
resetprop -n persist.sys.kernel_logging 0

# LMK
resetprop -n ro.lmk.debug false
resetprop -n ro.lmk.log_stats false
resetprop -n persist.sys.lmk.reportkills false
resetprop -n persist.lmk.disable 1
resetprop -n persist.sys.lmk.critical 0
resetprop -n persist.sys.lmk.silent 1
resetprop -n persist.sys.memtrack 0
resetprop -n persist.sys.lmk.logging 0
resetprop -n persist.lmk.logging 0

# Log Tag
resetprop -n log.tag.all 0

####################################
# Parameters ideas and credits
####################################
# 多肉芋圆葡萄 - 酷安 CoolApk
# Amktiao 水龙 - 酷安 CoolApk
# 
# @nonosvaimos
# @LeanHijosdesusMadres
#
# Looper(iamlooper) - Github
# ionuttbara - GitHub
# KTSR - GitHub
# KNTD-reborn - GitHub