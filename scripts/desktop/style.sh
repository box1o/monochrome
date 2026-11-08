#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/../.init.sh" || exit $?

script::init
script::parse "$@"
if args::has help; then
    script::usage '[all|terminal|browser|editor|desktop|buds] [vault-path]'
    exit 0
fi
script::require_count 0 2
proc::require jq awk cmp readlink date

# Shared context for the application modules.
# shellcheck disable=SC2034
config="${XDG_CONFIG_HOME:-$HOME/.config}"
# shellcheck disable=SC2034
data="${XDG_DATA_HOME:-$HOME/.local/share}"
themes="$config/mono/applications"
modules="${BASH_SOURCE[0]%/*}/style"
selection=${SCRIPT_ARGS[0]:-all}
# shellcheck disable=SC2034
vault=${SCRIPT_ARGS[1]:-}
fs::require_dir themes "$themes"

# shellcheck source=style/common.sh
source "$modules/common.sh"

case "$selection" in
    all) targets=(terminal browser editor desktop buds) ;;
    terminal | browser | editor | desktop | buds) targets=("$selection") ;;
    *) log::fatal --code 2 "Unknown theme group: $selection" ;;
esac
if [[ "$selection" != all && "$selection" != editor ]]; then
    script::require_count 0 1
fi

for target in "${targets[@]}"; do
    # shellcheck source=/dev/null
    source "$modules/$target.sh"
    "style::$target"
done
