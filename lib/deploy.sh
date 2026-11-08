#!/usr/bin/env bash

deploy::target_user() {
    if ((EUID == 0)); then
        if [[ -n ${SUDO_USER:-} && $SUDO_USER != root ]]; then
            printf '%s\n' "$SUDO_USER"
            return 0
        fi

        log::error 'Run deployment as your desktop user, not directly as root'
        return 1
    fi

    user::current
}

deploy::run() {
    local target_user=${1:-} SHELL_LIB_DRY_RUN=${2:-false}

    shift 2 || return 2

    validate::not_empty user "$target_user" || return
    validate::boolean dry-run "$SHELL_LIB_DRY_RUN" || return

    if ((EUID == 0)); then
        exec::run -- sudo -u "$target_user" -- bash -c \
            'source "$1/init.sh" || exit; shift; "$@"' \
            bash "$SHELL_LIB_DIR" "$@"
    elif declare -F "${1:-}" > /dev/null; then
        "$@"
    else
        exec::run -- "$@"
    fi
}

# Prepare the replacement before touching the deployed path. A failed commit rolls back.
deploy::_replace() {
    local source=${1:-} target=${2:-} mode=${3:-}

    if [[ ${SHELL_LIB_DRY_RUN:-false} == true ]]; then
        log::info "DRY-RUN stage $source and replace $target with rollback on failure"
        return 0
    fi

    fs::mkdir_parent "$target" || return

    local parent temporary status=0
    parent=$(path::dirname "$target") || return
    temporary=$(exec::capture mktemp -d "$parent/.mono-deploy.XXXXXX") || return

    if fs::is_dir "$source"; then
        fs::copy_tree "$source" "$temporary/new" || status=$?
    else
        fs::copy_file "$source" "$temporary/new" || status=$?
    fi
    if ((status == 0)) && [[ -n "$mode" ]]; then
        fs::chmod "$mode" "$temporary/new" || status=$?
    fi
    if ((status != 0)); then
        fs::remove_tree "$temporary" || true
        return "$status"
    fi

    if fs::exists "$target"; then
        fs::move "$target" "$temporary/previous" || {
            status=$?
            fs::remove_tree "$temporary" || true
            return "$status"
        }
    fi
    fs::move "$temporary/new" "$target" || {
        status=$?
        if fs::exists "$temporary/previous"; then
            fs::move "$temporary/previous" "$target" || {
                log::error "Rollback failed; previous files remain at $temporary/previous"
                return "$status"
            }
        fi
        fs::remove_tree "$temporary" || true
        return "$status"
    }
    fs::remove_tree "$temporary"
}

deploy::replace() {
    local target_user=${1:-} dry_run=${2:-false}
    local source=${3:-} target=${4:-} mode=${5:-}

    fs::_require_source "$source" || return
    fs::_assert_safe_removal_path "$target" || return
    deploy::run "$target_user" "$dry_run" deploy::_replace "$source" "$target" "$mode"
}
