#!/usr/bin/env bash

if [[ ${MONO_INSTALLER_INITIALIZED:-0} == 1 ]]; then
    return 0
fi

MONO_INSTALLER_INITIALIZED=1

MONO_INSTALLER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly MONO_INSTALLER_DIR

installer::_source() {
    local __relative_path__=${1:-}

    # shellcheck disable=SC1090
    source "${MONO_INSTALLER_DIR}/${__relative_path__}"
}

installer::_source cli.sh
installer::_source packages.sh
installer::_source hardware.sh
installer::_source package-manager.sh
installer::_source configs.sh
installer::_source scripts.sh
installer::_source watcher.sh
installer::_source menu.sh
installer::_source app.sh
