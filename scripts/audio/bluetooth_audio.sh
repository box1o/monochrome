#!/usr/bin/env bash

set -u

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/../.init.sh" || exit $?

script::init
script::parse "$@" || exit $?

if args::has help; then
    script::usage 'status|toggle'
    exit 0
fi

script::require_count 0 1 || exit $?

set -- "${SCRIPT_ARGS[@]}"

card_name() {
    exec::query pactl list cards short 2> /dev/null | exec::query awk '$2 ~ /^bluez_card/ { print $2; exit }'
}

card_block() {
    local card="$1"

    exec::query pactl list cards 2> /dev/null | exec::query sed -n "/^[[:space:]]*Name: ${card//./\.}$/,/^[[:space:]]*Name:/p" | exec::query sed '$d'
}

active_profile() {
    card_block "$1" | exec::query sed -n 's/^[[:space:]]*Active Profile: //p' | exec::query head -1
}

codec_from_profile() {
    local profile="$1"

    case "$profile" in
        *aac*) echo AAC ;;
        *opus*) echo Opus ;;
        *aptx*) echo aptX ;;
        *sbc_xq*) echo SBC-XQ ;;
        *msbc*) echo mSBC ;;
        *sbc*) echo SBC ;;
        *cvsd*) echo CVSD ;;
        *headset*) echo mSBC ;;
        *) echo "-" ;;
    esac
}

status() {
    local card profile mode codec
    card="$(card_name)"

    [ -n "$card" ] || {
        echo "connected=0"
        return 0
    }

    profile="$(active_profile "$card")"

    case "$profile" in
        headset-* | hsp* | hfp*) mode=call ;;
        a2dp-* | *) mode=music ;;
    esac

    codec="$(codec_from_profile "$profile")"

    printf 'connected=1\nmode=%s\ncodec=%s\n' "$mode" "$codec"
}

music_profile() {
    local block="$1" profile

    for profile in a2dp-sink-aac a2dp-sink-aptx a2dp-sink-opus_05 a2dp-sink-sbc_xq a2dp-sink; do
        if exec::query grep -q "^[[:space:]]*${profile}:" <<< "$block"; then
            echo "$profile"
            return 0
        fi
    done
    return 1
}

call_profile() {
    local block="$1" profile

    for profile in headset-head-unit-msbc headset-head-unit; do
        if exec::query grep -q "^[[:space:]]*${profile}:" <<< "$block"; then
            echo "$profile"
            return 0
        fi
    done
    return 1
}

bluetooth_mic_active() {
    local source_id
    source_id="$(exec::query pactl list sources short 2> /dev/null | exec::query awk '$2 ~ /^bluez_input/ {print $1; exit}')"

    [[ -n "$source_id" ]] || return 1

    exec::query pactl list source-outputs 2> /dev/null | exec::query grep -q "^[[:space:]]*Source: ${source_id}$"
}

toggle() {
    local card block current target
    card="$(card_name)"

    [ -n "$card" ] || {
        exec::run --quiet -- notify-send -a Mono "Bluetooth audio" "No Bluetooth audio device connected"
        return 1
    }

    block="$(card_block "$card")"
    current="$(active_profile "$card")"

    if [[ "$current" == headset-* || "$current" == hsp* || "$current" == hfp* ]]; then
        target="$(music_profile "$block")" || {
            exec::run --quiet -- notify-send -a Mono "Bluetooth audio" "No music profile is available"
            return 1
        }
    else
        target="$(call_profile "$block")" || {
            exec::run --quiet -- notify-send -a Mono "Bluetooth audio" "No microphone profile is available"
            return 1
        }
    fi

    # This is an explicit user choice. Keep WirePlumber from immediately
    # replacing it while an application creates or releases audio streams.
    exec::run --quiet -- wpctl settings bluetooth.autoswitch-to-headset-profile false > /dev/null 2>&1 || true
    exec::run --quiet -- pactl set-card-profile "$card" "$target"
    status
}

case "${1:-status}" in
    status) status ;;
    toggle) toggle ;;
    *) exit 2 ;;
esac
