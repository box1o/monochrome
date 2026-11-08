#!/usr/bin/env bash
# jq/awk expressions are intentionally not shell-expanded.
# shellcheck disable=SC2016

set -euo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/../.init.sh" || exit $?

script::init
args::option --name device
script::parse "$@"
if args::has help; then
    script::usage '--device BLUEZ-DEVICE-PATH'
    exit 0
fi
script::require_count 0 0
device=$(args::get device)
[[ $device =~ ^/org/bluez/hci[0-9]+/dev_([0-9A-F]{2}_){5}[0-9A-F]{2}$ ]] || log::fatal --code 2 'Invalid BlueZ device path'
if [[ ${SHELL_LIB_DRY_RUN:-false} == true ]]; then
    log::info "DRY-RUN pair $device"
    exit 0
fi
proc::require bluetoothctl busctl jq sed stdbuf

address=${device##*/dev_}
address=${address//_/:}
adapter=${device%/dev_*}
controller=$(exec::query busctl --system --json=short get-property org.bluez "$adapter" org.bluez.Adapter1 Address | exec::query jq -r '.data')
[[ $controller =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]] || log::fatal 'Bluetooth controller unavailable'

pair::event() {
    exec::query jq -cn --arg event "$1" --arg kind "${2:-}" --arg value "${3:-}" '{event:$event,kind:$kind,value:$value}'
}

pair::result() {
    successful=$1
    exec::query jq -cn --argjson success "$1" --arg message "$2" '{event:"result",success:$success,message:$message}'
    [[ $1 == true ]] && exit 0 || exit 1
}

pair::cleanup() {
    trap - EXIT TERM INT
    if [[ -n ${control_fd:-} ]]; then
        if ! $successful; then
            printf 'cancel-pairing %s\n' "$address" 1>&"$control_fd" 2>/dev/null || true
        fi
        printf 'quit\n' 1>&"$control_fd" 2>/dev/null || true
        exec {control_fd}>&-
    fi
    [[ -z ${events_fd:-} ]] || exec {events_fd}<&-
    if [[ -n ${agent_pid:-} ]]; then
        exec::run --quiet -- kill "$agent_pid" 2>/dev/null || true
        wait "$agent_pid" 2>/dev/null || true
    fi
}

successful=false
trap '' PIPE
trap pair::cleanup EXIT
trap 'pair::result false "Pairing canceled or timed out."' TERM INT

# bluetoothctl owns the native agent; never request default-agent status.
coproc BLUEZ { exec::run --quiet -- env LC_ALL=C TERM=dumb NO_COLOR=1 stdbuf -o0 -e0 bluetoothctl --agent KeyboardDisplay 2>&1; }
agent_pid=$BLUEZ_PID
exec {events_fd}<&"${BLUEZ[0]}"
exec {control_fd}>&"${BLUEZ[1]}"
started=false
kind=""
buffer=""
deadline=$((SECONDS + 90))

while ((SECONDS < deadline)); do
    chunk=""
    IFS= read -r -d '' -t 0.05 -u "$events_fd" chunk || true
    if [[ -n $chunk ]]; then
        clean=$(printf '%s' "$chunk" | exec::query sed -E $'s/\x1b\\[[0-9;?]*[[:alpha:]]//g; s/\r//g')
        buffer+=$clean
        if ((${#buffer} > 8192)); then
            buffer=${buffer: -8192}
        fi
        if ! $started && [[ $buffer == *'Agent registered'* ]]; then
            printf 'select %s\npair %s\n' "$controller" "$address" 1>&"$control_fd"
            started=true
            buffer=""
        elif [[ $buffer == *'Enter PIN code:'* ]]; then
            kind=pin; pair::event prompt "$kind"; buffer=""
        elif [[ $buffer == *'Enter passkey ('* ]]; then
            kind=passkey; pair::event prompt "$kind"; buffer=""
        elif [[ $buffer =~ Confirm[[:space:]]passkey[[:space:]]([0-9]{6}) ]]; then
            kind=confirm; pair::event prompt "$kind" "${BASH_REMATCH[1]}"; buffer=""
        elif [[ $buffer == *'Accept pairing (yes/no):'* || $buffer == *'Authorize service '*'(yes/no):'* ]]; then
            kind=confirm; pair::event prompt "$kind"; buffer=""
        elif [[ $buffer =~ (Passkey|PIN[[:space:]]code):[[:space:]]([0-9]+) ]]; then
            pair::event prompt display "${BASH_REMATCH[2]}"
        fi
        if [[ $clean == *'Pairing successful'* ]]; then
            pair::result true ''
        elif [[ $clean == *'Failed to pair'* || $clean == *'not available'* || $clean == *'Failed to register agent'* ]]; then
            pair::result false 'Pairing failed. Check the device and try again.'
        elif [[ $clean == *'Request canceled'* ]]; then
            kind=""; pair::event clear
        fi
    elif ! kill -0 "$agent_pid" 2>/dev/null; then
        pair::result false 'Bluetooth pairing agent stopped.'
    fi

    input_status=0
    IFS= read -r -t 0.05 response || input_status=$?
    if ((input_status == 0)); then
        [[ -n $kind ]] || continue
        exec::query jq -e 'type == "object" and (.accept | type == "boolean") and ((.value // "") | type == "string")' <<<"$response" >/dev/null 2>&1 || pair::result false 'Invalid pairing response.'
        accepted=$(exec::query jq -r '.accept' <<<"$response")
        value=$(exec::query jq -r '.value // ""' <<<"$response")
        [[ $accepted == true ]] || pair::result false 'Pairing rejected.'
        case "$kind" in
            pin)
                [[ ${#value} -ge 1 && ${#value} -le 16 && $value != *$'\n'* && $value != *$'\r'* ]] || pair::result false 'PIN must contain 1 to 16 characters.'
                ;;
            passkey) [[ $value =~ ^[0-9]{1,6}$ ]] || pair::result false 'Passkey must contain 1 to 6 digits.' ;;
            confirm) value=yes ;;
        esac
        printf '%s\n' "$value" 1>&"$control_fd"
        kind=""
    elif ((input_status == 1)); then
        pair::result false 'Pairing canceled.'
    fi
done
pair::result false 'Pairing canceled or timed out.'
