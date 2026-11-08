#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/../.init.sh" || exit $?

script::init
script::parse "$@" || exit $?

if args::has help; then
    script::usage 'backup|restore'
    exit 0
fi

script::require_count 0 1 || exit $?

set -- "${SCRIPT_ARGS[@]}"

root="${XDG_CONFIG_HOME:-$HOME/.config}"
dir="$HOME/Backups/mono"

case "${1:-backup}" in
    backup)
        fs::require_dir configuration "$root"

        fs::mkdir "$dir"

        out="$dir/mono-$(exec::query date +%Y-%m-%d_%H-%M-%S).tar.gz"

        exec::run --quiet -- tar -czf "$out" -C "$root" quickshell hypr kitty nvim
        exec::run --quiet -- notify-send -a Mono 'Configuration backup' "$out"
        ;;
    restore)
        archive=''

        for candidate in "$dir"/*.tar.gz; do
            fs::is_file "$candidate" || continue

            if [[ -z "$archive" || "$candidate" -nt "$archive" ]]; then
                archive=$candidate
            fi
        done

        validate::not_empty backup "$archive"

        archive::extract "$archive" "$root"
        exec::run --quiet -- notify-send -a Mono 'Configuration restore' "Restored ${archive##*/}"
        ;;
    *) log::fatal --code 2 "usage: ${0##*/} [--dry-run] backup|restore" ;;
esac
