#!/usr/bin/env bash

installer_menu::action() {
    local __selection__
    __selection__=$(menu::select \
        --prompt "What do you want to do?" \
        -- \
        "Install packages" \
        "Deploy configs" \
        "Deploy scripts" \
        "Watch configs" \
        "Full install" \
        "Exit") || return

    case "${__selection__}" in
        "Install packages") printf 'packages\n' ;;
        "Deploy configs") printf 'configs\n' ;;
        "Deploy scripts") printf 'scripts\n' ;;
        "Watch configs") printf 'watch\n' ;;
        "Full install") printf 'full\n' ;;
        "Exit") return 130 ;;
    esac
}

installer_menu::dry_run() {
    menu::confirm --default-no "Preview only (dry-run)?"
}

installer_menu::confirm_action() {
    local __action__=${1:-installation}
    menu::confirm "Continue with ${__action__}?"
}
