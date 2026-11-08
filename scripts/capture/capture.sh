#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/../.init.sh" || exit $?

script::init
script::parse "$@" || exit $?

if args::has help; then
    script::usage 'screenshot|record|record-start|record-stop'
    exit 0
fi

script::require_count 1 1 || exit $?

set -- "${SCRIPT_ARGS[@]}"

SCRIPT_DIR="$(path::absolute "${BASH_SOURCE[0]%/*}")"

case "${1:-}" in
    screenshot)
        exec::run --quiet -- "$SCRIPT_DIR/shot.sh"
        ;;
    record | record-start | record-stop)
        video_dir=$(exec::query xdg-user-dir VIDEOS 2> /dev/null || true)
        outdir="${video_dir:-$HOME/Videos}"
        outdir="${outdir%/}/Recordings"

        if exec::query pgrep -u "$UID" -x wf-recorder > /dev/null 2>&1; then
            [[ "$1" != record-start ]] || exit 0
            exec::run --quiet -- pkill -INT -u "$UID" -x wf-recorder
            exit 0
        fi

        [[ "$1" != record-stop ]] || exit 0

        proc::require wf-recorder hyprctl jq setsid

        output=$(exec::query hyprctl monitors -j | exec::query jq -r 'sort_by(.y, .x) | .[0].name // empty')
        [[ -n "$output" ]] || log::fatal "No recording output available"

        if [[ ${SHELL_LIB_DRY_RUN:-false} == true ]]; then
            log::info "DRY-RUN record $output to $outdir"
            exit 0
        fi

        fs::mkdir "$outdir"
        exec::run --quiet -- setsid -f wf-recorder -o "$output" -f "$outdir/Recording_$(exec::query date +%Y-%m-%d_%H-%M-%S).mkv" < /dev/null > /dev/null 2>&1
        log::info "Recording started on $output"
        ;;
    *) log::fatal --code 2 "usage: ${0##*/} [--dry-run] screenshot|record|record-start|record-stop" ;;
esac
