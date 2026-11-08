#!/usr/bin/env bash

set -uo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/../.init.sh" || exit $?

script::init
script::parse "$@" || exit $?

if args::has help; then
    script::usage 'detect|list|rescan|set ID PERCENT'
    exit 0
fi

script::require_count 1 3 || exit $?

set -- "${SCRIPT_ARGS[@]}"

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/mono-$UID}"
CACHE="$RUNTIME_DIR/mono-brightness.map"

MIN=1
MAX=100

has_battery() {
    local d

    for d in /sys/class/power_supply/*; do
        [ -r "$d/type" ] || continue
        [ "$(exec::query cat "$d/type" 2> /dev/null)" = "Battery" ] && return 0
    done
    return 1
}

has_touchpad() {
    proc::exists hyprctl || return 1
    exec::query hyprctl -j devices 2> /dev/null | exec::query grep -qiE '"name": *"[^"]*(touchpad|synaptics|trackpad)' && return 0
    exec::query grep -qiE 'touchpad|synaptics' /proc/bus/input/devices 2> /dev/null
}

backlight_dev() {
    local d

    for d in /sys/class/backlight/*; do
        [ -d "$d" ] || continue
        path::basename "$d"
        return 0
    done
    return 1
}

backend() {
    backlight_dev > /dev/null 2>&1 && {
        echo backlight
        return
    }
    proc::exists ddcutil && compgen -G '/dev/i2c-*' > /dev/null && {
        echo ddc
        return
    }

    echo none
}

cmd_detect() {
    local b
    b="$(backend)"

    echo "backend=$b"

    if has_battery; then
        echo "battery=1"
        echo "chassis=laptop"
    else
        echo "battery=0"
        echo "chassis=desktop"
    fi

    has_touchpad && echo "touchpad=1" || echo "touchpad=0"
    proc::exists ddcutil && echo "ddcutil=1" || echo "ddcutil=0"
}

# ------------------------------------------------------------------- backlight
# awk fields are evaluated by awk, not Bash.
# shellcheck disable=SC2016
bl_get() { exec::query brightnessctl -d "$1" -m 2> /dev/null | LC_ALL=C exec::query awk -F, '{gsub("%","",$4); print $4}'; }

bl_set() { exec::run --quiet -- brightnessctl -d "$1" -q s "$2%" 2> /dev/null; }

# ------------------------------------------------------------------------- DDC
ddc_scan() {
    local bus="" conn=""

    exec::query timeout --signal=KILL 8 ddcutil detect --brief 2> /dev/null | while IFS= read -r line; do
        case "$line" in
            *"I2C bus:"*) bus="${line##*/dev/i2c-}" ;;
            *"DRM connector:"*)
                conn="${line##*: }"
                conn="$(echo "$conn" | exec::query tr -d ' \t')"
                # card1-HDMI-A-1 → HDMI-A-1
                conn="${conn#card*-}"

                [ -n "$bus" ] && [ -n "$conn" ] && printf '%s\t%s\n' "$bus" "$conn"

                bus=""
                conn=""
                ;;
        esac
    done
}

ddc_map() {
    if [[ ${SHELL_LIB_DRY_RUN:-false} == true ]]; then
        log::info "DRY-RUN refresh brightness cache: $CACHE"
        return 0
    fi

    if ! fs::is_dir "$RUNTIME_DIR"; then
        fs::mkdir "$RUNTIME_DIR" || return
        fs::chmod 0700 "$RUNTIME_DIR" || return
    fi

    if [ ! -s "$CACHE" ]; then
        local pending
        pending="$(temp::file mono-brightness "$RUNTIME_DIR")" || return 1

        if ddc_scan > "$pending" 2> /dev/null; then
            fs::move "$pending" "$CACHE"
        else
            fs::remove_file "$pending"
            return 1
        fi
    fi

    fs::read "$CACHE" 2> /dev/null
}

# shellcheck disable=SC2016
ddc_get() {
    exec::query timeout --signal=KILL 3 ddcutil --bus "$1" getvcp 10 --brief 2> /dev/null |
        LC_ALL=C exec::query awk '$3 == "C" && $5 > 0 { printf "%.0f\n", $4 / $5 * 100 }'
}

# shellcheck disable=SC2016
ddc_set() {
    local maximum value
    maximum=$(exec::query timeout --signal=KILL 3 ddcutil --bus "$1" getvcp 10 --brief 2> /dev/null |
        LC_ALL=C exec::query awk '$3 == "C" { print $5 }') || return
    [[ $maximum =~ ^[0-9]+$ && $maximum -gt 0 ]] || return 1
    value=$((($2 * maximum + 50) / 100))
    exec::run --quiet -- timeout --signal=KILL 3 ddcutil --bus "$1" setvcp 10 "$value" > /dev/null 2>&1
}

clamp() {
    local p="$1"

    [[ $p =~ ^[0-9]+$ ]] || return 2

    p=$((10#$p))

    [ "$p" -lt "$MIN" ] && p="$MIN"
    [ "$p" -gt "$MAX" ] && p="$MAX"

    echo "$p"
}

cmd_list() {
    local d bus conn pct

    if d="$(backlight_dev)"; then
        printf 'bl:%s\t%s\t%s\n' "$d" "${DISPLAY_LABEL:-Built-in display}" "$(bl_get "$d")"
    fi

    proc::exists ddcutil || return 0

    while IFS=$'\t' read -r bus conn; do
        [[ -n "$bus" ]] || continue
        pct="$(ddc_get "$bus")" || continue
        [[ -n "$pct" ]] || continue
        printf 'ddc:%s\t%s\t%s\n' "$bus" "$conn" "$pct"
    done < <(ddc_map)
}

cmd_set() {
    local id="${1:-}" pct
    pct="$(clamp "${2:-}")" || return 2

    case "$id" in
        bl:*) bl_set "${id#bl:}" "$pct" || return ;;
        ddc:*) ddc_set "${id#ddc:}" "$pct" || return ;;
        *) return 2 ;;
    esac

    echo "$pct"
}

case "${1:-}" in
    detect) cmd_detect ;;
    list) cmd_list ;;
    rescan)
        fs::remove_file "$CACHE"
        ddc_map > /dev/null
        cmd_list
        ;;
    set) cmd_set "${2:-}" "${3:-0}" ;;
    *) log::fatal --code 2 'Expected detect, list, rescan, or set ID PERCENT' ;;
esac
