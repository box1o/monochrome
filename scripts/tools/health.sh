#!/usr/bin/env bash

set -euo pipefail
# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/../.init.sh" || exit $?

script::init
script::parse "$@"
if args::has help; then
    script::usage ''
    exit 0
fi
script::require_count 0 0
proc::require systemctl find awk jq

warnings=0
failures=0
config="${XDG_CONFIG_HOME:-$HOME/.config}"

health::warn() {
    warnings=$((warnings + 1))
    log::warn "$*"
}

health::error() {
    failures=$((failures + 1))
    log::error "$*"
}

log::info 'Mono desktop health — read-only'
for command in kitty mousepad nautilus lsblk stat xdg-user-dir qs hyprctl hyprlock hypridle hyprpaper wpctl nmcli bluetoothctl wl-copy cliphist inotifywait udevadm; do
    proc::exists "$command" || health::error "Missing dependency: $command"
done

for scope in system user; do
    arguments=()
    [[ $scope != user ]] || arguments+=(--user)
    if failed=$(exec::query systemctl "${arguments[@]}" --failed --no-legend --plain --no-pager 2>/dev/null); then
        if [[ -n "$failed" ]]; then
            while read -r unit _; do
                [[ -z "$unit" ]] || health::error "Failed $scope service: $unit"
            done <<<"$failed"
        else
            log::info "No failed $scope services"
        fi
    else
        health::warn "Cannot inspect $scope services"
    fi
done

for unit in NetworkManager bluetooth power-profiles-daemon; do
    exec::query systemctl is-active --quiet "$unit.service" 2>/dev/null || health::warn "Inactive service: $unit"
done

if [[ -n ${WAYLAND_DISPLAY:-} ]]; then
    for unit in pipewire.socket pipewire-pulse.socket wireplumber.service hyprpolkitagent.service; do
        exec::query systemctl --user is-active --quiet "$unit" 2>/dev/null || health::warn "Inactive session service: $unit"
    done
    if proc::exists pgrep; then
        exec::query pgrep -u "$UID" -x qs >/dev/null 2>&1 || health::warn 'QuickShell is not running'
    fi
fi

for file in hypr/hyprland.lua quickshell/shell.qml nvim/init.lua gtk-3.0/gtk.css gtk-4.0/gtk.css mono/appearance/settings.json; do
    [[ -r "$config/$file" ]] || health::error "Missing configuration: $config/$file"
done

for directory in "$config/hypr" "$config/quickshell" "$config/nvim" "$config/mono" "$HOME/.local/libexec/mono"; do
    [[ -d "$directory" ]] || continue
    while IFS= read -r -d '' link; do
        [[ -e "$link" ]] || health::error "Broken link: $link"
    done < <(exec::query find "$directory" -type l -print0)
done

palette="$config/nvim/lua/mono/palette.lua"
if [[ -r "$palette" ]]; then
    background=$(exec::query awk -F '"' '/^[[:space:]]*background =/ { print $2; exit }' "$palette")
    vscode="$HOME/.vscode/extensions/mono.theme-1.0.0/themes/mono-color-theme.json"
    if [[ -r "$vscode" ]]; then
        if color=$(exec::query jq -er '.colors["editor.background"]' "$vscode" 2>/dev/null); then
            [[ $color == "$background" ]] || health::warn 'VS Code and Neovim backgrounds differ; redeploy their themes'
        else
            health::error 'VS Code theme is invalid'
        fi
    fi
    gtk="$config/gtk-4.0/gtk.css"
    if [[ -r "$gtk" && -n "$background" ]]; then
        color=$(exec::query awk '/--window-bg-color:/ { gsub(/;/, "", $2); print $2; exit }' "$gtk")
        [[ $color == "$background" ]] || health::warn 'GTK and Neovim backgrounds differ; redeploy their themes'
    fi
    log::info "Installed theme background: ${background:-unknown}"
fi

log::info "Health report: $failures errors, $warnings warnings"
((failures == 0))
