#!/usr/bin/env bash

package_manager::require_arch() {
    local __distribution__
    __distribution__=$(system::distribution) || return

    if [[ "${__distribution__}" != arch ]]; then
        log::error "Mono package installation currently supports Arch Linux only"
        return 1
    fi
}

package_manager::authenticate() {
    local __dry_run__=${1:-false}
    validate::boolean dry-run "${__dry_run__}" || return

    [[ "${__dry_run__}" == true ]] && return 0
    ((EUID == 0)) && return 0

    proc::require sudo || return
    log::info 'Administrator privileges are required to install system packages'
    proc::run --info 'sudo authentication' sudo -v
}

package_manager::install_pacman() {
    local __packages_reference__=${1:-}
    local __assume_yes__=${2:-false}
    local __dry_run__=${3:-false}

    var::_validate_reference "${__packages_reference__}" || return
    validate::boolean assume-yes "${__assume_yes__}" || return
    validate::boolean dry-run "${__dry_run__}" || return

    local -n _packages_=${__packages_reference__}
    ((${#_packages_[@]} > 0)) || return 0

    proc::require pacman sudo || return

    local -a __arguments__=(-S --needed)
    [[ "${__assume_yes__}" == true ]] && __arguments__+=(--noconfirm)
    __arguments__+=("${_packages_[@]}")

    if [[ "${__dry_run__}" == true ]]; then
        proc::run --dry-run -- sudo pacman "${__arguments__[@]}"
        return
    fi

    proc::run sudo pacman "${__arguments__[@]}"
}

package_manager::install_aur() {
    local __packages_reference__=${1:-}
    local __assume_yes__=${2:-false}
    local __dry_run__=${3:-false}

    var::_validate_reference "${__packages_reference__}" || return
    validate::boolean assume-yes "${__assume_yes__}" || return
    validate::boolean dry-run "${__dry_run__}" || return

    local -n _packages_=${__packages_reference__}
    ((${#_packages_[@]} > 0)) || return 0

    proc::require yay || return

    local -a __arguments__=(-S --needed)
    [[ "${__assume_yes__}" == true ]] && __arguments__+=(--noconfirm)
    __arguments__+=("${_packages_[@]}")

    if [[ "${__dry_run__}" == true ]]; then
        proc::run --dry-run -- yay "${__arguments__[@]}"
        return
    fi

    proc::run yay "${__arguments__[@]}"
}

package_manager::install() {
    local __pacman_reference__=${1:-}
    local __aur_reference__=${2:-}
    local __assume_yes__=${3:-false}
    local __dry_run__=${4:-false}

    validate::boolean dry-run "${__dry_run__}" || return

    package_manager::require_arch || return
    package_manager::authenticate "${__dry_run__}" || return
    package_manager::install_pacman "${__pacman_reference__}" "${__assume_yes__}" "${__dry_run__}" || return
    package_manager::install_aur "${__aur_reference__}" "${__assume_yes__}" "${__dry_run__}"
}
