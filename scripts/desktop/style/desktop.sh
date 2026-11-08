#!/usr/bin/env bash
# Context is supplied by ../style.sh.
# shellcheck disable=SC2154

style::desktop() {
    local directory
    style::link "$themes/obs/Mono.ovt" "$config/obs-studio/themes/Mono.ovt"
    style::ini "$config/obs-studio/user.ini" Appearance Theme org.monochrome.Mono

    for directory in "$config/Vencord" "$config/vesktop/settings"; do
        [[ -d "$directory" ]] || continue
        style::link "$themes/discord/mono.theme.css" "$directory/themes/mono.theme.css"
        style::json "$directory/settings.json" '.enabledThemes = ((.enabledThemes // []) + ["mono.theme.css"] | unique)'
    done
    if [[ -d "$config/BetterDiscord/themes" ]]; then
        style::link "$themes/discord/mono.theme.css" "$config/BetterDiscord/themes/mono.theme.css"
    fi
    if proc::exists spicetify; then
        directory="$config/spicetify"
        style::link "$themes/spotify" "$directory/Themes/Mono"
        exec::run spicetify config current_theme Mono color_scheme Mono
        log::info 'Spotify theme selected; run spicetify backup apply after the first Spotify login'
    else
        log::info 'Spotify theme ready; Spicetify is not installed'
    fi
    if [[ -f "$data/mono/telegram/mono.tdesktop-theme" ]]; then
        log::info "Telegram theme and wallpaper: $data/mono/telegram"
    else
        log::info "Telegram palette: $themes/telegram/mono.tdesktop-theme; install assets for the wallpaper"
    fi
    log::info 'Discord CSS ready; native Discord has no custom theme interface'
}
