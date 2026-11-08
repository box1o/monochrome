#!/usr/bin/env bash
# jq/awk expressions are intentionally not shell-expanded.
# shellcheck disable=SC2016

set -uo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/../.init.sh" || exit $?

script::init
script::parse "$@" || exit $?

if args::has help; then
    script::usage 'status|list|scan|toggle|connect SSID [PASSWORD]|disconnect|forget SSID'
    exit 0
fi

script::require_count 1 3 || exit $?

set -- "${SCRIPT_ARGS[@]}"

TIMEOUT=(timeout --signal=KILL)
SCRIPT_DIR="$(path::absolute "${BASH_SOURCE[0]%/*}")"

usage() {
    script::usage 'status|list|scan|toggle|connect SSID [PASSWORD]|disconnect|forget SSID' >&2
}

wifi_iface() {
    if [[ -n ${WIFI_IFACE:-} ]]; then
        printf '%s\n' "$WIFI_IFACE"
        return
    fi

    exec::query "${TIMEOUT[@]}" 2 nmcli -t -f DEVICE,TYPE device status 2> /dev/null |
        exec::query awk -F: '$2 == "wifi" && $1 !~ /^p2p-/ { print $1; exit }'
}

IFACE="$(wifi_iface)"

require_iface() {
    if [[ -z $IFACE ]]; then
        log::error 'No Wi-Fi interface found'
        exit 1
    fi
}

radio_state() {
    [[ $(exec::query "${TIMEOUT[@]}" 2 nmcli radio wifi 2> /dev/null) == enabled ]] &&
        printf 'on\n' || printf 'off\n'
}

current_ssid() {
    require_iface

    local name
    name="$(exec::query "${TIMEOUT[@]}" 2 nmcli -g GENERAL.CONNECTION device show "$IFACE" 2> /dev/null)"

    [[ $name == -- ]] && name=""

    printf '%s' "$name"
}

current_quality() {
    require_iface
    exec::query "${TIMEOUT[@]}" 2 nmcli -t -f IN-USE,SIGNAL device wifi list ifname "$IFACE" 2> /dev/null |
        exec::query awk -F: '$1 == "*" { print $2; found=1; exit } END { if (!found) print 0 }'
}

list_networks() {
    require_iface
    exec::query bash "$SCRIPT_DIR/networks.sh" "$IFACE"
}

case "${1:-}" in
    status)
        printf '%s|%s|%s\n' "$(radio_state)" "$(current_ssid)" "$(current_quality)"
        ;;
    list)
        list_networks
        ;;
    scan)
        require_iface
        exec::run --quiet -- "${TIMEOUT[@]}" 15 nmcli device wifi rescan ifname "$IFACE" > /dev/null
        ;;
    toggle)
        if [[ $(radio_state) == on ]]; then
            exec::run --quiet -- nmcli radio wifi off
        else
            exec::run --quiet -- nmcli radio wifi on
        fi
        ;;
    connect)
        require_iface

        ssid="${2:-}"
        password="${3:-}"

        [[ -n $ssid ]] || {
            usage
            exit 2
        }

        command=(nmcli device wifi connect "$ssid" ifname "$IFACE")

        [[ -n $password ]] && command+=(password "$password")

        exec::run --quiet --info "Connect Wi-Fi network" -- "${TIMEOUT[@]}" 30 "${command[@]}" > /dev/null
        ;;
    disconnect)
        require_iface
        exec::run --quiet -- "${TIMEOUT[@]}" 10 nmcli device disconnect "$IFACE" > /dev/null
        ;;
    forget)
        ssid="${2:-}"

        [[ -n $ssid ]] || {
            usage
            exit 2
        }

        exec::run --quiet -- "${TIMEOUT[@]}" 10 nmcli connection delete id "$ssid" > /dev/null
        ;;
    *)
        usage
        exit 2
        ;;
esac
