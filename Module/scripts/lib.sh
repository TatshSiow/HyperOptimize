#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
####################################
# Functions
####################################
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

write() {
    local file="$1"
    shift
    [ -f "$file" ] && { echo "$@" > "$file"; } 2>/dev/null
    return 0
}

normalize_toggle() {
    case "$1" in
        "1") echo "0" ;;
        "Y") echo "N" ;;
        "enabled") echo "disabled" ;;
        "on") echo "off" ;;
        *)
            if echo "$1" | grep -qE '^[0-9]+$'; then
                echo "0"
            else
                return 1
            fi
            ;;
    esac
}

apply_toggle() {
    local path="$1"
    [ -f "$path" ] || return 0

    local val new_val
    val=$(cat "$path" 2>/dev/null) || return 0
    new_val=$(normalize_toggle "$val") || return 0
    write "$path" "$new_val"
}

debug_cache_signature() {
    {
        getprop ro.build.fingerprint
        getprop ro.build.version.incremental
        getprop ro.vendor.build.fingerprint
        getprop ro.bootimage.build.fingerprint
        uname -r
    } 2>/dev/null
}

build_debug_path_cache() {
    local cache="$1"
    local tmp="${cache}.$$.tmp"
    local path base pattern

    mkdir -p "$(dirname "$cache")"
    : > "$tmp"

    find /sys /proc/sys -type f 2>/dev/null | while read -r path; do
        base="${path##*/}"
        for pattern in $debug_name; do
            case "$base" in
                $pattern)
                    echo "$path"
                    break
                    ;;
            esac
        done
    done > "$tmp"

    mv -f "$tmp" "$cache"
}

apply_debug_path_cache() {
    local cache="$1"
    local sig="${cache}.sig"
    local sig_tmp="${sig}.$$.tmp"
    local path

    mkdir -p "$(dirname "$cache")"
    debug_cache_signature > "$sig_tmp"

    if [ ! -f "$cache" ] || [ ! -f "$sig" ] || ! cmp -s "$sig_tmp" "$sig"; then
        build_debug_path_cache "$cache"
        mv -f "$sig_tmp" "$sig"
    else
        rm -f "$sig_tmp"
    fi

    [ -s "$cache" ] || return 0

    while read -r path; do
        apply_toggle "$path"
    done < "$cache"
}


# $1:value $2:path
lock_val() {
    find "$2" -type f 2>/dev/null | while read -r file; do
        file="$(realpath "$file")"
        umount "$file" 2>/dev/null
        chmod +w "$file" 2>/dev/null
        { echo "$1" >"$file"; } 2>/dev/null
        chmod -w "$file" 2>/dev/null
    done
    return 0
}


lock_val_in_path() {
    if [ "$#" = "4" ]; then
        find "$2/" -path "*$3*" -name "$4" -type f 2>/dev/null | while read -r file; do
            lock_val "$1" "$file"
        done
    else
        find "$2/" -name "$3" -type f 2>/dev/null | while read -r file; do
            lock_val "$1" "$file"
        done
    fi
    return 0
}

get_memtotal_mb() {
    awk '/MemTotal:/ { print int($2 / 1024); exit }' /proc/meminfo 2>/dev/null
}

get_swaptotal_mb() {
    awk '/SwapTotal:/ { print int($2 / 1024); exit }' /proc/meminfo 2>/dev/null
}

apply_adaptive_vm_tunables() {
    local mem_mb swap_mb has_swap
    local stat_interval swappiness page_cluster vfs_cache_pressure
    local dirty_ratio dirty_background_ratio dirty_expire dirty_writeback

    mem_mb="$(get_memtotal_mb)"
    swap_mb="$(get_swaptotal_mb)"
    [ -n "$mem_mb" ] || mem_mb=0
    [ -n "$swap_mb" ] || swap_mb=0

    if [ "$swap_mb" -gt 0 ]; then
        has_swap=1
    else
        has_swap=0
    fi

    case "$mem_mb" in
        0)
            stat_interval=60
            swappiness=40
            page_cluster=1
            vfs_cache_pressure=100
            dirty_ratio=12
            dirty_background_ratio=5
            dirty_expire=2000
            dirty_writeback=3000
            ;;
        *)
            if [ "$mem_mb" -le 4096 ]; then
                stat_interval=30
                page_cluster=0
                vfs_cache_pressure=120
                dirty_ratio=8
                dirty_background_ratio=3
                dirty_expire=1000
                dirty_writeback=2000
                [ "$has_swap" = "1" ] && swappiness=70 || swappiness=35
            elif [ "$mem_mb" -le 6144 ]; then
                stat_interval=45
                page_cluster=0
                vfs_cache_pressure=110
                dirty_ratio=10
                dirty_background_ratio=4
                dirty_expire=1500
                dirty_writeback=2500
                [ "$has_swap" = "1" ] && swappiness=60 || swappiness=30
            elif [ "$mem_mb" -le 8192 ]; then
                stat_interval=60
                page_cluster=1
                vfs_cache_pressure=100
                dirty_ratio=12
                dirty_background_ratio=5
                dirty_expire=2000
                dirty_writeback=3000
                [ "$has_swap" = "1" ] && swappiness=50 || swappiness=25
            elif [ "$mem_mb" -le 12288 ]; then
                stat_interval=60
                page_cluster=2
                vfs_cache_pressure=90
                dirty_ratio=14
                dirty_background_ratio=6
                dirty_expire=2000
                dirty_writeback=3000
                [ "$has_swap" = "1" ] && swappiness=40 || swappiness=20
            else
                stat_interval=60
                page_cluster=3
                vfs_cache_pressure=80
                dirty_ratio=16
                dirty_background_ratio=8
                dirty_expire=3000
                dirty_writeback=5000
                [ "$has_swap" = "1" ] && swappiness=30 || swappiness=15
            fi
            ;;
    esac

    write "/proc/sys/vm/stat_interval" "$stat_interval"
    write "/proc/sys/vm/swappiness" "$swappiness"
    write "/proc/sys/vm/page-cluster" "$page_cluster"
    write "/proc/sys/vm/vfs_cache_pressure" "$vfs_cache_pressure"
    write "/proc/sys/vm/dirty_ratio" "$dirty_ratio"
    write "/proc/sys/vm/dirty_background_ratio" "$dirty_background_ratio"
    write "/proc/sys/vm/dirty_expire_centisecs" "$dirty_expire"
    write "/proc/sys/vm/dirty_writeback_centisecs" "$dirty_writeback"
    write "/proc/sys/vm/dirtytime_expire_seconds" "43200"
}
