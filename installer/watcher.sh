#!/usr/bin/env bash

watcher::_selected() {
    local __name__=${1:-}
    local __selected__=${2:-}
    case $'\n'"${__selected__}"$'\n' in
        *$'\n'"${__name__}"$'\n'*) return 0 ;;
        *) return 1 ;;
    esac
}

watcher::_config_for_path() {
    local __path__=${1:-}
    local __name__
    local __source__

    while IFS= read -r __name__; do
        [[ -n "${__name__}" ]] || continue
        __source__=$(configs::source "${__name__}") || return
        case "${__path__}" in
            "${__source__}" | "${__source__}"/*)
                printf '%s\n' "${__name__}"
                return 0
                ;;
        esac
    done < <(configs::available)

    return 1
}

watcher::_deploy_pending() {
    local __pending_reference__=${1:-}
    local __user__=${2:-}
    local __home__=${3:-}
    local __dry_run__=${4:-false}

    var::_validate_reference "${__pending_reference__}" || return
    local -n _pending_="${__pending_reference__}"

    local __name__
    for __name__ in "${!_pending_[@]}"; do
        log::info "Configuration changed: ${__name__}"
        configs::_deploy_one "${__name__}" "${__user__}" "${__home__}" "${__dry_run__}" || return
    done

    _pending_=()
}

watcher::configs() {
    local __selection__=${1:-all}
    local __dry_run__=${2:-false}
    validate::boolean dry-run "${__dry_run__}" || return
    configs::validate_manifest || return
    proc::require inotifywait || return

    local __selected__
    __selected__=$(configs::normalize "${__selection__}") || return

    local __user__
    local __home__
    __user__=$(configs::target_user) || return
    __home__=$(user::home "${__user__}") || return

    local __watch_root__="${MONO_ROOT}/configs"
    fs::require_dir configuration-root "${__watch_root__}" || return

    log::info "Watching ${__watch_root__} for configuration changes"
    log::info 'Press Ctrl+C to stop'

    coproc MONO_CONFIG_WATCH {
        exec::run --quiet inotifywait \
            --monitor \
            --recursive \
            --quiet \
            --event close_write,create,delete,move \
            --format '%w%f' \
            -- "${__watch_root__}"
    }

    local __watch_fd__=${MONO_CONFIG_WATCH[0]}
    local __watch_pid__=${MONO_CONFIG_WATCH_PID}
    local __path__
    local __name__
    local -A __pending__=()

    while IFS= read -r -u "${__watch_fd__}" __path__; do
        __name__=$(watcher::_config_for_path "${__path__}") || continue
        watcher::_selected "${__name__}" "${__selected__}" || continue
        __pending__["${__name__}"]=true

        while IFS= read -r -t 0.15 -u "${__watch_fd__}" __path__; do
            __name__=$(watcher::_config_for_path "${__path__}") || continue
            watcher::_selected "${__name__}" "${__selected__}" || continue
            __pending__["${__name__}"]=true
        done

        watcher::_deploy_pending __pending__ "${__user__}" "${__home__}" "${__dry_run__}" || {
            proc::run_allow_fail kill "${__watch_pid__}" >/dev/null 2>&1 || true
            return 1
        }
    done

    wait "${__watch_pid__}"
}
