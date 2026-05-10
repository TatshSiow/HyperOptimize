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

    : "${RUN_LOG:=/dev/null}"

    if [ ! -f "$file" ]; then
        [ "$HYPEROPTIMIZE_DEBUG" = "1" ] && echo "skip missing: $file" >> "$RUN_LOG"
        return 0
    fi

    if { echo "$@" > "$file"; } 2>/dev/null; then
        [ "$HYPEROPTIMIZE_DEBUG" = "1" ] && echo "write ok: $file <- $*" >> "$RUN_LOG"
    else
        [ "$HYPEROPTIMIZE_DEBUG" = "1" ] && echo "write failed: $file <- $*" >> "$RUN_LOG"
    fi

    return 0
}

write_if_writable() {
    local file="$1"
    shift

    : "${RUN_LOG:=/dev/null}"

    if [ ! -f "$file" ]; then
        [ "$HYPEROPTIMIZE_DEBUG" = "1" ] && echo "skip missing: $file" >> "$RUN_LOG"
        return 0
    fi

    if [ ! -w "$file" ]; then
        [ "$HYPEROPTIMIZE_DEBUG" = "1" ] && echo "skip readonly: $file" >> "$RUN_LOG"
        return 0
    fi

    write "$file" "$@"
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
        base="${path##*/}"
        for pattern in $debug_skip_path; do
            [ "$base" = "$pattern" ] && continue 2
        done
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

write_in_path() {
    local matches

    if [ "$#" = "4" ]; then
        matches="$(find "$2/" -path "*$3*" -name "$4" -type f 2>/dev/null)"
    else
        matches="$(find "$2/" -name "$3" -type f 2>/dev/null)"
    fi

    if [ -z "$matches" ]; then
        : "${RUN_LOG:=/dev/null}"
        [ "$HYPEROPTIMIZE_DEBUG" = "1" ] && echo "skip no match: $2 $3 ${4:-}" >> "$RUN_LOG"
        return 0
    fi

    echo "$matches" | while read -r file; do
        write "$file" "$1"
    done

    return 0
}

write_in_path_excluding() {
    local matches

    matches="$(find "$2/" -path "*$3*" ! -path "*$4*" -name "$5" -type f 2>/dev/null)"

    if [ -z "$matches" ]; then
        : "${RUN_LOG:=/dev/null}"
        [ "$HYPEROPTIMIZE_DEBUG" = "1" ] && echo "skip no match: $2 $3 ! $4 $5" >> "$RUN_LOG"
        return 0
    fi

    echo "$matches" | while read -r file; do
        write "$file" "$1"
    done

    return 0
}

write_in_path_if_writable() {
    local matches

    if [ "$#" = "4" ]; then
        matches="$(find "$2/" -path "*$3*" -name "$4" -type f 2>/dev/null)"
    else
        matches="$(find "$2/" -name "$3" -type f 2>/dev/null)"
    fi

    if [ -z "$matches" ]; then
        : "${RUN_LOG:=/dev/null}"
        [ "$HYPEROPTIMIZE_DEBUG" = "1" ] && echo "skip no match: $2 $3 ${4:-}" >> "$RUN_LOG"
        return 0
    fi

    echo "$matches" | while read -r file; do
        write_if_writable "$file" "$1"
    done

    return 0
}
