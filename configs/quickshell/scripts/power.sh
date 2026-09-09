#!/usr/bin/env bash
set -uo pipefail

BUS="net.hadess.PowerProfiles"
OBJ="/net/hadess/PowerProfiles"

case "${1:-}" in
    get)
        busctl --system --timeout=3s get-property "$BUS" "$OBJ" "$BUS" ActiveProfile 2>/dev/null \
            | sed 's/^s //; s/"//g'
        ;;
    set)
        profile="${2:-}"
        case "$profile" in
            power-saver|balanced|performance) ;;
            *) printf 'invalid power profile: %s\n' "$profile" >&2; exit 2 ;;
        esac
        busctl --system --timeout=3s set-property "$BUS" "$OBJ" "$BUS" ActiveProfile s "$profile" 2>/dev/null
        ;;
    *)
        printf 'usage: %s get | set <power-saver|balanced|performance>\n' "${0##*/}" >&2
        exit 2
        ;;
esac
