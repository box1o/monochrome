#!/usr/bin/env bash

if [[ -z ${BASH_VERSION:-} ]]; then
    printf '%s\n' 'Mono installer requires Bash' >&2
    exit 2
fi

MONO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly MONO_ROOT

# shellcheck disable=SC1091
source "${MONO_ROOT}/lib/shell.sh"
# shellcheck disable=SC1091
source "${MONO_ROOT}/installer/init.sh"

installer::main "$@"
