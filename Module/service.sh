####################################
# Functions
####################################

# $1:value $2:filepaths
lock_val() {
    for p in $2; do
        if [ -f "$p" ]; then
            chown root:root "$p"
            chmod 0666 "$p"
            echo "$1" >"$p"
            chmod 0444 "$p"
        fi
    done
}

# $1:value $2:filepaths
mask_val() {
    touch /data/local/tmp/mount_mask
    for p in $2; do
        if [ -f "$p" ]; then
            umount "$p"
            chmod 0666 "$p"
            echo "$1" >"$p"
            mount --bind /data/local/tmp/mount_mask "$p"
        fi
    done
}

wait_until_login() {
  while [[ "$(getprop sys.boot_completed)" != "1" ]]; do
    sleep 3
  done

  test_file="/storage/emulated/0/Android/.PERMISSION_TEST"
  true >"$test_file"
  while [[ ! -f "$test_file" ]]; do
    true >"$test_file"
    sleep 1
  done
  rm -f "$test_file"
}

wait_until_login
sleep 15

####################################
# Performance Tuning
####################################

stop perf-hal-2-3
stop vendor.perfservice


if [ "$(getprop ro.hardware)" = "qcom" ]; then 
  if [ -d "/proc/sys/walt/" ]; then
    # disable WALT CPU Boost
    mask_val "0" /proc/sys/walt/sched_boost
    mask_val "0" /proc/sys/walt/input_boost/*
    # WALT Adjustment
    mask_val "5 70" "/proc/sys/walt/sched_downmigrate"
    mask_val "15 90" "/proc/sys/walt/sched_upmigrate"
  fi
  # KGSL Tuning (GPU)
  lock_val "2147483647" /sys/class/devfreq/*kgsl-3d0/max_freq
  lock_val "0" /sys/class/devfreq/*kgsl-3d0/min_freq
  lock_val "0" /sys/class/kgsl/kgsl-3d0/force_bus_on
  lock_val "0" /sys/class/kgsl/kgsl-3d0/force_clk_on
  lock_val "0" /sys/class/kgsl/kgsl-3d0/force_no_nap
  lock_val "0" /sys/class/kgsl/kgsl-3d0/force_rail_on
  lock_val "92" /sys/class/kgsl/kgsl-3d0/devfreq/mod_percent # 92 is bad for Geekbench AI
  
  start vendor.perfservice
  start perf-hal-2-3
  
  lock_val "0" /sys/kernel/rcu_expedited
  echo "5000000" >/sys/kernel/debug/sched/migration_cost_ns
  echo "12500000" >/sys/kernel/debug/sched/wakeup_granularity_ns
  mask_val "4" /proc/sys/kernel/sched_pelt_multiplier
fi

# Xiaomi Config
stop mimd-service
mask_val "0" /sys/module/migt/parameters/enable_pkg_monitor
mask_val "0" /proc/sys/migt/enable_pkg_monitor
mask_val "0" /sys/module/migt/parameters/glk_freq_limit_walt
mask_val "0" /sys/module/metis/parameters/cluaff_control

####################################
# Kill and Stop Services
####################################

sleep 3 
process="
logcat
logd
tombstoned
traced
traced_probes
vendor.diag-router
vendor.ipacm-diag
mi_thermald
subsystem_ramdump
qesdk-manager
vendor.modemManager
vendor.qesdk-mgr
statsd
misight
update_engine
mqsasd
vendor.mi_misight
"

for name in $process; do
  su -c stop "$name" 2>/dev/null 
  su -c killall -9 "$name" 2>/dev/null 
done
  # am kill "$name" 2>/dev/null 

# CPUset Adjustment
lock_val "0-2" /dev/cpuset/background/cpus
lock_val "0-2" /dev/cpuset/system-background/cpus
lock_val "0-6" /dev/cpuset/foreground/cpus
lock_val "0-7" /dev/cpuset/top-app/cpus

exit

# /proc/sys/glk/freq_break_enable
# 1 : aggresive scaling GPU frequency
# 0 : avoid frequent GPU performance jumps

# /proc/sys/glk/glk_disable
# 1 : reduce GPU-related overhead
# 0 : Graphics Lock or synchronization features are active