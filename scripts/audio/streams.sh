#!/usr/bin/env bash

set -uo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/../.init.sh" || exit $?

script::init
script::parse "$@" || exit $?

if args::has help; then
    script::usage 'list|set-volume ID PERCENT|toggle-mute ID|move ID SINK'
    exit 0
fi

script::require_count 0 3 || exit $?

set -- "${SCRIPT_ARGS[@]}"

SCRIPT_DIR="$(path::absolute "${BASH_SOURCE[0]%/*}")"

usage() { script::usage 'list|set-volume ID PERCENT|toggle-mute ID|move ID SINK' >&2; }

require_id() { validate::non_negative_integer stream-id "${1:-}" || exit 2; }

case "${1:-list}" in
    list)
        proc::require pactl jq timeout
        if snapshot=$(LC_ALL=C exec::query timeout 3 pactl --format=json list sink-inputs 2>/dev/null); then
            exec::query jq -c -f "$SCRIPT_DIR/streams.jq" <<<"$snapshot"
        else
            printf '[]\n'
        fi
        ;;
    set-volume)
        require_id "${2:-}"

        [[ ${3:-} =~ ^[0-9]+$ ]] || {
            usage
            exit 2
        }

        ((10#$3 <= 150)) || { log::fatal --code 2 'Volume exceeds 150%'; }

        exec::run --quiet -- pactl set-sink-input-volume "$2" "$3%"
        ;;
    toggle-mute)
        require_id "${2:-}"
        exec::run --quiet -- pactl set-sink-input-mute "$2" toggle
        ;;
    move)
        require_id "${2:-}"
        require_id "${3:-}"
        exec::run --quiet -- pactl move-sink-input "$2" "$3"
        ;;
    *)
        usage
        exit 2
        ;;
esac
