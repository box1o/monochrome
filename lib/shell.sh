#!/usr/bin/env bash

if [[ -z ${BASH_VERSION:-} ]]; then
    printf '%s\n' 'shell library requires Bash' >&2
    return 2
fi

if [[ -z ${SHELL_LIB_ENTRY_DIR+x} ]]; then
    SHELL_LIB_ENTRY_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
    readonly SHELL_LIB_ENTRY_DIR
fi

# shellcheck disable=SC1091
source "${SHELL_LIB_ENTRY_DIR}/init.sh"
