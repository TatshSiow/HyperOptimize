#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

####################################
# Runtime Framework Config
####################################

run_cmd() {
    "$@" >/dev/null 2>&1
    local code="$?"

    : "${RUN_LOG:=/dev/null}"
    if [ "$HYPEROPTIMIZE_DEBUG" = "1" ]; then
        if [ "$code" = "0" ]; then
            echo "cmd ok: $*" >> "$RUN_LOG"
        else
            echo "cmd failed($code): $*" >> "$RUN_LOG"
        fi
    fi

    return 0
}

log_get() {
    local label="$1"
    shift

    : "${RUN_LOG:=/dev/null}"
    [ "$HYPEROPTIMIZE_DEBUG" = "1" ] && echo "cmd value: $label=$("$@" 2>/dev/null)" >> "$RUN_LOG"
    return 0
}

# Keep DropboxManager alive but reduce low-priority broadcast spam.
run_cmd cmd dropbox set-rate-limit 10000

# Disable framework looper statistics collection when the shell service exists.
run_cmd cmd settings put global looper_stats enabled false
run_cmd resetprop debug.sys.looper_stats_enabled false
run_cmd cmd looper_stats disable

# Reduce framework/runtime diagnostics overhead where supported.
run_cmd cmd settings put system anr_debugging_mechanism 0
run_cmd cmd settings put system send_security_reports 0
run_cmd cmd settings put secure send_action_app_error 0
run_cmd cmd settings put global send_action_app_error 0
run_cmd cmd settings put global activity_starts_logging_enabled 0
run_cmd cmd settings put global force_enable_pss_profiling 0
run_cmd cmd settings put global upload_apk_enable 0
run_cmd cmd device_config put runtime_native_boot iorap_perfetto_enable false

# Disable attention features that can keep sensors active.
run_cmd cmd settings put secure adaptive_sleep 0

# Disable Xiaomi touch-down app prestart behavior through the all-package
# blacklist. This complements the MIUI preload/SPTM properties in system.prop.
run_cmd cmd settings put system touch_prestart_opt_config "{featureDisable:false,bgExceptionInterceptDisable:false,touchDownPreStartBlackList:[disable_all_package]}"
run_cmd cmd settings put system predownload_cloud_enable 0

# Perfetto/heapprofd tracing triggers. These properties can start tracing,
# perf sampling, or heap profiling daemons when set by developer tools.
run_cmd resetprop persist.device_config.global_settings.sys_traced 0
run_cmd resetprop persist.traced.enable 0
run_cmd resetprop persist.traced_perf.enable 0
run_cmd resetprop debug.atrace.user_initiated ""
run_cmd resetprop traced.lazy.traced_perf ""
run_cmd resetprop traced.lazy.heapprofd ""
run_cmd resetprop persist.heapprofd.enable 0
run_cmd resetprop traced.lazy.heapprofd_standalone ""
run_cmd resetprop persist.sys.debug.app.mtbf_test false

# logcatd/logpersist can be re-enabled by logcatd.rc during persistent-property
# load. Reassert the stopped state late in boot.
run_cmd resetprop logd.logpersistd.enable false
run_cmd resetprop logd.logpersistd stop
run_cmd resetprop persist.logd.logpersistd ""

# Keep retained logcat data minimal without killing logd.
run_cmd logcat -b all -G 64K
run_cmd logcat -P "~! ~1000/!"
run_cmd logcat -b all -c

log_get "settings.system.anr_debugging_mechanism" cmd settings get system anr_debugging_mechanism
log_get "settings.system.send_security_reports" cmd settings get system send_security_reports
log_get "settings.secure.send_action_app_error" cmd settings get secure send_action_app_error
log_get "settings.global.send_action_app_error" cmd settings get global send_action_app_error
log_get "settings.global.activity_starts_logging_enabled" cmd settings get global activity_starts_logging_enabled
log_get "settings.global.force_enable_pss_profiling" cmd settings get global force_enable_pss_profiling
log_get "settings.global.upload_apk_enable" cmd settings get global upload_apk_enable
log_get "settings.system.touch_prestart_opt_config" cmd settings get system touch_prestart_opt_config
log_get "settings.system.predownload_cloud_enable" cmd settings get system predownload_cloud_enable
log_get "settings.global.looper_stats" cmd settings get global looper_stats
log_get "settings.secure.adaptive_sleep" cmd settings get secure adaptive_sleep
log_get "device_config.runtime_native_boot.iorap_perfetto_enable" cmd device_config get runtime_native_boot iorap_perfetto_enable
log_get "prop.debug.sys.looper_stats_enabled" getprop debug.sys.looper_stats_enabled
log_get "prop.persist.device_config.global_settings.sys_traced" getprop persist.device_config.global_settings.sys_traced
log_get "prop.persist.traced.enable" getprop persist.traced.enable
log_get "prop.persist.traced_perf.enable" getprop persist.traced_perf.enable
log_get "prop.debug.atrace.user_initiated" getprop debug.atrace.user_initiated
log_get "prop.traced.lazy.traced_perf" getprop traced.lazy.traced_perf
log_get "prop.traced.lazy.heapprofd" getprop traced.lazy.heapprofd
log_get "prop.persist.heapprofd.enable" getprop persist.heapprofd.enable
log_get "prop.traced.lazy.heapprofd_standalone" getprop traced.lazy.heapprofd_standalone
log_get "prop.persist.sys.debug.app.mtbf_test" getprop persist.sys.debug.app.mtbf_test
log_get "prop.logd.logpersistd.enable" getprop logd.logpersistd.enable
log_get "prop.logd.logpersistd" getprop logd.logpersistd
log_get "prop.persist.logd.logpersistd" getprop persist.logd.logpersistd
