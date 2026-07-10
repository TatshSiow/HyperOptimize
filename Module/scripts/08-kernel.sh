#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

# No setting met the multi-metric acceptance threshold on this device.
# write "/proc/sys/kernel/timer_migration" "1"
# write "/proc/sys/kernel/sched_energy_aware" "1"
# write "/proc/sys/kernel/sched_child_runs_first" "0"

# Read-protected; the vendor-selected Y value remains untouched.
# write "/sys/module/workqueue/parameters/power_efficient" "Y"

# The write succeeds, but an unplugged suspend/resume stability test was not run.
# if grep -qw deep /sys/power/mem_sleep 2>/dev/null; then
#     write "/sys/power/mem_sleep" "deep"
# fi

# Compatible during UI testing, but wake-source counters were unavailable and
# no CPU/I/O/GPU benefit was measured.
# wakelock_list="tftp_server_wakelock;wcnss_filter_lock;"
# write "/sys/devices/virtual/misc/boeffla_wakelock_blocker/wakelock_blocker" "$wakelock_list"
# write "/sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker" "$wakelock_list"
