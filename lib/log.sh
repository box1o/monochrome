#!/usr/bin/env bash

readonly LOG_LEVEL_DEBUG=10
readonly LOG_LEVEL_INFO=20
readonly LOG_LEVEL_WARN=30
readonly LOG_LEVEL_ERROR=40

LOG_LEVEL=${LOG_LEVEL:-${LOG_LEVEL_INFO}}
LOG_COLOR=${LOG_COLOR:-auto}
LOG_TIMESTAMP=${LOG_TIMESTAMP:-false}
LOG_ICON_DEBUG=${LOG_ICON_DEBUG:-·}
LOG_ICON_INFO=${LOG_ICON_INFO:-}
LOG_ICON_WARN=${LOG_ICON_WARN:-!}
LOG_ICON_ERROR=${LOG_ICON_ERROR:-×}

log::_supports_color() {
    case "${LOG_COLOR}" in
        always) return 0 ;;
        never) return 1 ;;
        auto) [[ -t 2 ]] ;;
        *) return 1 ;;
    esac
}

log::_color_for() {
    local __level__=${1:-}

    case "${__level__}" in
        DEBUG) printf '\033[36m' ;;
        INFO) printf '\033[32m' ;;
        WARN) printf '\033[33m' ;;
        ERROR) printf '\033[31m' ;;
    esac
}

log::_icon_for() {
    local __level__=${1:-}

    case "${__level__}" in
        DEBUG) printf '%s' "${LOG_ICON_DEBUG}" ;;
        INFO) printf '%s' "${LOG_ICON_INFO}" ;;
        WARN) printf '%s' "${LOG_ICON_WARN}" ;;
        ERROR) printf '%s' "${LOG_ICON_ERROR}" ;;
    esac
}

log::_write() {
    local __level_name__=${1:-}
    local __level_value__=${2:-0}
    shift 2 || return 2

    if ((__level_value__ < LOG_LEVEL)); then
        return 0
    fi

    local __prefix__=
    if [[ "${LOG_TIMESTAMP}" == true ]]; then
        local __timestamp__
        __timestamp__=$(date '+%Y-%m-%d %H:%M:%S') || return
        __prefix__="[${__timestamp__}] "
    fi

    if log::_supports_color; then
        local __color__
        local __icon__
        __color__=$(log::_color_for "${__level_name__}") || return
        __icon__=$(log::_icon_for "${__level_name__}") || return

        if [[ -n "${__icon__}" ]]; then
            printf '%s%s\033[0m %s%s\n' \
                "${__color__}" \
                "${__icon__}" \
                "${__prefix__}" \
                "$*" >&2
        else
            printf '%s%s\n' "${__prefix__}" "$*" >&2
        fi
        return
    fi

    local __icon__
    __icon__=$(log::_icon_for "${__level_name__}") || return
    if [[ -n "${__icon__}" ]]; then
        printf '%s %s%s\n' "${__icon__}" "${__prefix__}" "$*" >&2
    else
        printf '%s%s\n' "${__prefix__}" "$*" >&2
    fi
}

log::debug() {
    log::_write DEBUG "${LOG_LEVEL_DEBUG}" "$@"
}

log::info() {
    log::_write INFO "${LOG_LEVEL_INFO}" "$@"
}

log::warn() {
    log::_write WARN "${LOG_LEVEL_WARN}" "$@"
}

log::error() {
    log::_write ERROR "${LOG_LEVEL_ERROR}" "$@"
}

log::fatal() {
    local __exit_code__=1

    if [[ ${1:-} == --code ]]; then
        __exit_code__=${2:-1}
        shift 2
    fi

    log::error "$@"
    exit "${__exit_code__}"
}
