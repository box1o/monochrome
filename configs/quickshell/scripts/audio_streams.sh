#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

usage() {
    printf 'usage: %s list | set-volume ID PERCENT | toggle-mute ID\n' "${0##*/}" >&2
}

require_id() {
    [[ ${1:-} =~ ^[0-9]+$ ]] || {
        printf 'invalid stream id: %s\n' "${1:-}" >&2
        exit 2
    }
}

case "${1:-list}" in
    list)
        exec python3 "$SCRIPT_DIR/audio_streams.py"
        ;;
    set-volume)
        require_id "${2:-}"
        [[ ${3:-} =~ ^[0-9]+$ ]] || { usage; exit 2; }
        (( 10#$3 <= 150 )) || { printf 'volume exceeds 150%%\n' >&2; exit 2; }
        exec pactl set-sink-input-volume "$2" "$3%"
        ;;
    toggle-mute)
        require_id "${2:-}"
        exec pactl set-sink-input-mute "$2" toggle
        ;;
    *)
        usage
        exit 2
        ;;
esac
