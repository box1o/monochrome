#!/usr/bin/env bash

set -uo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/../.init.sh" || exit $?

script::init
script::parse "$@" || exit $?

if args::has help; then
    script::usage 'get|set PROFILE'
    exit 0
fi

script::require_count 1 2 || exit $?

set -- "${SCRIPT_ARGS[@]}"

BUS="net.hadess.PowerProfiles"
OBJ="/net/hadess/PowerProfiles"

case "${1:-}" in
    get)
        exec::query busctl --system --timeout=3s get-property "$BUS" "$OBJ" "$BUS" ActiveProfile 2> /dev/null |
            exec::query sed 's/^s //; s/"//g'
        ;;
    set)
        profile="${2:-}"

        case "$profile" in
            power-saver | balanced | performance) ;;
            *) log::fatal --code 2 "Invalid power profile: $profile" ;;
        esac

        exec::run --quiet -- busctl --system --timeout=3s set-property "$BUS" "$OBJ" "$BUS" ActiveProfile s "$profile" 2> /dev/null
        ;;
    *)
        script::usage 'get|set PROFILE' >&2
        exit 2
        ;;
esac
