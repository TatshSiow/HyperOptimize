#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

write "/proc/sys/vm/stat_interval" "60"
write "/proc/sys/vm/dirty_ratio" "14"
write "/proc/sys/vm/dirty_expire_centisecs" "2000"
