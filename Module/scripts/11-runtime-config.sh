#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

setprop_value debug.sys.looper_stats_enabled false
run_cmd cmd looper_stats disable
setting_put system anr_debugging_mechanism 0
setting_put_if_present system send_security_reports 0

# Cross-ROM candidates are applied only when the ROM already exposes them.
setprop_if_present persist.sys.stability.nativehangII.enable false
setprop_if_present persist.sys.turbosched.local.enable false
setprop_if_present persist.vendor.wifisalog.enable false
setprop_if_present persist.sys.offlinelog.bootlog false
setprop_if_present persist.vendor.camera.mawlog.aiasd 0
