# Shared by Bash and Zsh; do not source the Bash-only runtime here.
# shellcheck shell=bash

profile::path_prepend() {
    [[ -d ${1:-} ]] || return 0

    case ":$PATH:" in
        *":$1:"*) ;;
        *) export PATH="$1:$PATH" ;;
    esac
}

# Bash owns the common runtime; this bridge is also safe to call from Zsh.
profile::run() {
    SHELL_LIB_DRY_RUN="${SHELL_LIB_DRY_RUN:-false}" \
        command bash "${MONO_LIB_DIR:-$HOME/.local/lib/mono}/profile-run.sh" "$@"
}

profile::exists() { command -v "$1" > /dev/null 2>&1; }
profile::query() { SHELL_LIB_DRY_RUN=false profile::run "$@"; }

profile::log() {
    local level=$1
    shift
    SHELL_LIB_DRY_RUN=false profile::run "log::$level" "$@"
}

profile::source_optional() {
    [[ -r ${1:-} ]] || return 0
    # shellcheck source=/dev/null
    source "$1"
}
