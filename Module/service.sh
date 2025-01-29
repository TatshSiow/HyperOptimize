####################################
# Functions
####################################

mkdir -p /dev/mount_masks

# $1:value $2:path
lock_val() {
    find "$2" -type f | while read -r file; do
        file="$(realpath "$file")"
        umount "$file"
        chmod +w "$file"
        echo "$1" >"$file"
        chmod -w "$file"
    done
}

# $1:value $2:path $3:filename
# $1:value $2:path $3:subdir $4:filename
lock_val_in_path() {
    if [ "$#" = "4" ]; then
        find "$2/" -path "*$3*" -name "$4" -type f | while read -r file; do
            lock_val "$1" "$file"
        done
    else
        find "$2/" -name "$3" -type f | while read -r file; do
            lock_val "$1" "$file"
        done
    fi
}

# $1:value $2:path
mask_val() {
    find "$2" -type f | while read -r file; do
        lock_val "$1" "$file"

        TIME="$(date "+%s%N")"
        echo "$1" >"/dev/mount_masks/mount_mask_$TIME"
        mount --bind "/dev/mount_masks/mount_mask_$TIME" "$file"
        restorecon -R -F "$file" >/dev/null 2>&1
    done
}

# $1:value $2:path $3:filename
# $1:value $2:path $3:subdir $4:filename
mask_val_in_path() {
    if [ "$#" = "4" ]; then
        find "$2/" -path "*$3*" -name "$4" -type f | while read -r file; do
            mask_val "$1" "$file"
        done
    else
        find "$2/" -name "$3" -type f | while read -r file; do
            mask_val "$1" "$file"
        done
    fi
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

####################################
# Script Start
####################################

wait_until_login
sleep 15

####################################
# Performance Tuning
####################################
if [ "$(getprop ro.hardware)" = "qcom" ]; then 
    stop perf-hal-2-3
    stop vendor.perfservice

    # KGSL Tuning (GPU)
    lock_val "2147483647" /sys/class/devfreq/*kgsl-3d0/max_freq
    lock_val "0" /sys/class/devfreq/*kgsl-3d0/min_freq
    lock_val "0" /sys/class/kgsl/kgsl-3d0/force_bus_on
    lock_val "0" /sys/class/kgsl/kgsl-3d0/force_clk_on
    lock_val "0" /sys/class/kgsl/kgsl-3d0/force_no_nap
    lock_val "0" /sys/class/kgsl/kgsl-3d0/force_rail_on
    lock_val "92" /sys/class/kgsl/kgsl-3d0/devfreq/mod_percent # 92 is bad for Geekbench AI

    if [ -d /proc/sys/walt/ ]; then
    # WALT disable boost
        mask_val "0" /proc/sys/walt/sched_boost
        mask_val_in_path "0" "/proc/sys/walt/input_boost" "*"
        # 高：省電，但響應速降低
        # WALT的conservative，省電
        mask_val "1" /proc/sys/walt/sched_conservative_pl
        # Colcation
        mask_val "51" /proc/sys/walt/sched_min_task_util_for_boost
        mask_val "35" /proc/sys/walt/sched_min_task_util_for_colocation
        mask_val "20000000" /proc/sys/walt/sched_task_unfilter_period
    fi
    # Reduce PERF Monitoring overhead
    # Stock:25
    # mask_val "25" /proc/sys/kernel/perf_cpu_time_max_percent

    # Restart PERF service
    start vendor.perfservice
    start perf-hal-2-3

fi

# CPUset Adjustment
lock_val "0-2" /dev/cpuset/background/cpus
lock_val "0-2" /dev/cpuset/system-background/cpus
lock_val "0-6" /dev/cpuset/foreground/cpus
lock_val "0-7" /dev/cpuset/top-app/cpus

# Xiaomi Config
stop mimd-service
mask_val "0" /sys/module/migt/parameters/glk_freq_limit_walt
mask_val "0" /sys/module/metis/parameters/cluaff_control



####################################
# Kill and Stop Services
####################################

sleep 3 
process="
charge_logger
logcat
traced
traced_probes
vendor.ipacm-diag
mi_thermald
vendor.modemManager
vendor.qesdk-mgr
statsd
misight
update_engine
mqsasd"

for name in $process; do
  su -c stop "$name" 2>/dev/null 
done

# 有些設定system.prop吃不到，我放這裡總可以了吧（？
#Disable Power Monitor Tools
su -c "resetprop -n debug.power.monitor_tools false"
# LMK
su -c "resetprop -n persist.sys.lmk.reportkills false"
# statsd
su -c "resetprop -n persist.device_config.runtime_native.metrics.write-to-statsd false"
su -c "resetprop -n persist.device_config.statsd_native_boot.enable_restricted_metrics false"

exit

# /proc/sys/glk/freq_break_enable
# 1 : aggresive scaling GPU frequency
# 0 : avoid frequent GPU performance jumps

# /proc/sys/glk/glk_disable
# 1 : reduce GPU-related overhead
# 0 : Graphics Lock or synchronization features are active