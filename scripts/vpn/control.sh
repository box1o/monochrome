#!/usr/bin/env bash
# jq variables are intentionally evaluated by jq, not Bash.
# shellcheck disable=SC2016
set -euo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/../.init.sh" || exit $?
script::init
script::parse "$@" || exit $?

if args::has help; then
    script::usage 'list|snapshot|connect ID|disconnect ID|setting NAME VALUE|ping ADDRESS'
    exit 0
fi

script::require_count 1 3 || exit $?
set -- "${SCRIPT_ARGS[@]}"

vpn::list() {
    local result='[]' state active uuid type name connected
    if proc::exists tailscale; then
        state=$(exec::query timeout 4 tailscale status --json 2>/dev/null) || state='{}'
        result=$(exec::query jq -cn --argjson state "$state" '[{id:"tailscale", name:"Tailscale", icon:"tailscale", connected:($state.BackendState == "Running"), detail:($state.TailscaleIPs[0] // $state.BackendState // "Service unavailable")}]')
    fi
    if proc::exists nmcli; then
        active=$(exec::query nmcli -g UUID connection show --active) || active=''
        while IFS=: read -r uuid type name; do
            [[ $type == vpn || $type == wireguard ]] || continue
            connected=false
            [[ $'\n'"$active"$'\n' == *$'\n'"$uuid"$'\n'* ]] && connected=true
            result=$(exec::query jq -c --arg id "nm:$uuid" --arg name "$name" --arg type "$type" --argjson connected "$connected" '. + [{id:$id,name:$name,icon:"shield",connected:$connected,detail:(if $connected then "Connected" else $type end)}]' <<<"$result")
        done < <(exec::query nmcli -t --escape no -f UUID,TYPE,NAME connection show)
    fi
    if [[ ${1:-list} == snapshot ]]; then
        local prefs='{}' details
        state=${state:-'{}'}
        if proc::exists tailscale; then
            prefs=$(exec::query timeout 4 tailscale debug prefs 2>/dev/null | exec::query jq '{CorpDNS,RouteAll,ShieldsUp,ExitNodeID,ExitNodeIP,ExitNodeAllowLANAccess}') || prefs='{}'
        fi
        details=$(exec::query jq -cn --argjson state "$state" --argjson prefs "$prefs" -f "${BASH_SOURCE[0]%/*}/state.jq")
        exec::query jq -cn --argjson connections "$result" --argjson tailscale "$details" '{connections:$connections,tailscale:$tailscale}'
    else
        exec::query jq -c . <<<"$result"
    fi
}

vpn::tailscale() {
    local error_file code binary
    binary=$(command -v tailscale) || return
    if [[ ${SHELL_LIB_DRY_RUN:-false} == true ]]; then
        exec::run --quiet -- timeout 120 pkexec "$binary" "$@"
        return
    fi
    error_file=$(temp::file mono-vpn) || return
    code=0
    exec::run --quiet -- timeout 20 "$binary" "$@" 2>"$error_file" || code=$?
    if [[ $code != 0 ]] && exec::query grep -qiE 'access denied|permission denied|sudo|not permitted|must be root' "$error_file"; then
        fs::remove_file "$error_file"
        # The session's polkit agent owns the password prompt; credentials never enter QML.
        exec::run --quiet -- timeout 120 pkexec "$binary" "$@"
    else
        [[ $code == 0 ]] || fs::read "$error_file" >&2
        fs::remove_file "$error_file"
        return "$code"
    fi
}

case $1 in
    list|snapshot) vpn::list "$1" ;;
    connect|disconnect)
        [[ $# == 2 ]] || die 'A VPN connection is required'
        case $2 in
            tailscale)
                if [[ $1 == connect ]]; then
                    vpn::tailscale up
                else
                    vpn::tailscale down
                fi ;;
            nm:*)
                uuid=${2#nm:}
                [[ $uuid =~ ^[[:xdigit:]-]{36}$ ]] || die 'Invalid connection ID'
                action=down
                [[ $1 == connect ]] && action=up
                exec::run --quiet -- nmcli --wait 20 connection "$action" uuid "$uuid" ;;
            *) die 'Unsupported VPN connection' ;;
        esac ;;
    setting)
        [[ $# == 3 ]] || die 'A setting and value are required'
        case $2 in
            accept-dns|accept-routes|shields-up|exit-node-allow-lan-access)
                validate::boolean value "$3" || exit $?
                vpn::tailscale set "--$2=$3" ;;
            exit-node)
                [[ -z $3 || $3 =~ ^[0-9a-fA-F:.]+$ ]] || die 'Invalid exit node address'
                vpn::tailscale set "--exit-node=$3" ;;
            *) die 'Unsupported VPN setting' ;;
        esac ;;
    ping)
        [[ $# == 2 && $2 =~ ^[0-9a-fA-F:.]+$ ]] || die 'Invalid device address'
        exec::run --quiet -- timeout 7 tailscale ping --c 1 --timeout 4s "$2" ;;
    *) die 'Unknown VPN action' ;;
esac
