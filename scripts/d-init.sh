#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/.init.sh" || exit $?

script::init
script::parse "$@" || exit $?

if args::has help; then
    script::usage '[PATH]'
    exit 0
fi

script::require_count 0 1 || exit $?

exec::run --quiet -- "${BASH_SOURCE[0]%/*}/d-init" "${SCRIPT_ARGS[@]}"
