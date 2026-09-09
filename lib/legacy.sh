#!/usr/bin/env bash

# Compatibility helpers for commands migrated from the original Mono project.
if [[ -r "${BASH_SOURCE[0]%/*}/init.sh" ]]; then
    # shellcheck source=init.sh
    source "${BASH_SOURCE[0]%/*}/init.sh"
fi

mono_config_home() {
    printf '%s\n' "${MONO_CONFIG_HOME:-${XDG_CONFIG_HOME:-${HOME}/.config}/mono}"
}

load_config() {
    local name=${1:-}
    local file
    shift || true

    file="$(mono_config_home)/mono.conf"
    [[ -f "${file}" ]] && source "${file}"
    file="$(mono_config_home)/${name}.conf"
    [[ -f "${file}" ]] && source "${file}"
    for file in "$@"; do
        [[ -f "${file}" ]] && source "${file}"
    done
}

has_cmd() { command -v "$1" >/dev/null 2>&1; }
die() { log::fatal "$*"; }
log() { log::info "$*"; }
ok() { log::info "$*"; }
warn() { log::warn "$*"; }
need_cmd() { has_cmd "$1" || die "missing command: $1"; }
need_file() { [[ -f "${1:-}" ]] || die "missing file: ${1:-}"; }
need_dir() { [[ -d "${1:-}" ]] || die "missing directory: ${1:-}"; }

need_any_cmd() {
    local cmd
    for cmd in "$@"; do
        if has_cmd "${cmd}"; then
            printf '%s\n' "${cmd}"
            return 0
        fi
    done
    die "missing one of: $*"
}

kill_pids() {
    local pids=${1:-}
    [[ -z "${pids}" ]] || kill ${pids} 2>/dev/null || true
}

copy_text() {
    if has_cmd wl-copy; then
        wl-copy
    elif has_cmd xclip; then
        xclip -selection clipboard
    else
        die 'missing clipboard command: wl-copy or xclip'
    fi
}
