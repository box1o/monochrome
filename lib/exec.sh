#!/usr/bin/env bash

exec::_quote() {
    local __argument__
    for __argument__ in "$@"; do
        printf '%q ' "${__argument__}"
    done
}

exec::capture() {
    (($# > 0)) || {
        log::error 'exec::capture requires a command'
        return 2
    }
    exec::run --quiet "$@"
}

exec::run() {
    local __dry_run__=${SHELL_LIB_DRY_RUN:-false}
    local __quiet__=false
    local __sudo__=false
    local __stdout__=
    local __stderr__=
    local __stdin__=
    local __append__=false
    local __info__=
    local -a __command__=()

    while (($# > 0)); do
        case "$1" in
            --dry-run) __dry_run__=true ;;
            --quiet) __quiet__=true ;;
            --sudo) __sudo__=true ;;
            --append) __append__=true ;;
            --stdout | --stderr | --stdin | --info)
                (($# >= 2)) || {
                    log::error "$1 requires a value"
                    return 2
                }
                case "$1" in
                    --stdout) __stdout__=$2 ;;
                    --stderr) __stderr__=$2 ;;
                    --stdin) __stdin__=$2 ;;
                    --info) __info__=$2 ;;
                esac
                shift
                ;;
            --)
                shift
                __command__=("$@")
                break
                ;;
            *)
                __command__=("$@")
                break
                ;;
        esac
        shift
    done

    ((${#__command__[@]} > 0)) || {
        log::error 'exec::run requires a command'
        return 2
    }
    [[ -n ${__info__} ]] || __info__=$(exec::_quote "${__command__[@]}")

    if [[ ${__dry_run__} == true ]]; then
        log::info "DRY-RUN ${__info__}"
        return 0
    fi

    [[ ${__quiet__} == true ]] || log::info "RUN ${__info__}"

    if [[ ${__sudo__} == true ]]; then
        __command=(sudo "${__command__[@]}")
    fi

    if [[ -n ${__stdin__} && ! -f ${__stdin__} ]]; then
        log::error "stdin file not found: ${__stdin__}"
        return 1
    fi

    if [[ -n ${__stdin__} && -n ${__stdout__} && -n ${__stderr__} ]]; then
        if [[ ${__append__} == true ]]; then "${__command__[@]}" <"${__stdin__}" >>"${__stdout__}" 2>>"${__stderr__}"; else "${__command__[@]}" <"${__stdin__}" >"${__stdout__}" 2>"${__stderr__}"; fi
    elif [[ -n ${__stdout__} && -n ${__stderr__} ]]; then
        if [[ ${__append__} == true ]]; then "${__command__[@]}" >>"${__stdout__}" 2>>"${__stderr__}"; else "${__command__[@]}" >"${__stdout__}" 2>"${__stderr__}"; fi
    elif [[ -n ${__stdout__} ]]; then
        if [[ ${__append__} == true ]]; then "${__command__[@]}" >>"${__stdout__}"; else "${__command__[@]}" >"${__stdout__}"; fi
    elif [[ -n ${__stderr__} ]]; then
        if [[ ${__append__} == true ]]; then "${__command__[@]}" 2>>"${__stderr__}"; else "${__command__[@]}" 2>"${__stderr__}"; fi
    elif [[ -n ${__stdin__} ]]; then
        "${__command__[@]}" <"${__stdin__}"
    else
        "${__command__[@]}"
    fi
    local __status__=$?

    if ((__status__ != 0)); then
        log::error "FAILED (${__status__}) ${__info__}"
    fi
    return "${__status__}"
}
