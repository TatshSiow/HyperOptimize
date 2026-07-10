#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

# Three-round win: less CPU/scheduler work and retransmits, zero packet loss.
write "/proc/sys/net/ipv4/tcp_slow_start_after_idle" "0"

# Already safe; retain for other devices.
write "/proc/sys/net/ipv4/ip_forward" "0"

# No reliable multi-metric win on loopback TCP plus Wi-Fi gateway tests.
# write "/proc/sys/net/ipv4/tcp_tw_reuse" "1"
# write "/proc/sys/net/ipv4/tcp_no_metrics_save" "1"
# write "/proc/sys/net/ipv4/tcp_timestamps" "0"
# write_if_writable "/proc/sys/net/ipv4/tcp_low_latency" "1"
# write_if_writable "/proc/sys/net/ipv4/tcp_ecn" "1"
# write_if_writable "/proc/sys/net/ipv4/tcp_fastopen" "3"
