#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PICTURES_DIR="$(xdg-user-dir PICTURES 2>/dev/null || true)"
PICTURES_DIR="${PICTURES_DIR:-$HOME/Pictures}"
OUTPUT_DIR="$PICTURES_DIR/Screenshots"
SHOT=""
FROZEN=false

ipc() { qs ipc call mono "$@" >/dev/null 2>&1; }

cleanup() {
    $FROZEN && ipc unfreeze
    [[ -n $SHOT ]] && rm -f -- "$SHOT"
}
trap cleanup EXIT

runtime_dir="${XDG_RUNTIME_DIR:-/tmp/mono-$UID}"
mkdir -p -- "$runtime_dir" || exit 1
SHOT="$(mktemp --tmpdir="$runtime_dir" mono-shot.XXXXXXXX.ppm)" || exit 1

SNAP=false
if grim -t ppm "$SHOT" 2>/dev/null; then SNAP=true; fi

if $SNAP && ipc freeze "$SHOT"; then
    FROZEN=true
    sleep 0.08
fi

GEOM="$(slurp -b 00000060 -c ffffffff -w 1)" || exit 0
[[ -n $GEOM ]] || exit 0

if $FROZEN; then ipc unfreeze; FROZEN=false; fi

mkdir -p -- "$OUTPUT_DIR" || exit 1
OUT="$OUTPUT_DIR/$(date +'Screenshot_%Y-%m-%d_%H-%M-%S').png"

if $SNAP; then
    python3 "$SCRIPT_DIR/shotcrop.py" "$SHOT" "$GEOM" "$OUT" || exit 1
else
    grim -g "$GEOM" "$OUT" || exit 1
fi

wl-copy -t image/png < "$OUT"
ipc shotCopied "$OUT"
