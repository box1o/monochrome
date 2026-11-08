#!/usr/bin/env bash

configs::manifest() { printf '%s\n' "${MONO_CONFIGS_MANIFEST:-${MONO_ROOT}/configs.yaml}"; }

configs::validate_manifest() {
    local __manifest__
    __manifest__=$(configs::manifest) || return

    fs::require_file config-manifest "${__manifest__}" || return
    proc::require awk || return

    if ! exec::query awk '$0 == "configs:" { found = 1 } END { exit !found }' "${__manifest__}"; then
        log::error 'Configuration manifest does not contain a configs mapping'
        return 1
    fi
}

configs::available() {
    local __manifest__
    __manifest__=$(configs::manifest) || return

    exec::query awk '
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

configs::available_csv() { list::csv "$(configs::available)"; }

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

        local dependency
        local -a dependencies=()
        case "$__name__" in
        applications) dependencies=(shell) ;;
        bash | zsh) dependencies=(shell) ;;
        tmux) dependencies=(tmux-compat) ;;
        hypr | quickshell) dependencies=(assets icons) ;;
        appearance | qt | qt5ct | gtk3 | gtk4) dependencies=(icons) ;;
        esac
        for dependency in "${dependencies[@]}"; do
            [[ -v "__seen__[$dependency]" ]] && continue
            __seen__["$dependency"]=true
            printf '%s\n' "$dependency"
        done

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

    exec::query awk -v target="${__name__}" -v property="${__property__}" '
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
    __target__=$(exec::query realpath --canonicalize-missing --no-symlinks -- "${__home__}/${__relative__}") || return

    case "${__target__}" in
    "${__home__}" | "${__home__}"/*) printf '%s\n' "${__target__}" ;;
    *)
        log::error "Configuration target is outside the user home: ${__target__}"
        return 1
        ;;
    esac
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

    if [[ "$__dry_run__" == true ]]; then
        log::info "DRY-RUN deploy ${__source__} to ${__target__} with rollback on failure"
        return 0
    fi

    fs::_require_source "${__source__}" || return

    if ! configs::source_ready "${__source__}"; then
        log::warn "Skipping placeholder configuration without files: ${__name__}"
        return 0
    fi

    # Monitor edits made by QuickShell belong to this same Lua file across upgrades.
    local monitor_state=""
    local monitor_path="$__target__/settings/monitors.lua"
    [[ -f "$monitor_path" ]] || monitor_path="$__target__/monitors.lua"
    if [[ "$__name__" == hypr && -f "$monitor_path" ]]; then
        monitor_state=$(fs::read "$monitor_path") || return
    fi

    deploy::replace "${__user__}" "${__dry_run__}" "${__source__}" "${__target__}" || return

    case "$__name__" in
    icons)
        if proc::exists gtk-update-icon-cache; then
            deploy::run "$__user__" "$__dry_run__" gtk-update-icon-cache -f -t "$__target__" || return
        fi
        ;;
    quickshell) deploy::run "$__user__" "$__dry_run__" bash "$MONO_ROOT/scripts/desktop/snippets.sh" setup || return ;;
    nautilus) deploy::run "$__user__" "$__dry_run__" bash "$MONO_ROOT/scripts/desktop/files.sh" setup "$MONO_ROOT" || return ;;
    zen) deploy::run "$__user__" "$__dry_run__" bash "$MONO_ROOT/scripts/desktop/browser.sh" zen || return ;;
    applications) deploy::run "$__user__" "$__dry_run__" bash "$MONO_ROOT/scripts/desktop/style.sh" || return ;;
    esac

    if [[ -n "$monitor_state" ]]; then
        printf '%s\n' "$monitor_state" |
            deploy::run "$__user__" "$__dry_run__" fs::atomic_write "$__target__/settings/monitors.lua" || return
    fi

    if [[ "$__dry_run__" != true ]]; then
        log::info "Installed ${__name__}: ${__target__}"
    fi
}

configs::deploy() {
    local __selection__=${1:-all}
    local __dry_run__=${2:-false}

    validate::boolean dry-run "${__dry_run__}" || return

    if [[ "$__dry_run__" == true && ${MONO_BOOTSTRAP_PENDING:-false} == true ]]; then
        log::info 'DRY-RUN generate theme after bootstrap dependencies are installed'
    elif [[ "$__dry_run__" == true ]]; then
        exec::query bash "${MONO_ROOT}/scripts/tools/theme.sh" --root "$MONO_ROOT" --dry-run || return
    else
        exec::run --quiet -- bash "${MONO_ROOT}/scripts/tools/theme.sh" --root "$MONO_ROOT" || return
    fi

    configs::validate_manifest || return

    local __normalized__
    __normalized__=$(configs::normalize "${__selection__}") || return

    local __user__
    local __home__

    __user__=$(deploy::target_user) || return
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
        deploy::run "${__user__}" "${__dry_run__}" hyprctl reload || return
        if proc::exists systemctl; then
            local unit
            for unit in mono-hyprpaper.service mono-hypridle.service; do
                if exec::query systemctl --user is-active --quiet "$unit"; then
                    deploy::run "$__user__" "$__dry_run__" systemctl --user try-restart "$unit" || return
                fi
            done
        fi
    fi

    log::info "Processed ${__count__} configurations for ${__user__}"
}
