#!/usr/bin/env bash

configs::manifest() {
    printf '%s\n' "${MONO_CONFIGS_MANIFEST:-${MONO_ROOT}/configs.yaml}"
}

configs::validate_manifest() {
    local __manifest__
    __manifest__=$(configs::manifest) || return

    fs::require_file config-manifest "${__manifest__}" || return
    proc::require awk || return

    if ! proc::run_quiet awk '$0 == "configs:" { found = 1 } END { exit !found }' "${__manifest__}"; then
        log::error 'Configuration manifest does not contain a configs mapping'
        return 1
    fi
}

configs::available() {
    local __manifest__
    __manifest__=$(configs::manifest) || return

    proc::capture awk '
        $0 == "configs:" { configs = 1; next }
        configs && /^[^ ]/ { exit }
        configs && /^  [a-zA-Z0-9_-]+:$/ {
            value = $0
            sub(/^  /, "", value)
            sub(/:$/, "", value)
            print value
        }
    ' "${__manifest__}"
}

configs::has() {
    local __name__=${1:-}
    validate::identifier "${__name__}" || return

    local __candidate__
    while IFS= read -r __candidate__; do
        [[ "${__candidate__}" == "${__name__}" ]] && return 0
    done < <(configs::available)

    return 1
}

configs::available_csv() {
    installer::_lines_csv "$(configs::available)"
}

configs::normalize() {
    local __configs__=${1:-all}
    local -a __values__=()

    if [[ "${__configs__}" == all ]]; then
        configs::available
        return
    fi

    IFS=',' read -r -a __values__ <<<"${__configs__}"
    local -A __seen__=()
    local __name__
    for __name__ in "${__values__[@]}"; do
        __name__=${__name__//[[:space:]]/}
        validate::not_empty config "${__name__}" || return

        if ! configs::has "${__name__}"; then
            log::error "Unknown configuration: ${__name__}"
            log::info "Available configurations: $(configs::available_csv)"
            return 2
        fi

        if [[ "${__name__}" == bash || "${__name__}" == zsh ]]; then
            if [[ ! -v '__seen__[shell]' ]]; then
                __seen__[shell]=true
                printf 'shell\n'
            fi
        fi

        [[ -v "__seen__[${__name__}]" ]] && continue
        __seen__["${__name__}"]=true
        printf '%s\n' "${__name__}"
    done
}

configs::_property() {
    local __name__=${1:-}
    local __property__=${2:-}
    local __manifest__

    validate::identifier "${__name__}" || return
    validate::identifier "${__property__}" || return
    __manifest__=$(configs::manifest) || return

    proc::capture awk -v target="${__name__}" -v property="${__property__}" '
        $0 == "configs:" { configs = 1; next }
        configs && /^[^ ]/ { exit }
        configs && /^  [a-zA-Z0-9_-]+:$/ {
            current = $0
            sub(/^  /, "", current)
            sub(/:$/, "", current)
            next
        }
        configs && current == target && $0 ~ "^    " property ":" {
            value = $0
            sub("^    " property ":[[:space:]]*", "", value)
            print value
            found = 1
            exit
        }
        END { if (!found) exit 1 }
    ' "${__manifest__}"
}

configs::source() {
    local __relative__
    __relative__=$(configs::_property "${1:-}" source) || return
    path::absolute "${MONO_ROOT}/${__relative__}"
}

configs::target_relative() {
    local __target__
    __target__=$(configs::_property "${1:-}" target) || return

    if [[ -z "${__target__}" || "${__target__}" == /* || "${__target__}" == .. || "${__target__}" == ../* ]]; then
        log::error "Configuration target must be safely relative to the user home: ${__target__}"
        return 1
    fi

    printf '%s\n' "${__target__}"
}

configs::source_ready() {
    local __source__=${1:-}
    fs::_require_source "${__source__}" || return

    if [[ -f "${__source__}" ]]; then
        return 0
    fi

    local __nullglob_enabled__=false
    local __dotglob_enabled__=false
    shopt -q nullglob && __nullglob_enabled__=true
    shopt -q dotglob && __dotglob_enabled__=true

    local __entry__
    shopt -s nullglob dotglob
    for __entry__ in "${__source__}"/*; do
        [[ "${__entry__##*/}" == .gitkeep ]] && continue
        [[ "${__nullglob_enabled__}" == true ]] || shopt -u nullglob
        [[ "${__dotglob_enabled__}" == true ]] || shopt -u dotglob
        return 0
    done
    [[ "${__nullglob_enabled__}" == true ]] || shopt -u nullglob
    [[ "${__dotglob_enabled__}" == true ]] || shopt -u dotglob
    return 1
}

configs::_target_path() {
    local __home__=${1:-}
    local __relative__=${2:-}
    local __target__

    __target__=$(proc::capture realpath --canonicalize-missing --no-symlinks -- "${__home__}/${__relative__}") || return
    case "${__target__}" in
        "${__home__}" | "${__home__}"/*) printf '%s\n' "${__target__}" ;;
        *)
            log::error "Configuration target is outside the user home: ${__target__}"
            return 1
            ;;
    esac
}

configs::target_user() {
    if ((EUID == 0)); then
        if [[ -n ${SUDO_USER:-} && ${SUDO_USER} != root ]]; then
            printf '%s\n' "${SUDO_USER}"
            return 0
        fi

        log::error 'Run configuration deployment as your desktop user, not directly as root'
        return 1
    fi

    user::current
}

configs::_run() {
    local __user__=${1:-}
    local __dry_run__=${2:-false}
    shift 2 || return 2

    local -a __prefix__=()
    [[ "${__dry_run__}" == true ]] && __prefix__+=(--dry-run)

    if ((EUID == 0)); then
        proc::run "${__prefix__[@]}" -- sudo -u "${__user__}" -- "$@"
    else
        proc::run "${__prefix__[@]}" -- "$@"
    fi
}

configs::_deploy_one() {
    local __name__=${1:-}
    local __user__=${2:-}
    local __home__=${3:-}
    local __dry_run__=${4:-false}

    local __source__
    local __relative_target__
    local __target__
    __source__=$(configs::source "${__name__}") || return
    __relative_target__=$(configs::target_relative "${__name__}") || return
    __target__=$(configs::_target_path "${__home__}" "${__relative_target__}") || return
    fs::_require_source "${__source__}" || return

    if ! configs::source_ready "${__source__}"; then
        log::warn "Skipping placeholder configuration without files: ${__name__}"
        return 0
    fi

    if fs::exists "${__target__}"; then
        log::info "Replacing configuration: ${__target__}"
        configs::_run "${__user__}" "${__dry_run__}" rm -rf -- "${__target__}" || return
    fi

    configs::_run "${__user__}" "${__dry_run__}" mkdir -p -- "${__target__%/*}" || return
    configs::_run "${__user__}" "${__dry_run__}" cp -a -- "${__source__}" "${__target__}" || return

    if [[ "${__name__}" == hypr ]]; then
        configs::_ensure_monitor_state "${__user__}" "${__home__}" "${__source__}" "${__dry_run__}" || return
    fi

    log::info "Installed ${__name__}: ${__target__}"
}

configs::_ensure_monitor_state() {
    local __user__=${1:-}
    local __home__=${2:-}
    local __hypr_source__=${3:-}
    local __dry_run__=${4:-false}
    local __state__="${__home__}/.config/mono/hypr/monitors.conf"

    if fs::exists "${__state__}"; then
        return 0
    fi

    log::info "Creating persistent monitor configuration: ${__state__}"
    configs::_run "${__user__}" "${__dry_run__}" mkdir -p -- "${__state__%/*}" || return
    configs::_run "${__user__}" "${__dry_run__}" cp -a -- "${__hypr_source__}/monitors.conf" "${__state__}"
}

configs::deploy() {
    local __selection__=${1:-all}
    local __dry_run__=${2:-false}
    validate::boolean dry-run "${__dry_run__}" || return
    configs::validate_manifest || return

    local __normalized__
    __normalized__=$(configs::normalize "${__selection__}") || return

    local __user__
    local __home__
    __user__=$(configs::target_user) || return
    __home__=$(user::home "${__user__}") || return

    local __name__
    local __count__=0
    local __reload_hypr__=false
    while IFS= read -r __name__; do
        [[ -n "${__name__}" ]] || continue
        configs::_deploy_one "${__name__}" "${__user__}" "${__home__}" "${__dry_run__}" || return
        [[ "${__name__}" != hypr ]] || __reload_hypr__=true
        ((__count__ += 1))
    done <<<"${__normalized__}"

    # Hyprland may auto-reload while its config directory is being replaced.
    # Reload after all copies finish so it reads the complete configuration.
    if [[ "${__reload_hypr__}" == true && -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]] && proc::exists hyprctl; then
        configs::_run "${__user__}" "${__dry_run__}" hyprctl reload || return
    fi

    log::info "Processed ${__count__} configurations for ${__user__}"
}
