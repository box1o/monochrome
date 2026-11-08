#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/../.init.sh" || exit $?

script::init
script::parse "$@"
if args::has help; then
    script::usage 'list|copy ID|delete ID|clear'
    exit 0
fi
script::require_count 1 2
proc::require cliphist wl-copy

action=${SCRIPT_ARGS[0]}
case "$action" in
    list | clear) script::require_count 1 1 ;;
    copy | delete)
        script::require_count 2 2
        [[ ${SCRIPT_ARGS[1]} =~ ^[0-9]+$ ]] || log::fatal --code 2 'Invalid clipboard entry'
        ;;
    *) log::fatal --code 2 "Unknown clipboard action: $action" ;;
esac

if [[ $action != list && ${SHELL_LIB_DRY_RUN:-false} == true ]]; then
    log::info "DRY-RUN clipboard $action"
    exit 0
fi

case "$action" in
    list) exec::query cliphist list ;;
    copy)
        output=$(temp::file mono-clipboard)
        trap 'fs::remove_file "$output"' EXIT
        printf '%s\t' "${SCRIPT_ARGS[1]}" | exec::query cliphist decode | fs::write "$output"
        exec::run --quiet -- wl-copy <"$output"
        ;;
    delete) printf '%s\t' "${SCRIPT_ARGS[1]}" | exec::run --quiet -- cliphist delete ;;
    clear) exec::run --quiet -- cliphist wipe ;;
esac
