#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

run_cmd() { "$@" >/dev/null 2>&1; return 0; }

prop_exists() { resetprop "$1" >/dev/null 2>&1; }
setprop_if_present() { prop_exists "$1" && run_cmd resetprop "$1" "$2"; }

# Three-round win across CPU, system_server, scheduler, I/O, and GPU metrics.
run_cmd resetprop debug.sys.looper_stats_enabled false
run_cmd cmd looper_stats disable

# Individual A/B win across I/O and GPU metrics with zero errors.
run_cmd cmd settings put system anr_debugging_mechanism 0

# Confirmed on fuxi; apply only when the ROM already exposes the knob.
security_reports="$(cmd settings get system send_security_reports 2>/dev/null)"
if [ -n "$security_reports" ] && [ "$security_reports" != "null" ]; then
    run_cmd cmd settings put system send_security_reports 0
fi

setprop_if_present persist.sys.stability.nativehangII.enable false
setprop_if_present persist.sys.turbosched.local.enable false
setprop_if_present persist.vendor.wifisalog.enable false
setprop_if_present persist.sys.offlinelog.bootlog false
setprop_if_present persist.vendor.camera.mawlog.aiasd 0

# No reliable multi-metric win for the remaining knobs.
# run_cmd cmd settings put secure send_action_app_error 0
# run_cmd cmd settings put global send_action_app_error 0
# run_cmd cmd settings put global activity_starts_logging_enabled 0
# run_cmd cmd settings put global force_enable_pss_profiling 0
# run_cmd cmd settings put global upload_apk_enable 0
# run_cmd cmd settings put system predownload_cloud_enable 0
# run_cmd cmd settings put system touch_prestart_opt_config "{featureDisable:false,bgExceptionInterceptDisable:false,touchDownPreStartBlackList:[disable_all_package]}"

# User-visible feature; not treated as an optimization.
# run_cmd cmd settings put secure adaptive_sleep 0

# Already false or reboot/service-start scoped; not benchmark-proven here.
# run_cmd cmd device_config put runtime_native_boot iorap_perfetto_enable false
# run_cmd resetprop persist.traced.enable 0
# run_cmd resetprop persist.traced_perf.enable 0
# run_cmd resetprop persist.heapprofd.enable 0
# run_cmd resetprop persist.sys.debug.app.mtbf_test false
# run_cmd resetprop logd.logpersistd.enable false
# run_cmd resetprop logd.logpersistd stop
# run_cmd resetprop persist.logd.logpersistd ""

# Diagnostic tradeoffs or irreversible; deliberately omitted.
# run_cmd cmd dropbox set-rate-limit 10000
# run_cmd logcat -b all -G 64K
# run_cmd logcat -P "~! ~1000/!"
# run_cmd logcat -b all -c
