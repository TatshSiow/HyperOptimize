#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

# Three-round win across CPU, scheduler, I/O, GPU, and log-volume metrics.
stop charge_logger 2>/dev/null

# Absent on the test device; retained for another-device testing.
# stop vendor.tcpdump 2>/dev/null
# stop vendor.atrace-hal-1-0 2>/dev/null

# Bulk S-level suppression reduced log volume but hid audio/radio/power/framework
# errors and increased jank. Keep core and vendor diagnostics visible.
# resetprop -n log.tag.HWComposer S
# resetprop -n log.tag.HWC2On1Adapter S
# resetprop -n log.tag.SDM S
# ...all remaining static log.tag.* entries intentionally omitted...

# Repeatedly scanning logcat for 15 minutes adds work; omit dynamic suppression.
# suppress_dynamic_logtags &
