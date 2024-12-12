#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
# This script will be executed in post-fs-data mode
# More info in the main Magisk thread
MODDIR=${0%/*}
####################################
# General Optimization
####################################

# MIUI optimizations
resetprop -n persist.miui.extm.dm_opt.enable true
resetprop -n persist.sys.miui_sptm.enable true

# Tuning Based on Xiaomi Official Props
resetprop -n vendor.display.enable_fb_scaling 0
resetprop -n vendor.gralloc.use_dma_buf_heaps 1
resetprop -n vendor.display.enable_allow_idle_fallback 1
resetprop -n vendor.display.enable_perf_hint_large_comp_cycle 1
resetprop -n vendor.display.enable_rotator_ui 1
resetprop -n vendor.display.enable_latch_media_content 1
resetprop -n vendor.display.enable_inline_writeback 0
resetprop -n vendor.display.timed_render_enable 1
resetprop -n vendor.display.disable_system_load_check 1
resetprop -n vendor.display.enable_posted_start_dyn 2

# Disables Preload (Save Battery but longer app launch duration)
resetprop -n persist.zygote.preload false #testing
resetprop -n persist.sys.prestart.proc false
resetprop -n persist.sys.preload.enable false
resetprop -n persist.sys.precache.enable false
resetprop -n persist.sys.prestart.feedback.enable false
resetprop -n persist.sys.app_dexfile_preload.enable false

# Disable can reduce memory overhead
resetprop -n persist.mm.enable.prefetch false

# Power Management Dynamic sampling
resetprop -n dev.pm.dyn_samplingrate 1

# Zero Shutter Lag
resetprop -n camera.disable_zsl_mode 0

# Wifi Tuning (Powersaving)
resetprop -n wifi.supplicant_scan_interval 600
resetprop -n persist.wifi.scan_power_saving true

# USAP Pool (Android Runtime Optimization)
resetprop -n persist.device_config.runtime_native.usap_pool_enabled true

# Unified Bandwidth Compression (Lower Power Consumption)
resetprop -n vendor.gralloc.disable_ubwc false
resetprop -n debug.gralloc.enable_fb_ubwc 1
# Reenable Xiaomi13/14 LTPO feature
resetprop -n vendor.disable_idle_fps.threshold 492

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
#resetprop -n ro.kernel.power_suspend 1

# Testing
resetprop -n profiler.force_disable_err_rpt 1
resetprop -n profiler.force_disable_ulog 1
resetprop -n ro.debuggable 0
resetprop -n persist.sys.purgeable_assets 1
resetprop -n persist.sys.use_dithering 0
resetprop -n dalvik.vm.dexopt-flags "m=y"
resetprop -n persist.sys.enable_cache_fusion 0
resetprop -n ro.bluetooth.request.master false
resetprop -n ro.bluetooth.keep_alive false
resetprop -n ro.wifi.power_management 1

####################################
# Graphics and Rendering
####################################

# Testing
resetprop -n debug.hwui.render_dirty_regions false
resetprop -n ro.surface_flinger.max_frame_buffer_acquired_buffers 2
resetprop -n persist.sys.ui.hw 1

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
resetprop -n debug.sf.hw 1
resetprop -n accelerated_enabled_for_all true

# Optimize Surface Flinger Latch
resetprop -n debug.sf.latch_unsignaled false
resetprop -n debug.sf.auto_latch_unsignaled false

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

# Disable Software GLES (Use Vulkan)
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
resetprop -n debug.renderengine.backend skiagl
resetprop -n renderthread.skia.reduceopstasksplitting true

# Logging and Debugging
resetprop -n debug.hwui.skia_atrace_enabled false
resetprop -n debug.enable.gpu.debuglayers 0
resetprop -n persist.sys.debug.sf.debug false
resetprop -n debug.sys.fw.debug false
resetprop -n debug.vendor.power false
resetprop -n debug.egl.hw 0
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
resetprop -n dalvik.vm.heapgrowthlimit 128m
resetprop -n dalvik.vm.heapsize 256m
resetprop -n dalvik.vm.heapstartsize 32m
resetprop -n dalvik.vm.heaptargetutilization 0.75

# Ahead-of-Time (AOT) Compilation
resetprop -n dalvik.vm.dex2oat-flags "--compiler-filter=speed-profile"
resetprop -n dalvik.vm.dex2oat-resolve-startup-strings true
resetprop -n dalvik.vm.dex2oat-swap true
resetprop -n dalvik.vm.dex2oat-threads 4
resetprop -n dalvik.vm.systemservercompilerfilter speed-profile
resetprop -n dalvik.vm.systemuicompilerfilter speed-profile

# Memory Allocation
resetprop -n dalvik.vm.usap_pool_enabled true
resetprop -n dalvik.vm.jit.code_cache_size 1MB

# Debugging and Verification
resetprop -n dalvik.vm.dex2oat-minidebuginfo false
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
resetprop -n debug.egl.profiler 0
resetprop -n debug.enable.gamed false
resetprop -n ro.debuggable 0
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
resetprop -n persist.logd.limit OFF
resetprop -n persist.logd.size OFF
resetprop -n persist.logd.size.crash OFF
resetprop -n persist.logd.size.main OFF
resetprop -n persist.logd.size.radio OFF
resetprop -n persist.logd.size.system OFF
resetprop -n persist.sys.qlogd 0
resetprop -n ro.logd.kernel false
resetprop -n ro.logd.size.stats OFF
resetprop -n ro.logd.size OFF
resetprop -n ro.logdumpd.enabled false
resetprop -n logd.logpersistd.enable false
resetprop -n persist.service.logd.enable false

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
resetprop -n persist.ims.disableADBLogs true
resetprop -n persist.ims.disableDebugLogs true
resetprop -n persist.ims.disableIMSLogs true
resetprop -n persist.ims.disableQXDMLogs true

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
resetprop -n persist.sys.offlinelog.kernel false
resetprop -n persist.sys.offlinelog.logcat false
resetprop -n persist.sys.offlinelog.logcatkernel false
resetprop -n persist.sys.offlinelog.bootlog false

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

# LMK
resetprop -n ro.lmk.debug false
resetprop -n ro.lmk.log_stats false
resetprop -n persist.sys.lmk.reportkills false

####################################
# Log Tags
####################################

# General
resetprop -n log.tag.all 0
resetprop -n log.tag.stats_log OFF
resetprop -n persist.log.tag Settings OFF
resetprop -n persist.log.tag.snet_event_log OFF

# System and UI Logs
resetprop -n log.tag.SystemUI 0
resetprop -n log.tag.WindowManager 0
resetprop -n log.tag.ActivityManager 0
resetprop -n log.tag.PowerManager 0
resetprop -n log.tag.InputDispatcher 0
resetprop -n log.tag.InputManager 0

# Networking and Connectivity
resetprop -n log.tag.WifiScanner 0
resetprop -n log.tag.ConnectivityService 0
resetprop -n log.tag.NetworkStats 0
resetprop -n log.tag.WifiStateMachine 0
resetprop -n log.tag.DnsResolver 0

# Location Services
resetprop -n debug.log.tag.GpsLocation 0
resetprop -n log.tag.ActivityRecognition 0
resetprop -n log.tag.gnss 0
resetprop -n log.tag.GeofencingProvider 0
resetprop -n log.tag.LocationManager 0

# Sensors
resetprop -n log.tag.Sensors 0
resetprop -n log.tag.SensorManager 0
resetprop -n log.tag.SensorService 0

# Graphics
resetprop -n log.tag.GLES 0
resetprop -n log.tag.RenderThread 0
resetprop -n log.tag.SurfaceFlinger 0

# Miscellaneous
resetprop -n debug.log.tag.Power 0
resetprop -n log.tag.AppOps 0
resetprop -n log.tag.BatteryStats 0
resetprop -n log.tag.BluetoothService 0
resetprop -n log.tag.eventlog 0
resetprop -n log.tag.MDnsDS 0
resetprop -n log.tag.PackageManager 0

# Media and Audio
resetprop -n debug.log.tag.AudioFlinger 0
resetprop -n log.tag.AF::MmapTrack 0
resetprop -n log.tag.AF::OutputTrack 0
resetprop -n log.tag.AF::PatchRecord 0
resetprop -n log.tag.AF::PatchTrack 0
resetprop -n log.tag.AF::RecordHandle 0
resetprop -n log.tag.AF::RecordTrack 0
resetprop -n log.tag.AF::Track 0
resetprop -n log.tag.AF::TrackBase 0
resetprop -n log.tag.AF::TrackHandle 0
resetprop -n log.tag.APM::AudioCollections 0
resetprop -n log.tag.APM::AudioInputDescriptor 0
resetprop -n log.tag.APM::AudioOutputDescriptor 0
resetprop -n log.tag.APM::AudioPatch 0
resetprop -n log.tag.APM::AudioPolicyEngine 0
resetprop -n log.tag.APM::AudioPolicyEngine::Base 0
resetprop -n log.tag.APM::AudioPolicyEngine::Config 0
resetprop -n log.tag.APM::AudioPolicyEngine::ProductStrategy 0
resetprop -n log.tag.APM::AudioPolicyEngine::VolumeGroup 0
resetprop -n log.tag.APM::Devices 0
resetprop -n log.tag.APM::IOProfile 0
resetprop -n log.tag.APM::Serializer 0
resetprop -n log.tag.APM::VolumeCurve 0
resetprop -n log.tag.APM_AudioPolicyManager 0
resetprop -n log.tag.APM_ClientDescriptor 0
resetprop -n log.tag.AudioTrack 0
resetprop -n log.tag.AudioManager 0
resetprop -n log.tag.AudioAttributes 0
resetprop -n log.tag.AudioEffect 0
resetprop -n log.tag.AudioFlinger 0
resetprop -n log.tag.AudioFlinger::DeviceEffectProxy 0
resetprop -n log.tag.AudioFlinger::DeviceEffectProxy::ProxyCallback 0
resetprop -n log.tag.AudioFlinger::EffectBase 0
resetprop -n log.tag.AudioFlinger::EffectChain 0
resetprop -n log.tag.AudioFlinger::EffectHandle 0
resetprop -n log.tag.AudioFlinger::EffectModule 0
resetprop -n log.tag.AudioFlinger_Threads 0
resetprop -n log.tag.AudioHwDevice 0
resetprop -n log.tag.AudioPolicy 0
resetprop -n log.tag.AudioPolicyEffects 0
resetprop -n log.tag.AudioPolicyIntefaceImpl 0
resetprop -n log.tag.AudioPolicyService 0
resetprop -n log.tag.AudioProductStrategy 0
resetprop -n log.tag.AudioRecord 0
resetprop -n log.tag.AudioSystem 0
resetprop -n log.tag.AudioTrackShared 0
resetprop -n log.tag.AudioVolumeGroup 0
resetprop -n log.tag.FastCapture 0
resetprop -n log.tag.FastMixer 0
resetprop -n log.tag.FastMixerState 0
resetprop -n log.tag.FastThread 0
resetprop -n log.tag.IAudioFlinger 0
resetprop -n log.tag.MediaPlayer 0
resetprop -n log.tag.ToneGenerator 0


####################################
# Parameters ideas and credits
####################################
# 多肉芋圆葡萄 - 酷安 CoolApk
# Amktiao 水龙 - 酷安 CoolApk
# 
# @nonosvaimos
# @LeanHijosdesusMadres
# Looper(iamlooper) - Github
# ionuttbara - GitHub
# KTSR - GitHub
# KNTD-reborn - GitHub