#!/usr/bin/env bash
# shellcheck disable=SC2034 # State is consumed by the installer phases.

bootstrap::prepare() {
    local dry_run=${1:-false}
    local -a packages=()
    local private_yq=false
    validate::boolean dry-run "$dry_run" || return
    MONO_BOOTSTRAP_PENDING=false

    proc::exists jq || packages+=(jq)
    if ! yaml::_require_yq 2>/dev/null; then
        if exec::query pacman -Qq yq >/dev/null 2>&1; then
            private_yq=true
            proc::exists go || packages+=(go)
        else
            packages+=(go-yq)
        fi
    fi
    ((${#packages[@]} > 0)) || [[ $private_yq == true ]] || return 0

    package_manager::require_arch || return
    if ((${#packages[@]} > 0)); then
        package_manager::authenticate "$dry_run" || return
        package_manager::install_pacman packages true "$dry_run" || return
    fi

    if [[ $private_yq == true ]]; then
        local target_user home
        target_user=$(deploy::target_user) || return
        home=$(user::home "$target_user") || return
        deploy::run "$target_user" "$dry_run" fs::mkdir "$home/.local/libexec/mono/bin" || return
        deploy::run "$target_user" "$dry_run" env GOBIN="$home/.local/libexec/mono/bin" \
            go install github.com/mikefarah/yq/v4@v4.54.1 || return
        export MONO_YQ="$home/.local/libexec/mono/bin/yq"
    fi

    if [[ $dry_run == true ]]; then
        MONO_BOOTSTRAP_PENDING=true
        log::info 'DRY-RUN theme validation deferred until bootstrap dependencies are installed'
    fi
}
