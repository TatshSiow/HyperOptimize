#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
# This script will be executed in post-fs-data mode
# More info in the main Magisk thread
MODDIR=${0%/*}
####################################
# General Optimization
####################################
# LTPO Optimize
#resetprop -n ro.vendor.mi_sf.support_automode_for_normalfps true

# Memory Management
resetprop -n persist.sys.spc.bindvisible true
resetprop -n persist.sys.spc.gamepay.protect.enabled false

# Memory Management
resetprop -n persist.miui.extm.enable false
resetprop -n persist.sys.mms.bg_apps_limit 65535
resetprop -n persist.sys.mms.compact_enable false
resetprop -n persist.sys.mms.single_compact_enable false
resetprop -n persist.sys.mms.enable false
resetprop -n persist.sys.spc.enabled false
resetprop -n persist.sys.spc.bindvisible.enabled false
resetprop -n persist.sys.spc.gamepay.protect.enabled true
resetprop -n persist.sys.spc.cpulimit.enabled false
resetprop -n persist.sys.spc.cpuexception.enabled false
resetprop -n persist.sys.spc.proc_restart_enable false
resetprop -n persist.sys.spc.process.tracker.enable false
resetprop -n persist.sys.spc.fast.launch false
resetprop -n persist.sys.spc.scale.backgorund.app.enable false
resetprop -n persist.sys.spc.resident.app.enable false
resetprop -n persist.sys.miui.resident.app.count 65535
resetprop -n persist.sys.cross_process_jump_response_opt false
resetprop -n persist.sys.min.swap.free false
resetprop -n persist.sys.memory_standard.enable false
resetprop -n persist.sys.mfz.enable false
resetprop -n persist.miui.boot.mopt.enable false
resetprop -n persist.sys.mimd.reclaim.enable false
resetprop -n persist.sys.mmms.switch false
resetprop -n persist.sys.mthp.enabled false
resetprop -n persist.sys.miui.damon.enable false
resetprop -n persist.sys.stability.enable_process_exit_monitor false
resetprop -n persist.sys.stability.enable_rss_monitor false
resetprop -n persist.sys.stability.enable_sentinel_resource_monitor false
resetprop -n persist.sys.stability.enable_thread_monitor false
resetprop -n persist.sys.stability_memory_monitor.enable false
resetprop -n persist.sys.stability.swapEnable false
resetprop -n persist.sys.stability.enable_dmabuf_monitor false
resetprop -n persist.sys.stability.enable_fd_monitor false
resetprop -n persist.sys.debug.enable_scout_memory_monitor false
resetprop -n persist.sys.smartpower.intercept.enable false
resetprop -n persist.sys.smartpower.appstate.enable false

# 3x Faster Game Splash
resetprop -n debug.game.video.support true
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
resetprop -n persist.sys.stability.iorapEnable false

# Disable Screen Dim and Reduced Refresh Rate when overheat
resetprop -n persist.sys.enable_templimit false
resetprop -n ro.vendor.display.hwc_thermal_dimming false
resetprop -n ro.vendor.fps.switch.thermal false
resetprop -n ro.vendor.thermal.dimming.enable false
resetprop -n persist.sys.smartpower.display_thermal_temp_threshold 99

# Sched
# resetprop -n persist.sys.miui_animator_sched.bigcores 3-7
# resetprop -n persist.sys.miui.sf_cores 3-7
# resetprop -n persist.vendor.display.miui.composer_boost 3-7
# resetprop -n ro.miui.affinity.sfui 3-7
# resetprop -n ro.miui.affinity.sfre 3-7
# resetprop -n ro.miui.affinity.sfuireset 0-7
resetprop -n persist.sys.miui_animator_sched.sched_threads false
resetprop -n persist.miui.miperf.enable false
resetprop -n persist.sys.smart_gc.enable false
resetprop -n persist.sys.stability.gcImproveEnable.8false8 false
resetprop -n persist.sys.enable_perf_hint false
resetprop -n persist.sys.miui_scout_enable false
resetprop -n persist.sys.miui_sptm.enable false
resetprop -n persist.sys.miui_sptm_new.enable false
resetprop -n persist.sys.miui_sptm.ignore_cloud_enable false
resetprop -n persist.sys.miui_startup_mode.enable false
resetprop -n persist.sys.miui_slow_startup_mode.enable false
resetprop -n persist.sys.miuibooster.launch.rtmode false
resetprop -n persist.sys.miuibooster.rtmode false
resetprop -n persist.miui.home_reuse_leash true
resetprop -n ro.miui.shell_anim_enable_fcb false
# resetprop -n persist.sys.hyper_transition true
# resetprop -n persist.sys.hyper.barfollow_anim true
# persist.sys.gesture_anim_magic_speed=1.0

# Misc
resetprop -n persist.sys.stability.f2fsTrackEnable false
resetprop -n persist.sys.stability.nativehang.enable false
resetprop -n persist.sys.stability.qcom_hang_task.enable false
resetprop -n persist.sys.stability.report_app_launch.enable false
resetprop -n persist.sys.stability.window_monitor.enabled false
resetprop -n persist.sys.textureview_optimization.enable false
resetprop -n persist.sys.touch.followup.enable false
resetprop -n persist.sys.trim_rendernode.enable false
resetprop -n persist.sys.stability.lz4asm off
resetprop -n persist.sys.stability.reboot_days -1
resetprop -n persist.sys.stability.smartfocusio off
resetprop -n persist.sys.stability.fbo_hal_stop false
resetprop -n persist.sys.fboservice.ctrl true

# Display
resetprop -n ro.vendor.touch.touchscheduler.enable false
resetprop -n persist.sys.smartpower.display_camera_fps_enable true

# Network
resetprop -n persist.sys.miuitcptracker.ctrl false
resetprop -n vendor.miui.wifi.p2p.enable160m true

# Power Management Dynamic sampling
resetprop -n dev.pm.dyn_samplingrate 1

# event processing framerate cap (Mi Highest RR screen is 144)
resetprop -n windowsmgr.max_events_per_sec 144

# Unified Bandwidth Compression (Lower Power Consumption)
resetprop -n vendor.gralloc.disable_ubwc false
resetprop -n debug.gralloc.enable_fb_ubwc 1

# Dynamic Refresh Rate Support (RC=RefreshrateControl)
resetprop -n vendor.display.enable_rc_support 1

# Radio Interface Layer (RIL) Powersaving State
resetprop -n ro.ril.power.collapse 1
resetprop -n ro.ril.disable.power.collapse 0


resetprop -n profiler.launch false # Disables profiling for app launches
resetprop -n persist.sys.debug.app.mtbf_test false # Disable mtbf_test
resetprop -n persist.sys.perfdebug.monitor.enable false #perf monitor
resetprop -n persist.sys.whetstone.level 0 # Disable whetstone benchmark
resetprop -n wifiP2pEnabled 0 # P2P/Wi-Fi Direct
resetprop -n ro.kernel.power_suspend 1 # Allows the kernel to suspend operations when idle
resetprop -n ro.config.hw_power_saving true # Hardware Power Saving  
resetprop -n persist.sys.purgeable_assets 1 # release memory used by drawable and bitmap assets that are not in use
resetprop -n persist.sys.enable_cache_fusion true #optimize app data caching
resetprop -n ro.bluetooth.request.master false #Prevents the device from being the "master" in Bluetooth connections (Save Power)
resetprop -n persist.sys.use_boot_compact false #Disabling increase boot time slightly but could save some system resources during boot

# Disallow framepacing in favor of FAS algorithms
resetprop -n vendor.perf.framepacing.enable false

# CoreSight
resetprop -n persist.debug.coresight.config ""

# Strict mode (for developers only)
resetprop -n persist.android.strictmode 0

# Wifi Tuning (Powersaving)
resetprop -n wifi.supplicant_scan_interval 180
resetprop -n persist.wifi.scan_power_saving true
resetprop -n ro.wifi.power_management 1 # Adjust Wifi Power Dynamically

# LMKD
# resetprop -n ro.lmk.swap_util_max 100
# resetprop -n ro.lmk.swap_free_low_percentage 0

# dex2oat optimization
resetprop -n dalvik.vm.background-dex2oat-cpu-set 2,3,4,5,6,7
resetprop -n dalvik.vm.bg-dex2oat-threads 6
resetprop -n dalvik.vm.boot-dex2oat-cpu-set 2,3,4,5,6,7
resetprop -n dalvik.vm.boot-dex2oat-threads 6
resetprop -n dalvik.vm.default-dex2oat-cpu-set 2,3,4,5,6,7
resetprop -n dalvik.vm.dex2oat-cpu-set 2,3,4,5,6,7
resetprop -n dalvik.vm.dex2oat-threads 6
resetprop -n dalvik.vm.image-dex2oat-cpu-set 2,3,4,5,6,7
resetprop -n dalvik.vm.image-dex2oat-threads 6
resetprop -n dalvik.vm.dex2oat-swap true
resetprop -n dalvik.vm.madvise.artfile.size 2147483647
resetprop -n dalvik.vm.madvise.odexfile.size 2147483647
resetprop -n dalvik.vm.madvise.vdexfile.size 2147483647
resetprop -n dalvik.vm.systemservercompilerfilter everything
resetprop -n dalvik.vm.systemuicompilerfilter everything

# dex2oat 
resetprop -n persist.dalvik.vm.dex2oat-threads 8
resetprop -n system_perf_init.bg-dex2oat-threads 8
resetprop -n system_perf_init.boot-dex2oat-threads 8
resetprop -n system_perf_init.dex2oat-threads 8

# dex2oat Trigger
resetprop -n pm.dexopt.ab-ota verify
resetprop -n pm.dexopt.bg-dexopt everything
resetprop -n pm.dexopt.boot-after-ota verify
resetprop -n pm.dexopt.boot-after-mainline-update verify
resetprop -n pm.dexopt.cmdline everything
resetprop -n pm.dexopt.downgrade_after_inactive_days 30
resetprop -n pm.dexopt.first-boot verify
resetprop -n pm.dexopt.first-use verify
resetprop -n pm.dexopt.inactive verify
resetprop -n pm.dexopt.install everything
resetprop -n pm.dexopt.install-bulk everything
resetprop -n pm.dexopt.install-bulk-downgraded everything
resetprop -n pm.dexopt.install-bulk-secondary everything
resetprop -n pm.dexopt.install-bulk-secondary-downgraded everything
resetprop -n pm.dexopt.install-fast verify
resetprop -n pm.dexopt.post-boot verify
resetprop -n pm.dexopt.shared everything

# Use kryo785 as processor target for ART and Bionic
resetprop -n dalvik.vm.isa.arm64.variant kryo785
resetprop -n ro.bionic.cpu_variant kryo785
resetprop -n dalvik.vm.isa.arm64.features runtime

####################################
# Graphics and Rendering
####################################

# General Optimization
resetprop -n ro.zygote.disable_gl_preload false
resetprop -n debug.hwui.render_dirty_regions false
resetprop -n debug.sf.disable_backpressure 1
resetprop -n debug.sf.enable_gl_backpressure 0
resetprop -n persist.sys.use_dithering 0

# Optimize Layout Compilation (reducing UI tasks CPU usage)
resetprop -n dev.pm.precompile_layouts 1

# Hardware Acceleration
# resetprop -n video.accelerate.hw 1
# resetprop -n persist.sys.ui.hwlayer_power_saving 1
# resetprop -n persist.sys.force_hw_accel true
# resetprop -n persist.sys.ui.hw_layers true
# resetprop -n accelerated_enabled_for_all true
resetprop -n debug.egl.hw 1
resetprop -n debug.renderengine.backend skiavkthreaded
# debug.renderengine.graphite true
resetprop -n debug.renderengine.vulkan true
resetprop -n debug.stagefright.renderengine.backend threaded
resetprop -n debug.sf.multithreaded_present true
resetprop -n persist.sys.force_sw_gles 0
# resetprop -n debug.egl.profiler 1
# resetprop -n persist.sys.ui.hw 1
# resetprop -n ro.hwui.use_vulkan true

# Disable surfaceflinger managed dynamic fps
resetprop -n ro.surface_flinger.use_content_detection_for_refresh_rate true

# Surface Flinger Optimization
resetprop -n debug.sf.cache_source_crop_only_moved true
resetprop -n debug.sf.disable_client_composition_cache 0
resetprop -n debug.sf.enable_layer_command_batching true
resetprop -n debug.sf.fp16_client_target true
resetprop -n debug.sf.hw 1
resetprop -n debug.sf.latch_unsignaled 1
resetprop -n debug.sf.auto_latch_unsignaled 0
resetprop -n debug.sf.multithreaded_present true
resetprop -n debug.sf.predict_hwc_composition_strategy 1
resetprop -n debug.sf.screenshot_fence_preservation true
resetprop -n ro.surface_flinger.running_without_sync_framework false
resetprop -n ro.surface_flinger.start_graphics_allocator_service true
# resetprop -n debug.sf.latch_unsignaled 0
# resetprop -n debug.sf.auto_latch_unsignaled 1
# resetprop -n ro.surface_flinger.max_frame_buffer_acquired_buffers 2
# resetprop -n debug.sf.enable_transaction_tracing false
# resetprop -n debug.sf.enable_advanced_sf_phase_offset 0
# resetprop -n debug.sf.region_sampling_period_ns 500000000
# resetprop -n debug.sf.set_idle_timer_ms 500
# resetprop -n debug.sf.use_phase_offsets_as_durations 1
# resetprop -n persist.sys.sf.partial_updates 1
# resetprop -n debug.sf.frame_rate_divisor 2
# resetprop -n persist.sys.sf.enable_gpu_offload 1
# resetprop -n debug.sf.enable_frame_rate_hinting 1
# resetprop -n debug.sf.partial_update true

# Software GLES
resetprop -n persist.sys.force_sw_gles 0

# # Vulkan
# resetprop -n debug.sf.vulkan true
# resetprop -n debug.hwui.disable_vulkan false
# resetprop -n debug.hwui.overdraw false
# resetprop -n debug.hwui.renderer vulkan
# resetprop -n debug.hwui.use_hwc true
# resetprop -n debug.hwui.use_vulkan true
# resetprop -n debug.hwui.vulkan_cache true
# resetprop -n debug.hwui.vulkan_disable_rt false
# resetprop -n debug.hwui.vulkan_prefetch true  
resetprop -n debug.renderengine.backend skiaglthreaded
resetprop -n debug.stagefright.renderengine.backend threaded
# resetprop -n renderthread.skia.reduceopstasksplitting true

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
resetprop -n debug.sf.dump 0
resetprop -n debug.sf.gles_log 0
resetprop -n persist.vendor.graphics.debug 0
resetprop -n persist.vendor.graphics.log 0
resetprop -n debug.sf.enable_egl_image_tracker 0
resetprop -n persist.debug.sf.statistics 0

####################################
# Dalvik VM 
####################################

# ART Optimizations
resetprop -n dalvik.vm.foreground-heap-growth-multiplier 2.5
resetprop -n dalvik.vm.heapgrowthlimit 512m
resetprop -n dalvik.vm.heapmaxfree 32m
resetprop -n dalvik.vm.heapminfree 512k
resetprop -n dalvik.vm.heapsize 512m
resetprop -n dalvik.vm.heapstartsize 2m
resetprop -n dalvik.vm.heaptargetutilization 0.8
resetprop -n persist.device_config.runtime_native.usap_pool_enabled true
resetprop -n persist.sys.usap_pool_enabled true
resetprop -n dalvik.vm.usap_pool_enabled true
resetprop -n dalvik.vm.usap_pool_refill_delay_ms 3000
resetprop -n dalvik.vm.usap_pool_size_max 3
resetprop -n dalvik.vm.usap_pool_size_min 1
resetprop -n dalvik.vm.usap_refill_threshold 1
# ro.dalvik.vm.enable_uffd_gc true
# persist.device_config.runtime_native_boot.force_disable_uffd_gc false
# persist.device_config.runtime_native_boot.enable_generational_cc ""
# dalvik.vm.gctype CMC
# dalvik.vm.backgroundgctype HSpaceCompact

# Logging
resetprop -n dalvik.vm.dex2oat-minidebuginfo false
resetprop -n dalvik.vm.minidebuginfo false

# Debugging and Verification
resetprop -n dalvik.vm.check-dex-sum true
resetprop -n dalvik.vm.checkjni false
resetprop -n dalvik.vm.verify-bytecode true

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
resetprop -n persist.debug.sensors.hal 0 
resetprop -n persist.sys.perf.debug false
resetprop -n persist.sys.ssr.enable_debug false
resetprop -n persist.sys.ssr.restart_level ALL_DISABLE
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
resetprop -n persist.sys.watchdog_enhanced false
resetprop -n persist.sys.oom_crash_on_watchdog false

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
resetprop -n persist.logd.size 0M
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
# resetprop -n persist.lmk.disable 1
resetprop -n persist.sys.lmk.critical 0
resetprop -n persist.sys.lmk.silent 1
resetprop -n persist.sys.memtrack 0
resetprop -n persist.sys.lmk.logging 0
resetprop -n persist.lmk.logging 0

# Log Tag
resetprop -n log.tag.all S
resetprop -n persist.log.tag S

# MGLRU Disable
resetprop -n persist.sys.mglru_enable false

####################################
# Parameters ideas and credits
####################################
# 多肉芋圆葡萄 - 酷安 CoolApk
# Amktiao 水龙 - 酷安 CoolApk
# Nakixii - 酷安 CoolApk
# @nonosvaimos
# @LeanHijosdesusMadres
#
# Looper(iamlooper) - Github
# ionuttbara - GitHub
# KTSR - GitHub
# KNTD-reborn - GitHub