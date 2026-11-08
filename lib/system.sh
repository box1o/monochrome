#!/usr/bin/env bash

system::os() { exec::query uname -s; }

system::architecture() { exec::query uname -m; }

system::kernel() { exec::query uname -r; }

system::hostname() { exec::query hostname; }

system::cpu_count() { exec::query getconf _NPROCESSORS_ONLN 2> /dev/null || exec::query nproc; }

system::memory_mb() { exec::query awk '/MemTotal:/ { print int($2 / 1024) }' /proc/meminfo; }

system::require_linux() {
    local __operating_system__
    __operating_system__=$(system::os) || return

    if [[ "${__operating_system__}" != Linux ]]; then
        log::error "Linux is required"
        return 1
    fi
}

system::distribution() {
    if [[ ! -r /etc/os-release ]]; then
        printf 'unknown\n'
        return 0
    fi

    local __distribution__
    __distribution__=$(
        # shellcheck disable=SC1091
        source /etc/os-release
        printf '%s\n' "${ID:-unknown}"
    ) || return

    printf '%s\n' "${__distribution__}"
}

system::is_container() {
    [[ -f /.dockerenv ]] && return 0

    exec::query grep -qaE '(docker|containerd|lxc|kubepods)' /proc/1/cgroup
}

system::is_wsl() { exec::query grep -qi microsoft /proc/version; }
