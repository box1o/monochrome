#!/usr/bin/env bash

# shellcheck source=init.sh
source "${BASH_SOURCE[0]%/*}/init.sh"

script::init() {
    args::reset
    args::flag --name dry-run --short n
    args::flag --name help --short h
}

script::parse() {
    args::parse "$@" || return

    if args::has dry-run; then
        export SHELL_LIB_DRY_RUN=true
    fi

    validate::boolean dry-run "${SHELL_LIB_DRY_RUN:-false}" || return

    SCRIPT_ARGS=("${ARG_POSITIONAL_VALUES[@]}")
}

script::usage() { printf 'Usage: %s [--dry-run] %s\n' "${0##*/}" "${1:-}"; }

script::require_count() {
    local min=${1:-0} max=${2:-0}
    local count=${#SCRIPT_ARGS[@]}

    if ((count < min || count > max)); then
        log::error "Expected $min to $max positional arguments, got $count"
        return 2
    fi
}

script::parse_command() {
    local -a options=()

    while (($#)); do
        case "$1" in
            -n | --dry-run | -h | --help)
                options+=("$1")

                shift
                ;;
            --)
                shift
                break
                ;;
            *) break ;;
        esac
    done

    script::parse "${options[@]}" -- "$@"
}
