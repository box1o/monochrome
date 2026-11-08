#!/usr/bin/env bash

set -uo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/../.init.sh" || exit $?

script::init
script::parse "$@" || exit $?

if args::has help; then
    script::usage ''
    exit 0
fi

script::require_count 0 0 || exit $?

set -- "${SCRIPT_ARGS[@]}"

SCRIPT_DIR="$(path::absolute "${BASH_SOURCE[0]%/*}")"
PICTURES_DIR="$(exec::query xdg-user-dir PICTURES 2>/dev/null || true)"
PICTURES_DIR="${PICTURES_DIR:-$HOME/Pictures}"
OUTPUT_DIR="$PICTURES_DIR/Screenshots"
SHOT=""

cleanup() {
    [[ -z $SHOT ]] || fs::remove_file "$SHOT"
}

trap cleanup EXIT

if [[ ${SHELL_LIB_DRY_RUN:-false} == true ]]; then
    log::info "DRY-RUN capture region, save to $OUTPUT_DIR, and copy to clipboard"
    exit 0
fi

runtime_dir="${XDG_RUNTIME_DIR:-/tmp/mono-$UID}"

fs::mkdir "$runtime_dir" || exit 1

SHOT="$(temp::file mono-shot "$runtime_dir")" || exit 1

SNAP=false

if exec::run --quiet -- grim -t ppm "$SHOT" 2>/dev/null; then SNAP=true; fi

GEOM="$(exec::run --quiet -- slurp -b 00000060 -c ffffffff -w 1)" || exit 0

[[ -n $GEOM ]] || exit 0

fs::mkdir "$OUTPUT_DIR" || exit 1

OUT="$OUTPUT_DIR/$(exec::query date +'Screenshot_%Y-%m-%d_%H-%M-%S').png"

if $SNAP; then
    exec::run --quiet -- bash "$SCRIPT_DIR/crop.sh" "$SHOT" "$GEOM" "$OUT" || exit 1
else
    exec::run --quiet -- grim -g "$GEOM" "$OUT" || exit 1
fi

exec::run --quiet -- wl-copy -t image/png <"$OUT"
if proc::exists notify-send; then
    exec::run --quiet -- notify-send -a Mono "Screenshot copied" "$OUT"
fi
