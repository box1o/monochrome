#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
QML="$SCRIPT_DIR/../lock.qml"

LOG="${XDG_CACHE_HOME:-$HOME/.cache}/mono/lock.log"
mkdir -p "$(dirname "$LOG")" 2>/dev/null
log() { printf '%s %s\n' "$(date +%H:%M:%S)" "$1" >> "$LOG"; }
: > "$LOG" 2>/dev/null
log "starting"

if pgrep -af '(^|/)(qs|quickshell).*--path .*lock\.qml' >/dev/null; then
    log "already running"
    exit 0
fi

wallpaper=$(grep -m1 '^[[:space:]]*path[[:space:]]*=' "$HOME/.config/hypr/hyprpaper.conf" 2>/dev/null \
            | cut -d= -f2- | sed 's/^ *//; s/ *$//')
wallpaper="${wallpaper/#\~/$HOME}"

if [ -n "$wallpaper" ] && [ "$wallpaper" != "black" ] && [ -f "$wallpaper" ]; then
    export MONO_LOCK_BG="$wallpaper"
fi
log "background=${MONO_LOCK_BG:-none}"
if ! command -v quickshell >/dev/null 2>&1; then
    log "quickshell not found"
    exit 127
fi

export QSG_RENDER_LOOP="${QSG_RENDER_LOOP:-threaded}"

log "launching $QML"
exec quickshell --path "$QML" 2>>"$LOG"
