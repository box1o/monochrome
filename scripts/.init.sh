#!/usr/bin/env bash

# Resolve the source checkout or the installed runtime in one place.
if [[ -f "${BASH_SOURCE[0]%/*}/../lib/script.sh" ]]; then
    # A checkout runs its own library, even when a login exported an installed path.
    MONO_LIB_DIR="${BASH_SOURCE[0]%/*}/../lib"
    MONO_HELPER_DIR="${BASH_SOURCE[0]%/*}"
else
    MONO_LIB_DIR="${MONO_LIB_DIR:-${HOME}/.local/lib/mono}"
    MONO_HELPER_DIR="${HOME}/.local/libexec/mono"
fi

MONO_LIB_DIR=$(cd -- "$MONO_LIB_DIR" && pwd -P) || return

MONO_HELPER_DIR=$(cd -- "$MONO_HELPER_DIR" && pwd -P) || return

export MONO_LIB_DIR MONO_HELPER_DIR

# shellcheck source=../lib/script.sh
source "${MONO_LIB_DIR}/script.sh"
