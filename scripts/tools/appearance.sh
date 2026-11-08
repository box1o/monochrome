#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/../.init.sh" || exit $?

script::init
script::parse "$@" || exit $?
if args::has help; then
    script::usage ''
    exit 0
fi
script::require_count 0 0 || exit $?
proc::require jq gsettings

settings="${XDG_CONFIG_HOME:-$HOME/.config}/mono/appearance/settings.json"
fs::require_file appearance "$settings"
exec::query jq -e '
    keys == (["gtk-theme", "icon-theme", "cursor-theme", "cursor-size", "font-name",
              "monospace-font-name", "color-scheme", "enable-animations"] | sort)
    and all(to_entries[]; if .key == "cursor-size" then (.value | type == "number" and . == floor)
        elif .key == "enable-animations" then (.value | type == "boolean")
        else (.value | type == "string") end)
' "$settings" >/dev/null || log::fatal 'Invalid appearance settings; regenerate the theme'

while IFS= read -r record; do
    key=$(exec::query jq -r '.key' <<<"$record")
    value=$(exec::query jq -c '.value' <<<"$record")
    exec::run --quiet -- gsettings set org.gnome.desktop.interface "$key" "$value"
done < <(exec::query jq -c 'to_entries[]' "$settings")
