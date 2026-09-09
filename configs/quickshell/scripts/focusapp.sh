#!/usr/bin/env bash
set -uo pipefail

hint="${1:-}"
if [[ -z $hint ]]; then
    printf 'usage: %s DESKTOP_ID\n' "${0##*/}" >&2
    exit 2
fi
base="${hint%.desktop}"

addr="$(hyprctl -j clients 2>/dev/null | jq -r --arg h "$base" '
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
    out="$(hyprctl dispatch "hl.dsp.focus({ window = \"address:$addr\" })" 2>&1)"
    case "$out" in
        ok*) ;;
        *) hyprctl dispatch focuswindow "address:$addr" >/dev/null 2>&1 ;;
    esac
    exit 0
fi

for d in "$HOME/.local/share/applications" /usr/share/applications \
         /var/lib/flatpak/exports/share/applications \
         "$HOME/.local/share/flatpak/exports/share/applications"; do
    f="$d/$base.desktop"
    if [[ -f $f ]]; then
        gio launch "$f" >/dev/null 2>&1 &
        exit 0
    fi
done

short="${base##*.}"
for c in "$base" "$short"; do
    if command -v "$c" >/dev/null 2>&1; then
        setsid "$c" >/dev/null 2>&1 &
        exit 0
    fi
done
printf 'application not found: %s\n' "$hint" >&2
exit 1
