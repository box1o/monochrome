#!/usr/bin/env bash
set -uo pipefail

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/mono-$UID}"
install -d -m 0700 -- "$RUNTIME_DIR"
CACHE="$RUNTIME_DIR/mono-brightness.map"

MIN=1
MAX=100

have() { command -v "$1" >/dev/null 2>&1; }

has_battery() {
    local d
    for d in /sys/class/power_supply/*; do
        [ -r "$d/type" ] || continue
        [ "$(cat "$d/type" 2>/dev/null)" = "Battery" ] && return 0
    done
    return 1
}

has_touchpad() {
    have hyprctl || return 1
    hyprctl -j devices 2>/dev/null | grep -qiE '"name": *"[^"]*(touchpad|synaptics|trackpad)' && return 0
    grep -qiE 'touchpad|synaptics' /proc/bus/input/devices 2>/dev/null
}

backlight_dev() {
    local d
    for d in /sys/class/backlight/*; do
        [ -d "$d" ] || continue
        basename "$d"; return 0
    done
    return 1
}

backend() {
    backlight_dev >/dev/null 2>&1 && { echo backlight; return; }
    have ddcutil && compgen -G '/dev/i2c-*' >/dev/null && { echo ddc; return; }
    echo none
}

cmd_detect() {
    local b; b="$(backend)"
    echo "backend=$b"
    if has_battery; then echo "battery=1"; echo "chassis=laptop"
    else echo "battery=0"; echo "chassis=desktop"; fi
    has_touchpad && echo "touchpad=1" || echo "touchpad=0"
    have ddcutil && echo "ddcutil=1" || echo "ddcutil=0"
}

# ------------------------------------------------------------------- backlight
bl_get() { brightnessctl -d "$1" -m 2>/dev/null | LC_ALL=C awk -F, '{gsub("%","",$4); print $4}'; }
bl_set() { brightnessctl -d "$1" -q s "$2%" 2>/dev/null; }

# ------------------------------------------------------------------------- DDC
ddc_scan() {
    local bus="" conn=""
    timeout --signal=KILL 8 ddcutil detect --brief 2>/dev/null | while IFS= read -r line; do
        case "$line" in
            *"I2C bus:"*)       bus="${line##*/dev/i2c-}" ;;
            *"DRM connector:"*)
                conn="${line##*: }"
                conn="$(echo "$conn" | tr -d ' \t')"
                # card1-HDMI-A-1 → HDMI-A-1
                conn="${conn#card*-}"
                [ -n "$bus" ] && [ -n "$conn" ] && printf '%s\t%s\n' "$bus" "$conn"
                bus=""; conn=""
                ;;
        esac
    done
}

ddc_map() {
    if [ ! -s "$CACHE" ]; then
        local pending
        pending="$(mktemp "$CACHE.XXXXXX")" || return 1
        if ddc_scan > "$pending" 2>/dev/null; then
            mv -f -- "$pending" "$CACHE"
        else
            rm -f -- "$pending"
            return 1
        fi
    fi
    cat "$CACHE" 2>/dev/null
}

ddc_get() {
    timeout --signal=KILL 3 ddcutil --bus "$1" getvcp 10 --brief 2>/dev/null \
        | LC_ALL=C awk '{print $4}'
}
ddc_set() { timeout --signal=KILL 3 ddcutil --bus "$1" setvcp 10 "$2" >/dev/null 2>&1; }

clamp() {
    local p="$1"
    [[ $p =~ ^[0-9]+$ ]] || return 2
    p=$((10#$p))
    [ "$p" -lt "$MIN" ] && p="$MIN"
    [ "$p" -gt "$MAX" ] && p="$MAX"
    echo "$p"
}

cmd_list() {
    case "$(backend)" in
        backlight)
            local d; d="$(backlight_dev)" || return 0
            printf 'bl:%s\t%s\t%s\n' "$d" "$(tr -d '\n' <<<"${DISPLAY_LABEL:-Built-in display}")" "$(bl_get "$d")"
            ;;
        ddc)
            local bus conn pct
            while IFS=$'\t' read -r bus conn; do
                [ -n "$bus" ] || continue
                pct="$(ddc_get "$bus")"
                [ -n "$pct" ] || continue
                printf 'ddc:%s\t%s\t%s\n' "$bus" "$conn" "$pct"
            done < <(ddc_map)
            ;;
    esac
}

cmd_set() {
    local id="${1:-}" pct
    pct="$(clamp "${2:-}")" || return 2
    case "$id" in
        bl:*)  bl_set "${id#bl:}" "$pct" ;;
        ddc:*) ddc_set "${id#ddc:}" "$pct" ;;
        *) return 2 ;;
    esac
    echo "$pct"
}

case "${1:-}" in
    detect)  cmd_detect ;;
    list)    cmd_list ;;
    rescan)  rm -f "$CACHE"; ddc_map >/dev/null; cmd_list ;;
    set)     cmd_set "${2:-}" "${3:-0}" ;;
    *)       printf 'usage: %s detect|list|rescan|set ID PERCENT\n' "${0##*/}" >&2; exit 2 ;;
esac
