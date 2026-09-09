#!/usr/bin/env bash

scripts::source_dir() {
    printf '%s/scripts\n' "${MONO_ROOT}"
}

scripts::library_source_dir() {
    printf '%s/lib\n' "${MONO_ROOT}"
}

scripts::target_user() {
    configs::target_user
}

scripts::_files() {
    local __source_dir__
    __source_dir__=$(scripts::source_dir) || return
    fs::require_dir scripts "${__source_dir__}" || return

    local __nullglob_enabled__=false
    shopt -q nullglob && __nullglob_enabled__=true

    local __file__
    shopt -s nullglob
    for __file__ in "${__source_dir__}"/*; do
        [[ -f "${__file__}" ]] || continue
        [[ "${__file__##*/}" == .gitkeep ]] && continue
        printf '%s\n' "${__file__}"
    done
    [[ "${__nullglob_enabled__}" == true ]] || shopt -u nullglob
}

scripts::_deploy_one() {
    local __source__=${1:-}
    local __user__=${2:-}
    local __target_dir__=${3:-}
    local __dry_run__=${4:-false}

    local __name__=${__source__##*/}
    local __target__="${__target_dir__}/${__name__}"

    if fs::exists "${__target__}"; then
        log::info "Replacing user script: ${__target__}"
        configs::_run "${__user__}" "${__dry_run__}" rm -rf -- "${__target__}" || return
    fi

    configs::_run "${__user__}" "${__dry_run__}" mkdir -p -- "${__target_dir__}" || return
    configs::_run "${__user__}" "${__dry_run__}" cp -a -- "${__source__}" "${__target__}" || return
    configs::_run "${__user__}" "${__dry_run__}" chmod u+x -- "${__target__}" || return
    log::info "Installed user script: ${__target__}"
}

scripts::deploy() {
    local __dry_run__=${1:-false}
    validate::boolean dry-run "${__dry_run__}" || return

    local __files__
    __files__=$(scripts::_files) || return
    if [[ -z "${__files__}" ]]; then
        log::info 'No user commands are currently configured'
    fi

    local __user__
    local __home__
    __user__=$(scripts::target_user) || return
    __home__=$(user::home "${__user__}") || return

    local __target_dir__="${__home__}/.local/bin"
    local __library_source__
    local __library_target__="${__home__}/.local/lib/mono"
    __library_source__=$(scripts::library_source_dir) || return

    if fs::exists "${__library_target__}"; then
        log::info "Replacing runtime library: ${__library_target__}"
        configs::_run "${__user__}" "${__dry_run__}" rm -rf -- "${__library_target__}" || return
    fi
    configs::_run "${__user__}" "${__dry_run__}" mkdir -p -- "${__library_target__%/*}" || return
    configs::_run "${__user__}" "${__dry_run__}" cp -a -- "${__library_source__}" "${__library_target__}" || return
    log::info "Installed runtime library: ${__library_target__}"

    local __source__
    local __count__=0
    while IFS= read -r __source__; do
        [[ -n "${__source__}" ]] || continue
        scripts::_deploy_one "${__source__}" "${__user__}" "${__target_dir__}" "${__dry_run__}" || return
        ((__count__ += 1))
    done <<<"${__files__}"

    log::info "Processed ${__count__} user scripts for ${__user__}"
}
