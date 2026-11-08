#!/usr/bin/env bash

list::csv_append() {
    local __groups__=${1:-}
    local __group__=${2:-}

    case ",${__groups__}," in
        *",${__group__},"*) printf '%s\n' "${__groups__}" ;;
        *) printf '%s,%s\n' "${__groups__}" "${__group__}" ;;
    esac
}

list::from_lines() {
    local __output__=${1-}
    local __reference__=${2:-}

    var::_validate_reference "${__reference__}" || return

    local -n _values_=${__reference__}
    _values_=()

    [[ -n "${__output__}" ]] || return 0

    mapfile -t _values_ <<< "${__output__}"
}

list::csv() {
    local __lines__=${1-}
    local __result__=
    local __line__

    while IFS= read -r __line__; do
        [[ -n "${__line__}" ]] || continue
        [[ -n "${__result__}" ]] && __result__+=,

        __result__+="${__line__}"
    done <<< "${__lines__}"

    printf '%s\n' "${__result__}"
}
