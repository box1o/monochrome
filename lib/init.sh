#!/usr/bin/env bash

if [[ ${SHELL_LIB_INITIALIZED:-0} == 1 ]]; then
    return 0
fi

SHELL_LIB_INITIALIZED=1

SHELL_LIB_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SHELL_LIB_DIR

shell::_source() {
    local __relative_path__=${1:-}

    # shellcheck disable=SC1090
    source "${SHELL_LIB_DIR}/${__relative_path__}"
}

shell::_source log.sh
shell::_source validate.sh
shell::_source exec.sh
shell::_source var.sh
shell::_source args.sh
shell::_source menu.sh
shell::_source proc.sh
shell::_source path.sh
shell::_source paths/registry.sh
shell::_source paths/defaults.sh
shell::_source fs.sh
shell::_source temp.sh
shell::_source trap.sh
shell::_source lock.sh
shell::_source retry.sh
shell::_source env.sh
shell::_source user.sh
shell::_source system.sh
shell::_source archive.sh
shell::_source net.sh
shell::_source yaml.sh
shell::_source config.sh
shell::_source mount.sh
shell::_source chroot.sh

paths::register_defaults
