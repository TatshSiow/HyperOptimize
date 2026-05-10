#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

####################################
# Network Tuning
####################################

write "/proc/sys/net/ipv4/tcp_slow_start_after_idle" "0"
write "/proc/sys/net/ipv4/tcp_tw_reuse" "1"
write "/proc/sys/net/ipv4/tcp_no_metrics_save" "1"

# Enable this if you want to get vulnerable to attacks (especially the ones without networking knowledge)
write "/proc/sys/net/ipv4/ip_forward" "0"

