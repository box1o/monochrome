#!/usr/bin/env bash

# shellcheck disable=SC2034 # Parsed state is consumed by app.sh.

installer_cli::parse() {
    INSTALLER_COMMAND=
    INSTALLER_GROUPS=default
    INSTALLER_DRY_RUN=false
    INSTALLER_ASSUME_YES=true
    INSTALLER_INCLUDE_AUR=false
    INSTALLER_DETECT_HARDWARE=true
    INSTALLER_SHOW_HELP=false
    INSTALLER_HAS_PACKAGE_OPTIONS=false
    INSTALLER_CONFIGS=all
    INSTALLER_HAS_CONFIG_OPTIONS=false

    script::init
    args::option --name groups --short g --default default || return
    args::option --name configs --short c --default all || return
    args::flag --name yes --short y || return
    args::flag --name aur || return
    args::flag --name no-hardware || return
    script::parse "$@" || return

    INSTALLER_DRY_RUN=${SHELL_LIB_DRY_RUN:-false}

    if (($(args::count) > 1)); then
        log::error "Only one command may be supplied"
        return 2
    fi

    if (($(args::count) == 1)); then
        INSTALLER_COMMAND=$(args::position 0) || return
    fi

    INSTALLER_GROUPS=$(args::get groups) || return
    INSTALLER_CONFIGS=$(args::get configs) || return

    args::has dry-run && INSTALLER_DRY_RUN=true
    args::has yes && INSTALLER_ASSUME_YES=true
    args::has aur && INSTALLER_INCLUDE_AUR=true
    args::has no-hardware && INSTALLER_DETECT_HARDWARE=false
    args::has help && INSTALLER_SHOW_HELP=true

    if args::has groups || args::has dry-run || args::has yes || args::has aur || args::has no-hardware; then
        INSTALLER_HAS_PACKAGE_OPTIONS=true
    fi

    args::has configs && INSTALLER_HAS_CONFIG_OPTIONS=true
    return 0
}

installer_cli::print_help() {
    printf '%s\n' \
        'Usage:' \
        '  ./scripts/install/install.sh' \
        '  ./scripts/install/install.sh packages [options]' \
        '  ./scripts/install/install.sh configs [options]' \
        '  ./scripts/install/install.sh scripts [options]' \
        '  ./scripts/install/install.sh setup [options]' \
        '  ./scripts/install/install.sh watch [options]' \
        '  ./scripts/install/install.sh full [options]' \
        '' \
        'Commands:' \
        '  packages              Install package groups from packages.yaml.' \
        '  configs               Replace installed configurations from configs.yaml.' \
        '  scripts               Deploy user scripts into ~/.local/bin.' \
        '  setup                 Enable desktop services and configure shell/login.' \
        '  watch                 Redeploy changed configurations continuously.' \
        '  full                  Install packages, configs, scripts and system setup.' \
        '' \
        'Options:' \
        '  -g, --groups <list>   Comma-separated groups (default: default).' \
        '  -c, --configs <list>  Comma-separated configs (default: all).' \
        '  -n, --dry-run         Preview actions without changing the system.' \
        '  -y, --yes             Disable package-manager confirmation prompts (default).' \
        '      --aur             Include the AUR package group.' \
        '      --no-hardware     Skip automatic CPU and GPU package detection.' \
        '  -h, --help            Show this help text.' \
        '' \
        'Examples:' \
        '  ./scripts/install/install.sh packages --dry-run' \
        '  ./scripts/install/install.sh packages --groups default,development --dry-run' \
        '  ./scripts/install/install.sh packages --groups default,development,nvidia-development --yes' \
        '  ./scripts/install/install.sh packages --groups optional --aur' \
        '  ./scripts/install/install.sh configs --dry-run' \
        '  ./scripts/install/install.sh configs --configs hypr,kitty --dry-run' \
        '  ./scripts/install/install.sh scripts --dry-run' \
        '  ./scripts/install/install.sh watch --configs hypr,quickshell' \
        '  ./scripts/install/install.sh full --dry-run'
}
