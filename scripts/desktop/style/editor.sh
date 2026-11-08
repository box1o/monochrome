#!/usr/bin/env bash
# Context is supplied by ../style.sh.
# shellcheck disable=SC2154

style::editor() {
    local registry="$config/obsidian/obsidian.json" path paths
    for path in gtksourceview-4 gtksourceview-5; do
        style::link "$themes/gtksourceview/mono.xml" "$data/$path/styles/mono.xml"
    done
    if proc::exists mousepad; then
        exec::run gsettings set org.xfce.mousepad.preferences.view color-scheme mono
        exec::run xdg-mime default org.xfce.mousepad.desktop text/plain
    fi
    if [[ -n "$vault" ]]; then
        style::vault "$vault"
    elif [[ -f "$registry" ]]; then
        paths=$(exec::query jq -r '.vaults // {} | .[] | .path // empty' "$registry") || return
        while IFS= read -r path; do
            [[ -n "$path" ]] || continue
            style::vault "$path"
        done <<<"$paths"
    else
        log::info 'Obsidian theme ready; no registered vaults found'
    fi

    if proc::exists codium && [[ -d "$HOME/.vscode/extensions/mono.theme-1.0.0" ]]; then
        style::link "$HOME/.vscode/extensions/mono.theme-1.0.0" "$HOME/.vscode-oss/extensions/mono.theme-1.0.0"
        log::info 'VSCodium theme available as Mono in the Color Theme picker'
    fi
}

style::vault() {
    local directory=$1
    fs::require_dir vault "$directory/.obsidian"
    style::link "$themes/obsidian/mono.css" "$directory/.obsidian/snippets/mono.css"
    style::json "$directory/.obsidian/appearance.json" '
        .enabledCssSnippets = ((.enabledCssSnippets // []) + ["mono"] | unique)
        | .theme = "obsidian"
    '
    log::info "Enabled Mono snippet for Obsidian: $directory"
}
