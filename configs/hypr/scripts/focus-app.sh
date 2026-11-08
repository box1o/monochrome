#!/usr/bin/env bash

set -uo pipefail

bootstrap="${BASH_SOURCE[0]%/*}/../../../scripts/.init.sh"
[[ -f "$bootstrap" ]] || bootstrap="${HOME}/.local/libexec/mono/.init.sh"
# shellcheck source=/dev/null
source "$bootstrap" || exit $?

script::init
script::parse "$@" || exit $?

if args::has help; then
    script::usage 'DESKTOP-ID'
    exit 0
fi

script::require_count 1 1 || exit $?

set -- "${SCRIPT_ARGS[@]}"

hint="${1:-}"

if [[ -z $hint ]]; then
    script::usage 'DESKTOP-ID' >&2
    exit 2
fi

base="${hint%.desktop}"

addr="$(exec::query hyprctl -j clients 2>/dev/null | exec::query jq -r --arg h "$base" '
    ($h | ascii_downcase) as $l
    | ($l | split(".") | last) as $short
    | map(select(
          ((.class // "") | ascii_downcase | contains($l))
          or ((.initialClass // "") | ascii_downcase | contains($l))
          or ((.class // "") | ascii_downcase | contains($short))
          or ((.initialClass // "") | ascii_downcase | contains($short))
          or ((.title // "") | ascii_downcase | contains($short))
      ))
    | .[0].address // empty')"

if [ -n "$addr" ]; then
    exec::run --quiet -- hyprctl dispatch "hl.dsp.focus({ window = \"address:$addr\" })"
    exit $?
fi

for d in "$HOME/.local/share/applications" /usr/share/applications \
    /var/lib/flatpak/exports/share/applications \
    "$HOME/.local/share/flatpak/exports/share/applications"; do
    f="$d/$base.desktop"

    if [[ -f $f ]]; then
        exec::run --quiet -- gio launch "$f" >/dev/null 2>&1 &
        exit 0
    fi
done

short="${base##*.}"

for c in "$base" "$short"; do
    if proc::exists "$c"; then
        exec::run --quiet -- setsid "$c" >/dev/null 2>&1 &
        exit 0
    fi
done

log::error "Application not found: $hint"
exit 1
