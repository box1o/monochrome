#!/usr/bin/env bash

setup::_run() {
    local SHELL_LIB_DRY_RUN=$1
    shift
    if [[ $SHELL_LIB_DRY_RUN != true && $setup_authenticated != true ]]; then
        package_manager::authenticate false || return
        setup_authenticated=true
    fi
    exec::run -- sudo "$@"
}

setup::_has_login_manager() {
    local path
    [[ ! -L /etc/systemd/system/display-manager.service ]] || return 0
    for path in /etc/systemd/system/*.target.wants/*.service; do
        case ${path##*/} in
            ly@*.service | ly-kmsconvt@*.service | gdm.service | sddm.service | lightdm.service | greetd.service)
                return 0
                ;;
        esac
    done
    return 1
}

setup::apply() {
    local dry_run=${1:-false} target_user shell current unit setup_authenticated=false
    validate::boolean dry-run "$dry_run" || return
    package_manager::require_arch || return
    proc::require systemctl getent || return
    target_user=$(deploy::target_user) || return

    for unit in NetworkManager.service bluetooth.service power-profiles-daemon.service tailscaled.service; do
        if [[ $(exec::query systemctl show "$unit" --property=LoadState --value 2>/dev/null) == not-found ]]; then
            if [[ $unit == tailscaled.service ]]; then
                log::info "Skipping unavailable optional service: $unit"
                continue
            elif [[ $dry_run != true ]]; then
                log::error "Required service is not installed: $unit"
                return 1
            fi
        fi
        if exec::query systemctl is-enabled --quiet "$unit" 2>/dev/null &&
            exec::query systemctl is-active --quiet "$unit" 2>/dev/null; then
            log::info "Already configured: $unit"
        else
            setup::_run "$dry_run" systemctl enable --now "$unit" || return
        fi
    done

    local -a user_systemctl=(systemctl --user)
    if ((EUID == 0)); then
        local uid
        uid=$(user::uid "$target_user") || return
        user_systemctl=(sudo -u "$target_user" env "XDG_RUNTIME_DIR=/run/user/$uid" \
            "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus" systemctl --user)
    fi
    for unit in pipewire.socket pipewire-pulse.socket wireplumber.service; do
        if exec::query "${user_systemctl[@]}" is-enabled --quiet "$unit" 2>/dev/null &&
            exec::query "${user_systemctl[@]}" is-active --quiet "$unit" 2>/dev/null; then
            log::info "Already configured: $unit"
        else
            SHELL_LIB_DRY_RUN=$dry_run exec::run -- "${user_systemctl[@]}" enable --now "$unit" || return
        fi
    done

    if proc::exists zsh; then
        shell=$(path::absolute "$(command -v zsh)") || return
    elif [[ $dry_run == true ]]; then
        shell=/usr/bin/zsh
    else
        log::error 'Zsh is not installed; install the default package group first'
        return 1
    fi
    current=$(exec::query getent passwd "$target_user") || return
    if [[ ${current##*:} != "$shell" ]]; then
        setup::_run "$dry_run" chsh --shell "$shell" "$target_user" || return
    fi

    # Preserve an existing greeter and never start or stop one during deployment.
    if setup::_has_login_manager; then
        log::info 'Keeping the existing login manager'
    elif [[ $(exec::query systemctl show ly@tty1.service --property=LoadState --value 2>/dev/null) == not-found && $dry_run != true ]]; then
        log::error 'Ly is not installed; install the default package group first'
        return 1
    else
        setup::_run "$dry_run" systemctl enable ly@tty1.service || return
    fi
    if [[ $(exec::query systemctl get-default) != graphical.target ]]; then
        setup::_run "$dry_run" systemctl set-default graphical.target || return
    fi
    log::info 'Desktop system setup completed'
}
