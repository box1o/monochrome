#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/.init.sh" || exit $?

script::init
script::parse "$@" || exit $?

if args::has help; then
    script::usage 'MACHINE'
    exit 0
fi

script::require_count 1 1 || exit $?

set -- "${SCRIPT_ARGS[@]}"

config::load_shell rdp

require_machine_config() {
    local vm="$1"
    local var_ip="RDP_VM_${vm}_IP"
    local remote="${!var_ip:-}"

    [[ -n "${SSH_HOST:-}" ]] || log::fatal 'SSH_HOST is missing'
    [[ -n "${RDP_USER:-}" ]] || log::fatal 'RDP_USER is missing'
    [[ -n "${RDP_PASSWORD:-}" ]] || log::fatal 'RDP_PASSWORD is missing'
    [[ -n "${remote}" ]] || log::fatal "missing RDP config for machine ${vm}"
}

stop_existing_tunnel() {
    local port="$1"
    local pids
    pids="$(exec::query pgrep -f "ssh .*127.0.0.1:${port}:" || true)"

    local pid

    while IFS= read -r pid; do
        [[ -n "$pid" ]] || continue

        exec::run kill -- "$pid" || true
    done <<< "$pids"

    [[ -z "${pids}" ]] || exec::run --quiet -- sleep 1
}

start_tunnel() {
    local port="$1"
    local remote="$2"

    log::info "Starting SSH tunnel 127.0.0.1:${port} -> ${remote}:3389 via ${SSH_HOST}"

    exec::run ssh -fnNT -o ExitOnForwardFailure=yes -L "127.0.0.1:${port}:${remote}:3389" "${SSH_HOST}"
}

open_rdp() {
    local client="$1"
    local port="$2"
    local shared_dir="${RDP_SHARED_DIR:-${HOME}/work}"
    local shared_name="${RDP_SHARED_NAME:-work}"

    exec::run --quiet --info "Open RDP session" -- "${client}" \
        /v:127.0.0.1:"${port}" \
        /u:"${RDP_USER}" \
        /p:"${RDP_PASSWORD}" \
        /w:"${RDP_WIDTH:-1920}" \
        /h:"${RDP_HEIGHT:-1440}" \
        /drive:"${shared_name}","${shared_dir}" \
        +clipboard \
        +fonts
}

main() {
    local vm="${1:-}"
    local client remote name port
    local ip_key="RDP_VM_${vm}_IP" name_key="RDP_VM_${vm}_NAME"

    validate::positive_integer machine "${vm}"

    require_machine_config "${vm}"

    client="$(proc::first_available xfreerdp3 xfreerdp wlfreerdp sdl-freerdp)"
    remote=${!ip_key}
    name=${!name_key:-vm-$vm}
    port="${RDP_LOCAL_PORT_PREFIX:-339}${vm}"

    validate::positive_integer port "${port}"

    ((10#$port <= 65535)) || log::fatal "invalid local port: ${port}"

    stop_existing_tunnel "${port}"
    start_tunnel "${port}" "${remote}"

    log::info "RDP ${name} on 127.0.0.1:${port}"
    log::info "Opening ${client}"

    open_rdp "${client}" "${port}"
}

main "$@"
