#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/../.init.sh" || exit $?

script::init
args::option --name root --default "${MONO_PROJECT_ROOT:-${BASH_SOURCE[0]%/*}/../..}"
script::parse "$@"
if args::has help; then
    script::usage '[--root PROJECT-DIRECTORY]'
    exit 0
fi
script::require_count 0 0
root=$(path::absolute "$(args::get root)")
command=(bash "$root/themes/theme.sh" --root "$root")
[[ ${SHELL_LIB_DRY_RUN:-false} != true ]] || command+=(--dry-run)
if [[ ${SHELL_LIB_DRY_RUN:-false} == true ]]; then
    exec::query "${command[@]}"
else
    exec::run --quiet -- "${command[@]}"
fi
