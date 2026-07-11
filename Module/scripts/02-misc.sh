#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

# Confirmed reduction in CPU, scheduler and block-I/O work.
write "/sys/module/spurious/parameters/noirqdebug" "Y"
