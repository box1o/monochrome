#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/../.init.sh" || exit $?
# shellcheck source=style/common.sh
source "${BASH_SOURCE[0]%/*}/style/common.sh"

script::init
script::parse "$@"
if args::has help; then
    script::usage 'zen|firefox'
    exit 0
fi
script::require_count 1 1
proc::require awk cmp readlink date

root="${XDG_CONFIG_HOME:-$HOME/.config}"
case "${SCRIPT_ARGS[0]}" in
    zen)
        directories=("$root/zen" "$HOME/.zen")
        theme="$root/mono/zen"
        ;;
    firefox)
        directories=("$root/mozilla/firefox" "$HOME/.mozilla/firefox")
        theme="$root/mono/applications/firefox"
        ;;
    *) log::fatal --code 2 'Expected zen or firefox' ;;
esac
fs::require_file theme "$theme/mono.css"

for directory in "${directories[@]}"; do
    [[ -f "$directory/profiles.ini" ]] || continue
    profiles=$(exec::query awk -v root="$directory" '
        function emit() { if (profile && path != "") print relative == "0" ? path : root "/" path }
        /^\[/ { emit(); profile = /^\[Profile[0-9]+\]/; path = ""; relative = "1" }
        /^IsRelative=/ { relative = substr($0, 12); sub(/\r$/, "", relative) }
        /^Path=/ { path = substr($0, 6); sub(/\r$/, "", path) }
        END { emit() }
    ' "$directory/profiles.ini") || exit $?
    while IFS= read -r profile; do
        [[ -d "$profile" ]] || continue
        chrome="$profile/chrome"
        style::link "$theme/mono.css" "$chrome/mono.css"
        style::line "$chrome/userChrome.css" '@import url("mono.css");' prepend
        if [[ -f "$theme/content.css" ]]; then
            style::link "$theme/content.css" "$chrome/mono-content.css"
            style::line "$chrome/userContent.css" '@import url("mono-content.css");' prepend
        fi
        style::line "$profile/user.js" 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'
        log::info "Configured Mono browser colors: ${profile##*/}"
    done <<<"$profiles"
done
