#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

####################################
# Runtime Framework Config
####################################

run_cmd() {
    "$@" >/dev/null 2>&1
    local code="$?"

    : "${RUN_LOG:=/dev/null}"
    if [ "$HYPEROPTIMIZE_DEBUG" = "1" ]; then
        if [ "$code" = "0" ]; then
            echo "cmd ok: $*" >> "$RUN_LOG"
        else
            echo "cmd failed($code): $*" >> "$RUN_LOG"
        fi
    fi

    return 0
}

log_get() {
    local label="$1"
    shift

    : "${RUN_LOG:=/dev/null}"
    [ "$HYPEROPTIMIZE_DEBUG" = "1" ] && echo "cmd value: $label=$("$@" 2>/dev/null)" >> "$RUN_LOG"
    return 0
}

# Keep DropboxManager alive but reduce low-priority broadcast spam.
run_cmd cmd dropbox set-rate-limit 10000

# Disable framework looper statistics collection when the shell service exists.
run_cmd cmd looper_stats disable

# Reduce framework/runtime diagnostics overhead where supported.
run_cmd cmd settings put system anr_debugging_mechanism 0
run_cmd cmd device_config put runtime_native_boot iorap_perfetto_enable false

log_get "settings.system.anr_debugging_mechanism" cmd settings get system anr_debugging_mechanism
log_get "device_config.runtime_native_boot.iorap_perfetto_enable" cmd device_config get runtime_native_boot iorap_perfetto_enable
