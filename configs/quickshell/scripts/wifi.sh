#!/usr/bin/env bash
set -uo pipefail

TIMEOUT=(timeout --signal=KILL)
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

usage() {
    printf 'usage: %s status|list|scan|toggle|connect SSID [PASSWORD]|disconnect|forget SSID\n' "${0##*/}" >&2
}

wifi_iface() {
    if [[ -n ${WIFI_IFACE:-} ]]; then
        printf '%s\n' "$WIFI_IFACE"
        return
    fi
    "${TIMEOUT[@]}" 2 nmcli -t -f DEVICE,TYPE device status 2>/dev/null \
        | awk -F: '$2 == "wifi" && $1 !~ /^p2p-/ { print $1; exit }'
}

IFACE="$(wifi_iface)"

require_iface() {
    if [[ -z $IFACE ]]; then
        printf 'no Wi-Fi interface found\n' >&2
        exit 1
    fi
}

radio_state() {
    [[ $("${TIMEOUT[@]}" 2 nmcli radio wifi 2>/dev/null) == enabled ]] \
        && printf 'on\n' || printf 'off\n'
}

current_ssid() {
    require_iface
    local name
    name="$("${TIMEOUT[@]}" 2 nmcli -g GENERAL.CONNECTION device show "$IFACE" 2>/dev/null)"
    [[ $name == -- ]] && name=""
    printf '%s' "$name"
}

current_quality() {
    require_iface
    "${TIMEOUT[@]}" 2 nmcli -t -f IN-USE,SIGNAL device wifi list ifname "$IFACE" 2>/dev/null \
        | awk -F: '$1 == "*" { print $2; found=1; exit } END { if (!found) print 0 }'
}

list_networks() {
    require_iface
    python3 "$SCRIPT_DIR/wifi_networks.py" "$IFACE"
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
        "${TIMEOUT[@]}" 15 nmcli device wifi rescan ifname "$IFACE" >/dev/null
        ;;
    toggle)
        if [[ $(radio_state) == on ]]; then
            nmcli radio wifi off
        else
            nmcli radio wifi on
        fi
        ;;
    connect)
        require_iface
        ssid="${2:-}"
        password="${3:-}"
        [[ -n $ssid ]] || { usage; exit 2; }
        command=(nmcli device wifi connect "$ssid" ifname "$IFACE")
        [[ -n $password ]] && command+=(password "$password")
        "${TIMEOUT[@]}" 30 "${command[@]}" >/dev/null
        ;;
    disconnect)
        require_iface
        "${TIMEOUT[@]}" 10 nmcli device disconnect "$IFACE" >/dev/null
        ;;
    forget)
        ssid="${2:-}"
        [[ -n $ssid ]] || { usage; exit 2; }
        "${TIMEOUT[@]}" 10 nmcli connection delete id "$ssid" >/dev/null
        ;;
    *)
        usage
        exit 2
        ;;
esac
