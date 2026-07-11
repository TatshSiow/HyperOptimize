#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
STATE_DIR=${HYPEROPTIMIZE_STATE_DIR:-/data/adb/hyperoptimize-state}
APPLY_APPLIED=0
APPLY_UNCHANGED=0
APPLY_SKIPPED=0
APPLY_FAILED=0

apply_count() {
    case "$1" in
        applied) APPLY_APPLIED=$((APPLY_APPLIED+1)) ;;
        unchanged) APPLY_UNCHANGED=$((APPLY_UNCHANGED+1)) ;;
        skipped) APPLY_SKIPPED=$((APPLY_SKIPPED+1)) ;;
        failed) APPLY_FAILED=$((APPLY_FAILED+1)) ;;
    esac
}

hyperoptimize_summary() {
    line="apply-summary script=${0##*/} applied=$APPLY_APPLIED unchanged=$APPLY_UNCHANGED skipped=$APPLY_SKIPPED failed=$APPLY_FAILED"
    if [ -n "${RUN_LOG:-}" ] && [ "${RUN_LOG:-/dev/null}" != /dev/null ]; then
        printf '%s\n' "$line" >> "$RUN_LOG"
    else
        printf '%s\n' "$line"
    fi
}
trap hyperoptimize_summary EXIT

state_init() {
    mkdir -p "$STATE_DIR" 2>/dev/null || return 1
    chmod 0700 "$STATE_DIR" 2>/dev/null
    return 0
}

ledger_has() {
    [ -f "$1" ] && awk -F '|' -v key="$2" '$1 == key { found=1 } END { exit !found }' "$1"
}

record_file_state() {
    ledger="$STATE_DIR/files"
    ledger_has "$ledger" "$1" && return 0
    state_init || return 1
    printf '%s|%s\n' "$1" "$2" >> "$ledger" || return 1
    chmod 0600 "$ledger" 2>/dev/null
}

prop_exists() { resetprop "$1" >/dev/null 2>&1; }

record_prop_state() {
    ledger="$STATE_DIR/props"
    ledger_has "$ledger" "$1" && return 0
    state_init || return 1
    printf '%s|%s|%s\n' "$1" "$2" "$3" >> "$ledger" || return 1
    chmod 0600 "$ledger" 2>/dev/null
}

record_setting_state() {
    key="$1|$2"; ledger="$STATE_DIR/settings"
    [ -f "$ledger" ] && awk -F '|' -v ns="$1" -v name="$2" '$1 == ns && $2 == name { found=1 } END { exit !found }' "$ledger" && return 0
    state_init || return 1
    printf '%s|%s|%s|%s\n' "$1" "$2" "$3" "$4" >> "$ledger" || return 1
    chmod 0600 "$ledger" 2>/dev/null
}

record_service_state() {
    ledger="$STATE_DIR/services"
    ledger_has "$ledger" "$1" && return 0
    state_init || return 1
    printf '%s|%s\n' "$1" "$2" >> "$ledger" || return 1
    chmod 0600 "$ledger" 2>/dev/null
}

wait_until_login() {
    while [ "$(getprop sys.boot_completed)" != 1 ]; do sleep 3; done
    test_file=/storage/emulated/0/Android/.PERMISSION_TEST
    true > "$test_file"
    while [ ! -f "$test_file" ]; do true > "$test_file"; sleep 1; done
    rm -f "$test_file"
}

write() {
    file="$1"; shift; target="$*"
    : "${RUN_LOG:=/dev/null}"
    if [ ! -f "$file" ]; then
        apply_count skipped
        [ "${HYPEROPTIMIZE_DEBUG:-0}" = 1 ] && echo "skip missing: $file" >> "$RUN_LOG"
        return 0
    fi
    current=$(cat "$file" 2>/dev/null) || { apply_count failed; return 0; }
    [ "$current" = "$target" ] && { apply_count unchanged; return 0; }
    record_file_state "$file" "$current" || { apply_count failed; return 0; }
    if { printf '%s\n' "$target" > "$file"; } 2>/dev/null && [ "$(cat "$file" 2>/dev/null)" = "$target" ]; then
        apply_count applied
        [ "${HYPEROPTIMIZE_DEBUG:-0}" = 1 ] && echo "write ok: $file <- $target" >> "$RUN_LOG"
    else
        apply_count failed
        [ "${HYPEROPTIMIZE_DEBUG:-0}" = 1 ] && echo "write failed: $file <- $target" >> "$RUN_LOG"
    fi
    return 0
}

write_if_writable() {
    file="$1"; shift
    [ -f "$file" ] || { apply_count skipped; return 0; }
    [ -w "$file" ] || { apply_count skipped; return 0; }
    write "$file" "$@"
}

normalize_toggle() {
    case "$1" in
        1) echo 0 ;; Y) echo N ;; enabled) echo disabled ;; on) echo off ;;
        *[!0-9]*|'') return 1 ;;
        *) echo 0 ;;
    esac
}

apply_toggle() {
    path="$1"
    [ -f "$path" ] || { apply_count skipped; return 0; }
    value=$(cat "$path" 2>/dev/null) || { apply_count failed; return 0; }
    target=$(normalize_toggle "$value") || { apply_count skipped; return 0; }
    write "$path" "$target"
}

write_in_path() {
    value="$1"; root="$2"; pattern="$3"; contains=${4:-}
    if [ -n "$contains" ]; then
        matches=$(find "$root/" -path "*$pattern*" -name "$contains" -type f 2>/dev/null)
    else
        matches=$(find "$root/" -name "$pattern" -type f 2>/dev/null)
    fi
    [ -n "$matches" ] || { apply_count skipped; return 0; }
    for file in $matches; do write "$file" "$value"; done
}

write_in_path_if_writable() {
    value="$1"; root="$2"; pattern="$3"; contains=${4:-}
    if [ -n "$contains" ]; then
        matches=$(find "$root/" -path "*$pattern*" -name "$contains" -type f 2>/dev/null)
    else
        matches=$(find "$root/" -name "$pattern" -type f 2>/dev/null)
    fi
    [ -n "$matches" ] || { apply_count skipped; return 0; }
    for file in $matches; do write_if_writable "$file" "$value"; done
}

run_cmd() {
    if "$@" >/dev/null 2>&1; then apply_count applied; else apply_count failed; fi
    return 0
}

setprop_value() {
    prop="$1"; target="$2"
    if prop_exists "$prop"; then had=1; current=$(resetprop "$prop" 2>/dev/null); else had=0; current=; fi
    [ "$had" = 1 ] && [ "$current" = "$target" ] && { apply_count unchanged; return 0; }
    record_prop_state "$prop" "$had" "$current" || { apply_count failed; return 0; }
    if resetprop "$prop" "$target" >/dev/null 2>&1 && [ "$(resetprop "$prop" 2>/dev/null)" = "$target" ]; then
        apply_count applied
    else
        apply_count failed
    fi
}

setprop_if_present() {
    prop_exists "$1" || { apply_count skipped; return 0; }
    setprop_value "$1" "$2"
}

setting_put() {
    namespace="$1"; name="$2"; target="$3"
    current=$(cmd settings get "$namespace" "$name" 2>/dev/null)
    [ "$current" = "$target" ] && { apply_count unchanged; return 0; }
    [ "$current" = null ] && had=0 || had=1
    record_setting_state "$namespace" "$name" "$had" "$current" || { apply_count failed; return 0; }
    if cmd settings put "$namespace" "$name" "$target" >/dev/null 2>&1 && [ "$(cmd settings get "$namespace" "$name" 2>/dev/null)" = "$target" ]; then
        apply_count applied
    else
        apply_count failed
    fi
}

setting_put_if_present() {
    current=$(cmd settings get "$1" "$2" 2>/dev/null)
    [ -n "$current" ] && [ "$current" != null ] || { apply_count skipped; return 0; }
    setting_put "$1" "$2" "$3"
}

stop_service_if_running() {
    name="$1"; state=$(getprop "init.svc.$name")
    case "$state" in
        running|restarting)
            record_service_state "$name" "$state" || { apply_count failed; return 0; }
            if stop "$name" >/dev/null 2>&1; then apply_count applied; else apply_count failed; fi
            ;;
        stopped) apply_count unchanged ;;
        *) apply_count skipped ;;
    esac
}
