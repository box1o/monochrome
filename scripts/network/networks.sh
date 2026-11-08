#!/usr/bin/env bash
# jq/awk expressions are intentionally not shell-expanded.
# shellcheck disable=SC2016

set -euo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/../.init.sh" || exit $?

script::init
script::parse "$@"
if args::has help; then
    script::usage 'INTERFACE'
    exit 0
fi
script::require_count 1 1
proc::require nmcli jq timeout

# nmcli escapes colons and backslashes, so IFS splitting would corrupt SSIDs.
networks::fields() {
    local line=$1 character escaped=false field="" index
    FIELDS=()
    for ((index=0; index<${#line}; index++)); do
        character=${line:index:1}
        if $escaped; then
            field+=$character
            escaped=false
        elif [[ $character == \\ ]]; then
            escaped=true
        elif [[ $character == : ]]; then
            FIELDS+=("$field")
            field=""
        else
            field+=$character
        fi
    done
    $escaped && field+="\\"
    FIELDS+=("$field")
}

interface=${SCRIPT_ARGS[0]}
declare -A saved=()
while IFS= read -r line; do
    networks::fields "$line"
    [[ ${#FIELDS[@]} == 2 && ${FIELDS[0]} == 802-11-wireless ]] || continue
    saved["${FIELDS[1]}"]=true
done < <(exec::query timeout 4 nmcli -t --escape yes -f TYPE,NAME connection show 2>/dev/null || true)

records=""
while IFS= read -r line; do
    networks::fields "$line"
    [[ ${#FIELDS[@]} == 4 && -n ${FIELDS[1]} && ${FIELDS[3]} =~ ^[0-9]+$ ]] || continue
    ssid=${FIELDS[1]//|/}
    [[ -n $ssid ]] || continue
    security=${FIELDS[2]:-open}
    security=${security,,}
    security=${security//|//}
    active=false
    [[ ${FIELDS[0]} != '*' ]] || active=true
    known=${saved[$ssid]:-false}
    records+=$(exec::query jq -cn --arg ssid "$ssid" --arg security "$security" --argjson signal "${FIELDS[3]}" --argjson active "$active" --argjson known "$known" '{ssid:$ssid,security:$security,signal:$signal,active:$active,known:$known}')$'\n'
done < <(exec::query timeout 4 nmcli -t --escape yes -f IN-USE,SSID,SECURITY,SIGNAL device wifi list ifname "$interface" 2>/dev/null || true)

exec::query jq -rsr '
    group_by(.ssid) | map(max_by([.active, .signal])) | sort_by([.active, .signal]) | reverse | .[]
    | [(if .active then "yes" else "no" end),.ssid,.security,(.signal|tostring),(if .known then "yes" else "no" end)] | join("|")
' <<<"$records"
