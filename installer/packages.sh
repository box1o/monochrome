#!/usr/bin/env bash

packages::manifest() {
    printf '%s/packages.yaml\n' "${MONO_ROOT}"
}

packages::validate_manifest() {
    local __manifest__
    __manifest__=$(packages::manifest) || return

    fs::require_file package-manifest "${__manifest__}" || return
    proc::require awk || return

    local __distribution__
    __distribution__=$(proc::capture awk '
        $1 == "distribution:" { print $2; found = 1; exit }
        END { if (!found) exit 1 }
    ' "${__manifest__}") || {
        log::error "Package manifest does not declare a distribution"
        return 1
    }

    if [[ "${__distribution__}" != arch ]]; then
        log::error "Unsupported package manifest distribution: ${__distribution__}"
        return 1
    fi

    if ! proc::run_quiet awk '$0 == "packages:" { found = 1 } END { exit !found }' "${__manifest__}"; then
        log::error "Package manifest does not contain a packages mapping"
        return 1
    fi
}

packages::available_groups() {
    local __manifest__
    __manifest__=$(packages::manifest) || return

    proc::capture awk '
        $0 == "packages:" { packages = 1; next }
        packages && /^[^ ]/ { exit }
        packages && /^  [a-zA-Z0-9_-]+:$/ {
            value = $0
            sub(/^  /, "", value)
            sub(/:$/, "", value)
            print value
        }
    ' "${__manifest__}"
}

packages::has_group() {
    local __group__=${1:-}
    validate::identifier "${__group__}" || return

    local __candidate__
    while IFS= read -r __candidate__; do
        [[ "${__candidate__}" == "${__group__}" ]] && return 0
    done < <(packages::available_groups)

    return 1
}

packages::available_groups_csv() {
    local __result__=
    local __group__

    while IFS= read -r __group__; do
        [[ -n "${__group__}" ]] || continue

        if [[ -n "${__result__}" ]]; then
            __result__+=,
        fi
        __result__+="${__group__}"
    done < <(packages::available_groups)

    printf '%s\n' "${__result__}"
}

packages::normalize_groups() {
    local __groups__=${1:-}

    validate::not_empty package-groups "${__groups__}" || return

    local -A __seen__=()
    local __group__
    local -a __values__=()
    IFS=',' read -r -a __values__ <<<"${__groups__}"

    for __group__ in "${__values__[@]}"; do
        __group__=${__group__//[[:space:]]/}
        validate::not_empty package-group "${__group__}" || return

        if ! packages::has_group "${__group__}"; then
            log::error "Unknown package group: ${__group__}"
            log::info "Available groups: $(packages::available_groups_csv)"
            return 2
        fi

        [[ -v "__seen__[${__group__}]" ]] && continue
        __seen__["${__group__}"]=true
        printf '%s\n' "${__group__}"
    done
}

packages::_group_values() {
    local __group__=${1:-}
    local __manifest__

    validate::identifier "${__group__}" || return
    __manifest__=$(packages::manifest) || return

    proc::capture awk -v target="${__group__}" '
        $0 == "packages:" { packages = 1; next }
        packages && /^[^ ]/ { exit }
        packages && /^  [a-zA-Z0-9_-]+:$/ {
            current = $0
            sub(/^  /, "", current)
            sub(/:$/, "", current)
            next
        }
        packages && current == target && /^    - / {
            value = $0
            sub(/^    - /, "", value)
            print value
        }
    ' "${__manifest__}"
}

packages::_resolve_for_source() {
    local __source__=${1:-}
    local __groups__=${2:-}
    local -A __seen__=()
    local __group__
    local __package__

    while IFS= read -r __group__; do
        [[ -n "${__group__}" ]] || continue

        case "${__source__}" in
            pacman) [[ "${__group__}" == aur ]] && continue ;;
            aur) [[ "${__group__}" != aur ]] && continue ;;
            *)
                log::error "Unknown package source: ${__source__}"
                return 2
                ;;
        esac

        while IFS= read -r __package__; do
            [[ -n "${__package__}" ]] || continue
            [[ -v "__seen__[${__package__}]" ]] && continue

            __seen__["${__package__}"]=true
            printf '%s\n' "${__package__}"
        done < <(packages::_group_values "${__group__}")
    done <<<"${__groups__}"
}

packages::resolve_pacman() {
    packages::_resolve_for_source pacman "${1:-}"
}

packages::resolve_aur() {
    packages::_resolve_for_source aur "${1:-}"
}
