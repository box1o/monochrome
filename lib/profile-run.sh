#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=script.sh
source "${BASH_SOURCE[0]%/*}/script.sh"

script::init

script::parse_command "$@"

exec::run --quiet -- "${SCRIPT_ARGS[@]}"
