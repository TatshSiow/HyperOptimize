#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

if [ -d /sys/module/migt ]; then
    write "/proc/sys/migt/enable_pkg_monitor" "0"
    write_if_writable "/sys/module/migt/parameters/enable_pkg_monitor" "0"
    write "/sys/module/migt/parameters/glk_freq_limit_walt" "0"
    write_if_writable "/sys/module/migt/parameters/boost_policy" "0"
    write "/sys/module/migt/parameters/glk_disable" "1"
    write "/sys/module/migt/parameters/force_stask_to_big" "0"
fi

if [ -d /sys/module/metis ]; then
    write_if_writable "/sys/module/metis/parameters/suspend_vip_enable" "0"
    write_if_writable "/sys/module/metis/parameters/mi_link_enable" "0"
    write_if_writable "/sys/module/metis/parameters/mi_switch_enable" "0"
fi
