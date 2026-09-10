#!/usr/bin/env bash
set -u
case "${1:-}" in
  screenshot)
    "$HOME/.config/quickshell/scripts/shot.sh" &
    ;;
  record)
    outdir="$(xdg-user-dir VIDEOS 2>/dev/null || printf '%s/Videos' "$HOME")/Recordings"; mkdir -p "$outdir"
    if pgrep -x wf-recorder >/dev/null 2>&1; then pkill -INT -x wf-recorder; exit 0; fi
    command -v wf-recorder >/dev/null 2>&1 || { notify-send -a Mono "Screen recording" "wf-recorder is not installed"; exit 1; }
    wf-recorder -f "$outdir/Recording_$(date +%Y-%m-%d_%H-%M-%S).mkv" >/dev/null 2>&1 &
    notify-send -a Mono "Screen recording" "Recording started"
    ;;
  *) printf 'usage: %s screenshot|record\n' "${0##*/}" >&2; exit 2 ;;
esac
