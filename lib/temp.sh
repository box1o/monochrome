#!/usr/bin/env bash

declare -ga TEMP_RESOURCES=()

temp::_create() {
    local __kind__=${1:-}
    local __prefix__=${2:-shell-lib}
    local __base__=${3:-${TMPDIR:-/tmp}}
    local __path__

    validate::enum "$__kind__" directory file || return

    if [[ ${SHELL_LIB_DRY_RUN:-false} == true ]]; then
        __path__="${__base__%/}/${__prefix__}.dry-run-${BASHPID}"

        log::info "DRY-RUN temporary $__kind__: $__path__"

        printf '%s\n' "$__path__"
        return 0
    fi

    fs::mkdir "${__base__}" || return

    case "${__kind__}" in
        directory)
            __path__=$(exec::capture mktemp -d "${__base__%/}/${__prefix__}.XXXXXX") || return
            ;;
        file)
            __path__=$(exec::capture mktemp "${__base__%/}/${__prefix__}.XXXXXX") || return
            ;;
        *)
            log::error "temp::_create: invalid resource kind: ${__kind__}"
            return 2
            ;;
    esac

    temp::register "${__path__}" || return

    printf '%s\n' "${__path__}"
}

temp::dir() { temp::_create directory "${1:-shell-lib}" "${2:-${TMPDIR:-/tmp}}"; }

temp::file() { temp::_create file "${1:-shell-lib}" "${2:-${TMPDIR:-/tmp}}"; }

temp::register() {
    local __path__=${1:-}

    validate::not_empty temporary-path "${__path__}" || return

    TEMP_RESOURCES+=("${__path__}")
}

temp::cleanup() {
    local __path__
    local __absolute__

    for __path__ in "${TEMP_RESOURCES[@]}"; do
        [[ -n "${__path__}" ]] || continue

        __absolute__=$(path::absolute "${__path__}") || continue

        if [[ -d "${__absolute__}" && ! -L "${__absolute__}" ]]; then
            fs::remove_tree "${__absolute__}" || true
        else
            fs::remove_file "${__absolute__}" || true
        fi
    done

    TEMP_RESOURCES=()
}
