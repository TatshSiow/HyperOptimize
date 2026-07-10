#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

# Three-round A/B win across CPU/scheduler, I/O, and KGSL GPU metrics.
write "/proc/sys/kernel/printk_ratelimit" "5"

# Compatible, but no repeatable win across at least two independent categories.
# write "/proc/sys/kernel/printk" "0 0 0 0"
# write "/proc/sys/kernel/printk_delay" "0"
# write "/proc/sys/kernel/printk_devkmsg" "off"
# write "/proc/sys/kernel/printk_ratelimit_burst" "1"
# write "/proc/sys/kernel/tracepoint_printk" "0"
# write "/sys/module/printk/parameters/always_kmsg_dump" "N"
# write "/sys/module/printk/parameters/time" "0"
# write "/sys/module/printk/parameters/console_suspend" "1"
# write "/sys/module/printk/parameters/ignore_loglevel" "0"

# Missing on the test kernel; retained for testing on other devices.
# write "/sys/module/printk/parameters/console_no_auto_verbose" "Y"
