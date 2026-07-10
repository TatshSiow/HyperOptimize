#!/system/bin/sh
MODDIR="${0%/*}"
. "$MODDIR/scripts/lib.sh"
RUN_LOG="$MODDIR/config/hyperoptimize.log"
RUN_LOCK="$MODDIR/config/service.lock"
HYPEROPTIMIZE_DEBUG=1
export RUN_LOG HYPEROPTIMIZE_DEBUG

load_user_options() {
    ENABLE_PERFORMANCE_TUNING=0

    if [ -f "$MODDIR/config/user_options" ]; then
        . "$MODDIR/config/user_options"
    fi
}

run_script() {
    local script="$1"
    local name code

    [ -f "$script" ] || return 0
    name="${script##*/}"

    if [ "$name" = "04-performance.sh" ] && [ "$ENABLE_PERFORMANCE_TUNING" != "1" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') skip $name disabled by user option" >> "$RUN_LOG"
        return 0
    fi

    echo "$(date '+%Y-%m-%d %H:%M:%S') start $name" >> "$RUN_LOG"
    sh "$script" >> "$RUN_LOG" 2>&1
    code="$?"
    echo "$(date '+%Y-%m-%d %H:%M:%S') end $name rc=$code" >> "$RUN_LOG"
    return "$code"
}

mkdir -p "$MODDIR/config"
if ! mkdir "$RUN_LOCK" 2>/dev/null; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') service already running" >> "$RUN_LOG"
    exit 0
fi
trap 'rmdir "$RUN_LOCK" 2>/dev/null' EXIT

: > "$RUN_LOG"
echo "$(date '+%Y-%m-%d %H:%M:%S') service start" >> "$RUN_LOG"
load_user_options
echo "$(date '+%Y-%m-%d %H:%M:%S') option ENABLE_PERFORMANCE_TUNING=$ENABLE_PERFORMANCE_TUNING" >> "$RUN_LOG"

if [ "$HYPEROPTIMIZE_SKIP_WAIT" = "1" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') boot wait skipped" >> "$RUN_LOG"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') boot wait start" >> "$RUN_LOG"
    wait_until_login
    sleep 30
    echo "$(date '+%Y-%m-%d %H:%M:%S') boot wait end" >> "$RUN_LOG"
fi

for script in "$MODDIR"/scripts/[0-9][0-9]-*.sh; do
    run_script "$script"
done

echo "$(date '+%Y-%m-%d %H:%M:%S') service end" >> "$RUN_LOG"
exit 0
