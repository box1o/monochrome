#!/usr/bin/env bash

set -u

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/../.init.sh" || exit $?

script::init
script::parse "$@" || exit $?

if args::has help; then
    script::usage 'status|reconnect'
    exit 0
fi

script::require_count 0 1 || exit $?

set -- "${SCRIPT_ARGS[@]}"

case "${1:-status}" in
    status)
        exec::query nmcli -t -f GENERAL.STATE,GENERAL.CONNECTION,IP4.ADDRESS device show 2> /dev/null | exec::query sed -n 's/^GENERAL.STATE:\([0-9]*\).*/state=\1/p; s/^GENERAL.CONNECTION:\(.*\)/name=\1/p; s/^IP4.ADDRESS\[[0-9]*\]:\([^/]*\).*/ip=\1/p' | exec::query head -3
        ;;
    reconnect)
        exec::run --quiet -- nmcli networking off
        exec::run --quiet -- sleep 1
        exec::run --quiet -- nmcli networking on
        ;;
    *) log::fatal --code 2 'Expected status or reconnect' ;;
esac
