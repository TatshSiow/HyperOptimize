#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

if [ "$(getprop ro.hardware)" = qcom ]; then
    write "/sys/class/kgsl/kgsl-3d0/force_bus_on" "0"
    write "/sys/class/kgsl/kgsl-3d0/force_clk_on" "0"
    write "/sys/class/kgsl/kgsl-3d0/force_rail_on" "0"
    write "/sys/class/kgsl/kgsl-3d0/force_no_nap" "0"
    write_if_writable "/sys/kernel/rcu_expedited" "0"
    write_in_path "1000" "/sys/devices/system/cpu/cpufreq" "down_rate_limit_us"
    for path in $(find /sys/devices/system/cpu/qcom_lpm -type f -name '*disable*' 2>/dev/null); do write "$path" "0"; done
fi

if [ -d /proc/sys/walt ]; then
    write "/proc/sys/walt/sched_boost" "0"
    write "/proc/sys/walt/sched_asymcap_boost" "0"
    for path in /sys/devices/system/cpu/cpu*/cpufreq/walt/boost; do write "$path" "0"; done
else
    write_in_path "1000" "/sys/devices/system/cpu/cpufreq" "down_rate_limit_us"
fi
