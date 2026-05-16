#!/system/bin/sh

delete_prop() {
  command -v resetprop >/dev/null 2>&1 || return 0
  resetprop -d "$1" >/dev/null 2>&1
  return 0
}

# Restore DropboxManager defaults for the current boot session when possible.
cmd dropbox restore-defaults >/dev/null 2>&1

# Re-enable framework looper statistics collection when supported.
cmd looper_stats enable >/dev/null 2>&1
cmd settings delete global looper_stats >/dev/null 2>&1
delete_prop debug.sys.looper_stats_enabled

# Restore runtime diagnostic defaults observed on stock configuration.
cmd settings delete system anr_debugging_mechanism >/dev/null 2>&1
cmd settings delete secure adaptive_sleep >/dev/null 2>&1
cmd device_config delete runtime_native_boot iorap_perfetto_enable >/dev/null 2>&1

# Remove runtime Perfetto/heapprofd/logpersist trigger props set by the module.
delete_prop persist.device_config.global_settings.sys_traced
delete_prop persist.traced.enable
delete_prop persist.traced_perf.enable
delete_prop debug.atrace.user_initiated
delete_prop traced.lazy.traced_perf
delete_prop traced.lazy.heapprofd
delete_prop persist.heapprofd.enable
delete_prop traced.lazy.heapprofd_standalone
delete_prop persist.sys.debug.app.mtbf_test
delete_prop persist.sys.debug_rtmode
delete_prop persist.sys.enable_rtmode
delete_prop persist.sys.enable_sched_gesture
delete_prop persist.sys.enable_ignorecloud_rtmode
delete_prop persist.sys.miui_sptm.enable_pl_type
delete_prop persist.sys.miui_scout_debug
delete_prop persist.sys.stability.nativehangII.enable
delete_prop persist.sys.stability.nativehangII.resume
delete_prop persist.sys.miui_scout_binder_full_kill_process
delete_prop persist.sys.scout_binder_gki
delete_prop persist.sys.stability.scout.enable
delete_prop persist.sys.stability.scout.check_frozen
delete_prop persist.sys.sysrqOnAnr_D_state
delete_prop persist.sys.panicOnAnr_D_state
delete_prop persist.sys.panicOnWatchdog_D_state
delete_prop logd.logpersistd.enable
delete_prop logd.logpersistd
delete_prop persist.logd.logpersistd

# Best-effort pruning-list reset. Log buffer size itself is restored on reboot
# from the device's normal properties after the module overlay is gone.
logcat -P "" >/dev/null 2>&1

# Don't modify anything after this
if [ -f "$INFO" ]; then
  while read LINE; do
    if [ "$(echo -n "$LINE" | tail -c 1)" == "~" ]; then
      continue
    elif [ -f "$LINE~" ]; then
      mv -f "$LINE~" "$LINE"
    else
      rm -f "$LINE"
      while true; do
        LINE=$(dirname "$LINE")
        [ "$(ls -A "$LINE" 2>/dev/null)" ] && break 1 || rm -rf "$LINE"
      done
    fi
  done < "$INFO"
  rm -f "$INFO"
fi
