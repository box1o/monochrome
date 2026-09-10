#!/usr/bin/env bash
set -u

have() { command -v "$1" >/dev/null 2>&1; }

card_name() {
    pactl list cards short 2>/dev/null | awk '$2 ~ /^bluez_card/ { print $2; exit }'
}

card_block() {
    local card="$1"
    pactl list cards 2>/dev/null | sed -n "/^[[:space:]]*Name: ${card//./\.}$/,/^[[:space:]]*Name:/p" | sed '$d'
}

active_profile() {
    card_block "$1" | sed -n 's/^[[:space:]]*Active Profile: //p' | head -1
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
    [ -n "$card" ] || { echo "connected=0"; return 0; }
    profile="$(active_profile "$card")"
    case "$profile" in
        headset-*|hsp*|hfp*) mode=call ;;
        a2dp-*|*) mode=music ;;
    esac
    codec="$(codec_from_profile "$profile")"
    printf 'connected=1\nmode=%s\ncodec=%s\nprofile=%s\n' "$mode" "$codec" "$profile"
}

music_profile() {
    local block="$1" profile
    for profile in a2dp-sink-aac a2dp-sink-aptx a2dp-sink-opus_05 a2dp-sink-sbc_xq a2dp-sink; do
        if grep -q "^[[:space:]]*${profile}:" <<<"$block"; then
            echo "$profile"; return 0
        fi
    done
    return 1
}

call_profile() {
    local block="$1" profile
    for profile in headset-head-unit-msbc headset-head-unit; do
        if grep -q "^[[:space:]]*${profile}:" <<<"$block"; then
            echo "$profile"; return 0
        fi
    done
    return 1
}

toggle() {
    local card block current target
    card="$(card_name)"
    [ -n "$card" ] || { notify-send -a Mono "Bluetooth audio" "No Bluetooth audio device connected"; return 1; }
    block="$(card_block "$card")"
    current="$(active_profile "$card")"
    if [[ "$current" == headset-* || "$current" == hsp* || "$current" == hfp* ]]; then
        target="$(music_profile "$block")" || { notify-send -a Mono "Bluetooth audio" "No music profile is available"; return 1; }
    else
        target="$(call_profile "$block")" || { notify-send -a Mono "Bluetooth audio" "No microphone profile is available"; return 1; }
    fi
    pactl set-card-profile "$card" "$target"
    status
}

auto() {
    local card block target
    card="$(card_name)"; [ -n "$card" ] || return 0
    block="$(card_block "$card")"
    if pactl list source-outputs 2>/dev/null | grep -qi 'bluez'; then
        target="$(call_profile "$block")" || return 0
    else
        target="$(music_profile "$block")" || return 0
    fi
    pactl set-card-profile "$card" "$target" >/dev/null 2>&1 || true
}

case "${1:-status}" in
    status) status ;;
    toggle) toggle ;;
    auto) auto ;;
    *) exit 2 ;;
esac
