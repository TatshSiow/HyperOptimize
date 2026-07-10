#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

# Three-round A/B win: less CPU/scheduler/GPU work, swap-in and major faults.
write "/proc/sys/vm/stat_interval" "60"
write "/proc/sys/vm/dirty_ratio" "14"
write "/proc/sys/vm/dirty_expire_centisecs" "2000"

# No reliable multi-metric win on this 11.2 GiB RAM / 12 GiB zram device.
# Lower swappiness produced substantially more swap-ins, faults, and refaults.
# write "/proc/sys/vm/swappiness" "40"
# write "/proc/sys/vm/page-cluster" "2"
# write "/proc/sys/vm/vfs_cache_pressure" "90"
# write "/proc/sys/vm/dirty_background_ratio" "6"
# write "/proc/sys/vm/dirty_writeback_centisecs" "3000"

# Already identical; no change needed.
# write "/proc/sys/vm/dirtytime_expire_seconds" "43200"

# Missing on the test kernel; retained for another-device testing.
# write "/sys/kernel/mm/lru_gen/enabled" "7"
