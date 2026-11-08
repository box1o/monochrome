#!/usr/bin/env bash

proc::exists() {
    local __command__=${1:-}

    [[ -n "${__command__}" ]] && command -v "${__command__}" > /dev/null 2>&1
}

proc::require() {
    local __command__

    for __command__ in "$@"; do
        if ! proc::exists "${__command__}"; then
            log::error "Required command not found: ${__command__}"
            return 127
        fi
    done
}

proc::_require_command() {
    local __caller__=${1:-function}
    local __argument_count__=${2:-0}

    if ((__argument_count__ == 0)); then
        log::error "${__caller__}: command is required"
        return 2
    fi
}

proc::run_as() {
    local __user__=${1:-}

    shift || true

    validate::not_empty user "${__user__}" || return

    proc::_require_command proc::run_as "$#" || return

    proc::require sudo || return

    exec::run sudo -u "${__user__}" -- "$@"
}

proc::timeout() {
    local __seconds__=${1:-}

    shift || true

    validate::positive_integer seconds "${__seconds__}" || return

    proc::_require_command proc::timeout "$#" || return

    proc::require timeout || return

    exec::run timeout --preserve-status "${__seconds__}" "$@"
}

proc::first_available() {
    local command

    for command in "$@"; do
        if proc::exists "$command"; then
            printf '%s\n' "$command"
            return 0
        fi
    done

    log::error "Required command not found; expected one of: $*"
    return 127
}
