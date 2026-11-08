#!/usr/bin/env bash
# Context is supplied by ../style.sh.
# shellcheck disable=SC2154

style::terminal() {
    style::link "$themes/btop/mono.theme" "$config/btop/themes/mono.theme"
    style::setting "$config/btop/btop.conf" color_theme '"mono"'

    local lazygit="$config/lazygit/config.yml" current='{}' merged output
    [[ ! -f "$lazygit" ]] || current=$(yaml::to_json "$lazygit")
    merged=$(yaml::to_json "$themes/lazygit/mono.yml")
    output=$(exec::query jq --argjson colors "$merged" '. * $colors' <<<"$current") || return
    printf '%s\n' "$output" | style::write "$lazygit"

    style::link "$themes/yazi/theme.toml" "$config/yazi/theme.toml"
    style::link "$themes/zathura/mono.conf" "$config/zathura/mono.conf"
    style::line "$config/zathura/zathurarc" "include \"$config/zathura/mono.conf\""
    style::link "$themes/bat/Mono.tmTheme" "$config/bat/themes/Mono.tmTheme"
    if proc::exists bat; then
        exec::run --quiet -- bat cache --build
    fi
    log::info 'Installed terminal themes: btop, lazygit, Yazi, Zathura, bat and fzf'
}
