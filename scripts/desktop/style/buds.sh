#!/usr/bin/env bash
# Context is supplied by ../style.sh.
# shellcheck disable=SC2154

style::buds() {
    local file="$data/GalaxyBudsClient/settings.json" colors restart=false
    [[ -f "$file" ]] || return 0
    colors=$(fs::read "$themes/buds/colors.json")
    if exec::query jq -e --argjson colors "$colors" '.Theme == $colors.Theme and .AccentColor == $colors.AccentColor' "$file" >/dev/null 2>&1; then
        return
    fi
    if proc::exists systemctl && exec::query systemctl --user is-active --quiet mono-buds.service; then
        restart=true
        exec::run systemctl --user stop mono-buds.service
    elif exec::query pgrep -f '^([^ ]*/)?galaxybudsclient([[:space:]]|$)' >/dev/null; then
        log::warn 'Close Galaxy Buds Client and run style.sh buds to apply its accent'
        return
    fi
    # Preserve all device settings and credentials; only appearance keys are merged.
    local status=0
    style::json "$file" '. + $colors' --argjson colors "$colors" || status=$?
    if [[ "$restart" == true ]]; then
        exec::run systemd-run --user --collect --unit mono-buds galaxybudsclient /StartMinimized
    fi
    ((status == 0)) || return "$status"
    log::info 'Galaxy Buds Client: dark mode and system accent applied'
}
