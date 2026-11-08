#!/usr/bin/env bash

set -euo pipefail
# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/../.init.sh" || exit $?

files::bookmark() {
    local file=$1 directory=$2 label=$3 uri
    directory=$(path::absolute "$directory") || return
    [[ -d "$directory" && $directory != "$HOME" ]] || return 0
    uri=$(exec::query jq -nr --arg path "$directory" '"file://" + ($path | split("/") | map(@uri) | join("/"))') || return
    if [[ -f "$file" ]] && exec::query awk -v uri="$uri" '$1 == uri { found = 1 } END { exit !found }' "$file" 2>/dev/null; then
        return
    fi
    style::line "$file" "$uri $label"
}

script::init
script::parse_command "$@"
if args::has help; then
    script::usage 'setup [project-directory]|terminal|copy|edit [paths...]'
    exit 0
fi
script::require_count 1 256
set -- "${SCRIPT_ARGS[@]}"
action=$1
shift

case "$action" in
    setup)
        (($# <= 1)) || log::fatal --code 2 'setup accepts one project directory'
        proc::require jq xdg-user-dir awk cmp
        bookmarks="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-3.0/bookmarks"
        # Reuse the application integration helpers; bookmarks are additive.
        # shellcheck source=style/common.sh
        source "${BASH_SOURCE[0]%/*}/style/common.sh"
        for folder in DOCUMENTS DOWNLOAD PICTURES VIDEOS; do
            directory=$(exec::query xdg-user-dir "$folder")
            files::bookmark "$bookmarks" "$directory" "${directory##*/}"
        done
        if [[ -n ${1:-} && -d $1 ]]; then
            directory=$(path::absolute "$1")
            files::bookmark "$bookmarks" "$directory" Mono
        fi
        ;;
    terminal)
        proc::require kitty
        if [[ $# == 0 && ${NAUTILUS_SCRIPT_CURRENT_URI:-file:///} != file:///* ]]; then
            log::fatal 'Open in Terminal supports local folders only'
        fi
        directory=${1:-$PWD}
        [[ -d "$directory" ]] || directory=$(path::dirname "$directory")
        fs::require_dir directory "$directory"
        exec::run --quiet -- kitty --directory "$directory"
        ;;
    copy)
        proc::require wl-copy
        (($#)) || set -- "$PWD"
        printf '%s\n' "$@" | exec::run --quiet -- wl-copy
        ;;
    edit)
        proc::require mousepad file
        (($#)) || log::fatal 'Select a text file first'
        for path in "$@"; do
            fs::require_file text-file "$path"
            mime=$(exec::query file --brief --mime-type -- "$path")
            case "$mime" in
                text/* | application/json | application/xml | application/javascript | inode/x-empty) ;;
                *) log::fatal "Select text files only: ${path##*/}" ;;
            esac
        done
        exec::run --quiet -- mousepad -- "$@"
        ;;
    *) log::fatal --code 2 "Unknown file action: $action" ;;
esac
