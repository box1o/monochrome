#!/usr/bin/env bash

# Compatibility names exposed to existing project build files.
# shellcheck source=../.init.sh
source "${BASH_SOURCE[0]%/*}/../.init.sh"

fatal() { log::fatal "$@"; }

log() { log::info "$@"; }

err() { log::error "$@"; }

wrn() { log::warn "$@"; }

gbl_fatal() { log::fatal "$@"; }

gbl_log() { log::info "$@"; }

gbl_err() { log::error "$@"; }

error_trap() { trap 'log::fatal "Error on line ${LINENO}"' ERR; }
