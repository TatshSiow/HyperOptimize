#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

write "/proc/sys/net/ipv4/tcp_slow_start_after_idle" "0"
write "/proc/sys/net/ipv4/ip_forward" "0"
