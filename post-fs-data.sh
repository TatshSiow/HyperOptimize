#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
# This script will be executed in post-fs-data mode
# More info in the main Magisk thread
MODDIR=${0%/*}

####################################
# Disable Unnecessary Things (by @nonosvaimos)
####################################
resetprop -n av.debug.disable.pers.cache true
resetprop -n config.disable_rtt true
resetprop -n config.stats 0
resetprop -n db.log.slow_query_threshold 0
resetprop -n debug.atrace.tags.enableflags false
#resetprop -n debug.egl.profiler 0
resetprop -n debug.enable.gamed false
resetprop -n debug.enable.wl_log false
#resetprop -n debug.hwc.otf 0
#resetprop -n debug.hwc_dump_en 0
resetprop -n debug.mdpcomp.logs 0
#resetprop -n debug.qualcomm.sns.daemon 0
#resetprop -n debug.qualcomm.sns.libsensor1 0
#resetprop -n debug.sf.ddms 0
resetprop -n debug.sf.disable_client_composition_cache 1
resetprop -n debug.sf.dump 0
resetprop -n debug.sqlite.journalmode OFF
resetprop -n debug.sqlite.syncmode=OFF
resetprop -n debug.sqlite.wal.syncmode OFF
resetprop -n debug_test 0
resetprop -n libc.debug.malloc 0
resetprop -n log.shaders 0
resetprop -n log.tag.all 0
resetprop -n log.tag.stats_log OFF
resetprop -n log_ao 0
resetprop -n log_frame_info 0
resetprop -n logd.logpersistd.enable false
resetprop -n logd.statistics 0
resetprop -n media.metrics.enabled false
resetprop -n media.metrics 0
resetprop -n media.stagefright.log-uri 0
#resetprop -n net.ipv4.tcp_no_metrics_save 1
resetprop -n persist.anr.dumpthr 0
#resetprop -n persist.data.qmi.adb_logmask 0
resetprop -n persist.debug.sensors.hal 0 
resetprop -n persist.debug.wfd.enable false
#resetprop -n persist.ims.disableADBLogs true
resetprop -n persist.ims.disabled true
#resetprop -n persist.ims.disableDebugLogs true
#resetprop -n persist.ims.disableIMSLogs true
#resetprop -n persist.ims.disableQXDMLogs true
resetprop -n persist.logd.limit OFF
resetprop -n persist.logd.size OFF
resetprop -n persist.logd.size.crash OFF
resetprop -n persist.logd.size.main OFF
resetprop -n persist.logd.size.radio OFF
resetprop -n persist.logd.size.system OFF
resetprop -n persist.logd.size OFF
resetprop -n persist.oem.dump 0
resetprop -n persist.service.logd.enable false
resetprop -n persist.sys.perf.debug false
resetprop -n persist.sys.ssr.enable_debug false
resetprop -n persist.sys.ssr.restart_level 1
resetprop -n persist.sys.strictmode.disable true
resetprop -n persist.traced.enable false
resetprop -n persist.traced_perf.enable false
resetprop -n persist.vendor.crash.cnt 0
resetprop -n persist.vendor.crash.detect false
resetprop -n persist.vendor.radio.adb_log_on 0
resetprop -n persist.vendor.radio.snapshot_enabled false
resetprop -n persist.vendor.radio.snapshot_timer 0
resetprop -n persist.vendor.sys.modem.logging.enable false
resetprop -n persist.vendor.sys.reduce_qdss_log 1
resetprop -n persist.vendor.verbose_logging_enabled false
#resetprop -n persist.wpa_supplicant.debug false
#resetprop -n ro.config.ksm.support false
resetprop -n ro.config.nocheckin 1
resetprop -n ro.debuggable 0
#resetprop -n ro.kernel.android.checkjni 0
#resetprop -n ro.kernel.checkjni 0
resetprop -n ro.logd.kernel false
resetprop -n ro.logd.size.stats OFF
resetprop -n ro.logd.size OFF
#resetprop -n ro.logdumpd.enabled false
resetprop -n ro.statsd.enable false
resetprop -n ro.telephony.call_ring.multiple false
resetprop -n ro.vendor.connsys.dedicated.log 0
resetprop -n rw.logger 0
resetprop -n sys.miui.ndcd 0
resetprop -n sys.wifitracing.started 0

####################################
# LMK (by @nonosvaimos)
####################################
resetprop -n ro.lmk.debug false
resetprop -n ro.lmk.log_stats false


#dropbox disabler
settings put global dropbox:dumpsys:procstats disabled
settings put global dropbox:dumpsys:usagestats disabled

#@@@@@@ Custom Rulesets @@@@@@@@@@@
#Optimize Surface Flinger Latch
resetprop -n debug.sf.latch_unsignaled false
resetprop -n debug.sf.auto_latch_unsignaled false

# Android ART Logd
resetprop -n persist.sys.qlogd 0

# Disable logging and debugging stuff
resetprop -n debugtool.anrhistory 0
resetprop -n debug.sf.enable_egl_image_tracker 0
resetprop -n persist.debug.sf.statistics 0
resetprop -n persist.log.tag.snet_event_log OFF
resetprop -n persist.radio.ramdump 0
resetprop -n persist.sys.lmk.reportkills false
resetprop -n persist.sys.offlinelog.kernel false
resetprop -n persist.sys.offlinelog.logcat false
resetprop -n persist.sys.offlinelog.logcatkernel false
resetprop -n persist.sys.offlinelog.bootlog false
resetprop -n persist.sys.whetstone.level 0
resetprop -n profiler.hung.dumpdobugreport false
resetprop -n profiler.launch false
resetprop -n logd.disable 1
resetprop -n persist.sys.qseelogd false
resetprop -n ro.boot.ramdump disable
resetprop -n persist.oem.dump 0
resetprop -n persist.vendor.ssr.enable_ramdumps 0
resetprop -n vendor.bluetooth.startbtlogger false
resetprop -n vendor.swvdec.log.level 0
# Dynamic sampling rates for certain UI rendering operations 
resetprop -n dev.pm.dyn_samplingrate 1
# Precompiles app layouts(reducing runtime CPU usage for UI tasks)
resetprop -n dev.pm.precompile_layouts 1
# System Performance Thread Optimization(Improve task scheduling efficiency)
resetprop -n persist.sys.miui_sptm.enable true
#Performance Tuning
resetprop -n accelerated_enabled_for_all true
resetprop -n ro.zygote.disable_gl_preload false
resetprop -n debug.sf.enable_hwc_vds 1

# Zero Shutter Lag
resetprop -n camera.disable_zsl_mode 0

#Testing
resetprop -n debug.power.monitor_tools false
resetprop -n debug.sf.disable_backpressure 1
resetprop -n debug.sf.enable_gl_backpressure 1
resetprop -n persist.mm.enable.prefetch false
resetprop -n vendor.gralloc.disable_ubwc false
#software GLES
resetprop -n persist.sys.force_sw_gles 0

#whatt
resetprop -n pm.sleep_mode 1
resetprop -n ro.ril.disable.power.collapse 1
resetprop -n wifi.supplicant_scan_interval 600
resetprop -n video.accelerate.hw 1
resetprop -n persist.miui.extm.dm_opt.enable true

#Reduce CPU load and improve performance a little (Surface Flinger)
resetprop -n debug.sf.enable_transaction_tracing false
resetprop -n logcat.live disable

#Enable Xiaomi13/14 LTPO back
resetprop -n vendor.disable_idle_fps.threshold 492

#Disable-Skia-Tracing 
resetprop -n debug.hwui.skia_atrace_enabled false