#!/system/bin/sh

# Restore DropboxManager defaults for the current boot session when possible.
cmd dropbox restore-defaults >/dev/null 2>&1

# Re-enable framework looper statistics collection when supported.
cmd looper_stats enable >/dev/null 2>&1

# Restore runtime diagnostic defaults observed on stock configuration.
cmd settings delete system anr_debugging_mechanism >/dev/null 2>&1
cmd device_config delete runtime_native_boot iorap_perfetto_enable >/dev/null 2>&1

# Don't modify anything after this
if [ -f "$INFO" ]; then
  while read LINE; do
    if [ "$(echo -n "$LINE" | tail -c 1)" == "~" ]; then
      continue
    elif [ -f "$LINE~" ]; then
      mv -f "$LINE~" "$LINE"
    else
      rm -f "$LINE"
      while true; do
        LINE=$(dirname "$LINE")
        [ "$(ls -A "$LINE" 2>/dev/null)" ] && break 1 || rm -rf "$LINE"
      done
    fi
  done < "$INFO"
  rm -f "$INFO"
fi
