#!/usr/bin/env bash

installer::_append_group() {
    local __groups__=${1:-}
    local __group__=${2:-}

    case ",${__groups__}," in
        *",${__group__},"*) printf '%s\n' "${__groups__}" ;;
        *) printf '%s,%s\n' "${__groups__}" "${__group__}" ;;
    esac
}

installer::_output_to_array() {
    local __output__=${1-}
    local __reference__=${2:-}

    var::_validate_reference "${__reference__}" || return
    local -n _values_=${__reference__}
    _values_=()

    [[ -n "${__output__}" ]] || return 0
    mapfile -t _values_ <<<"${__output__}"
}

installer::_lines_csv() {
    local __lines__=${1-}
    local __result__=
    local __line__

    while IFS= read -r __line__; do
        [[ -n "${__line__}" ]] || continue
        [[ -n "${__result__}" ]] && __result__+=,
        __result__+="${__line__}"
    done <<<"${__lines__}"

    printf '%s\n' "${__result__}"
}

installer::install_packages() {
    local __groups__=${1:-default}
    local __dry_run__=${2:-false}
    local __assume_yes__=${3:-false}
    local __detect_hardware__=${4:-true}

    validate::boolean dry-run "${__dry_run__}" || return
    validate::boolean assume-yes "${__assume_yes__}" || return
    validate::boolean detect-hardware "${__detect_hardware__}" || return
    packages::validate_manifest || return

    local __normalized_groups__
    __normalized_groups__=$(packages::normalize_groups "${__groups__}") || return

    if [[ "${__detect_hardware__}" == true ]]; then
        local __hardware_groups__
        __hardware_groups__=$(hardware::groups) || return

        local __hardware_group__
        while IFS= read -r __hardware_group__; do
            [[ -n "${__hardware_group__}" ]] || continue
            __normalized_groups__+=$'\n'"${__hardware_group__}"
        done <<<"${__hardware_groups__}"

        if [[ -n "${__hardware_groups__}" ]]; then
            log::info "Automatically selected hardware groups: $(installer::_lines_csv "${__hardware_groups__}")"
        fi
    fi

    local __pacman_output__
    local __aur_output__
    __pacman_output__=$(packages::resolve_pacman "${__normalized_groups__}") || return
    __aur_output__=$(packages::resolve_aur "${__normalized_groups__}") || return

    local -a __pacman_packages__=()
    local -a __aur_packages__=()
    installer::_output_to_array "${__pacman_output__}" __pacman_packages__ || return
    installer::_output_to_array "${__aur_output__}" __aur_packages__ || return

    local __additional_output__
    __additional_output__=$(hardware::additional_packages "${__normalized_groups__}") || return
    if [[ -n "${__additional_output__}" ]]; then
        local __additional_package__
        while IFS= read -r __additional_package__; do
            [[ -n "${__additional_package__}" ]] && __pacman_packages__+=("${__additional_package__}")
        done <<<"${__additional_output__}"
    fi

    log::info "Resolved ${#__pacman_packages__[@]} Pacman packages and ${#__aur_packages__[@]} AUR packages"

    package_manager::install \
        __pacman_packages__ \
        __aur_packages__ \
        "${__assume_yes__}" \
        "${__dry_run__}"
}

installer::full_install() {
    local __groups__=${1:-default}
    local __configs__=${2:-all}
    local __dry_run__=${3:-false}
    local __assume_yes__=${4:-true}
    local __detect_hardware__=${5:-true}

    log::info 'Full install phase 1/3: packages'
    installer::install_packages "${__groups__}" "${__dry_run__}" "${__assume_yes__}" "${__detect_hardware__}" || return

    log::info 'Full install phase 2/3: configurations'
    configs::deploy "${__configs__}" "${__dry_run__}" || return

    log::info 'Full install phase 3/3: user scripts'
    scripts::deploy "${__dry_run__}" || return

    if [[ "${__dry_run__}" == true ]]; then
        log::info 'Full installation preview completed successfully'
    else
        log::info 'Full installation completed successfully'
    fi
}

installer::_interactive() {
    if [[ ! -t 0 || ! -t 1 ]]; then
        log::error "No command supplied and an interactive terminal is unavailable"
        installer_cli::print_help >&2
        return 2
    fi

    local __action__
    __action__=$(installer_menu::action) || {
        local __status__=$?
        ((__status__ == 130)) && return 0
        return "${__status__}"
    }

    local __dry_run__=false
    installer_menu::dry_run && __dry_run__=true

    if [[ "${__dry_run__}" != true ]]; then
        installer_menu::confirm_action "${__action__}" || return 0
    fi

    case "${__action__}" in
        packages) installer::install_packages default "${__dry_run__}" true true ;;
        configs) configs::deploy all "${__dry_run__}" ;;
        scripts) scripts::deploy "${__dry_run__}" ;;
        watch) watcher::configs all "${__dry_run__}" ;;
        full) installer::full_install default all "${__dry_run__}" true true ;;
    esac
}

installer::main() {
    installer_cli::parse "$@" || return

    if [[ "${INSTALLER_SHOW_HELP}" == true ]]; then
        installer_cli::print_help
        return 0
    fi

    if [[ -z "${INSTALLER_COMMAND}" ]]; then
        if [[ "${INSTALLER_HAS_CONFIG_OPTIONS}" == true ]]; then
            INSTALLER_COMMAND=configs
        elif [[ "${INSTALLER_HAS_PACKAGE_OPTIONS}" == true ]]; then
            INSTALLER_COMMAND=packages
        else
            installer::_interactive
            return
        fi
    fi

    case "${INSTALLER_COMMAND}" in
        packages)
            local __groups__=${INSTALLER_GROUPS}
            if [[ "${INSTALLER_INCLUDE_AUR}" == true ]]; then
                __groups__=$(installer::_append_group "${__groups__}" aur) || return
            fi

            installer::install_packages \
                "${__groups__}" \
                "${INSTALLER_DRY_RUN}" \
                "${INSTALLER_ASSUME_YES}" \
                "${INSTALLER_DETECT_HARDWARE}"
            ;;
        configs)
            configs::deploy "${INSTALLER_CONFIGS}" "${INSTALLER_DRY_RUN}"
            ;;
        scripts)
            scripts::deploy "${INSTALLER_DRY_RUN}"
            ;;
        watch)
            watcher::configs "${INSTALLER_CONFIGS}" "${INSTALLER_DRY_RUN}"
            ;;
        full)
            local __groups__=${INSTALLER_GROUPS}
            if [[ "${INSTALLER_INCLUDE_AUR}" == true ]]; then
                __groups__=$(installer::_append_group "${__groups__}" aur) || return
            fi

            installer::full_install \
                "${__groups__}" \
                "${INSTALLER_CONFIGS}" \
                "${INSTALLER_DRY_RUN}" \
                "${INSTALLER_ASSUME_YES}" \
                "${INSTALLER_DETECT_HARDWARE}"
            ;;
        *)
            log::error "Unknown installer command: ${INSTALLER_COMMAND}"
            installer_cli::print_help >&2
            return 2
            ;;
    esac
}
