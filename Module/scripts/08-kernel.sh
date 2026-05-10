#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

####################################
# Kernel Parameters
####################################

# Power-efficient workqueues are kernel/vendor policy controlled on some
# devices and may reject writes. Leave the vendor default intact.
# write "/sys/module/workqueue/parameters/power_efficient" "Y"

# never enable this unless you need to really reduce the latency
# write "/proc/sys/kernel/sched_child_runs_first" "0"

# This parameter controls whether timer interrupts can be migrated between CPU cores
# https://blog.csdn.net/qq_33471732/article/details/144695236

# Enabling timer migration can help reduce latency and improve performance for workloads that benefit from more efficient timer handling.
# However, it can also increase the overhead of timer handling and reduce overall performance for workloads that do not benefit from timer migration.
# Setting it to 1 is a good balance for most workloads
# as it allows for more efficient timer handling while still maintaining a degree of flexibility.
# Setting it to 0 can lead to better performance in scenarios where timer migration is not beneficial
# but it can also increase latency and reduce overall performance for workloads that benefit from timer migration.
write "/proc/sys/kernel/timer_migration" "1"

# Energy Aware
write "/proc/sys/kernel/sched_energy_aware" "1"

# Prefer the deeper suspend backend when the kernel exposes it.
# Revert this first if you see delayed wake, missed notifications, or suspend instability.
if grep -qw "deep" /sys/power/mem_sleep 2>/dev/null; then
    write "/sys/power/mem_sleep" "deep"
fi

# Boeffla Wakelock Blocker
# Keep this conservative: broad Wi-Fi, Bluetooth, sensor, timerfd, and netlink
# wakelocks can affect normal runtime behavior because Boeffla blocks globally.
wakelock_list="tftp_server_wakelock;wcnss_filter_lock;"
write "/sys/devices/virtual/misc/boeffla_wakelock_blocker/wakelock_blocker" "$wakelock_list"
write "/sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker" "$wakelock_list"
