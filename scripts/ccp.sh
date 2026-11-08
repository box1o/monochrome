#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/.init.sh" || exit $?

script::init
args::option --name file --short f
args::flag --name verbose --short v
args::flag --name copy --short c
script::parse "$@" || exit $?

if args::has help; then
    script::usage '--file PATH [--verbose] [--copy]'
    exit 0
fi

script::require_count 0 0 || exit $?

config::load_shell ccp

paths_file=$(args::get file)

fs::require_file paths-list "$paths_file"

ccp::write_files() {
    local line file

    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        file=${line%\"}
        file=${file#\"}
        file=${file%\'}
        file=${file#\'}
        file=${file/#\~/${HOME}}

        if ! fs::is_file "$file"; then
            log::warn "Missing: $file"
            continue
        fi

        if args::has verbose; then log::info "Reading $file"; fi

        printf '====\n%s\n====\n' "$file"

        fs::read "$file"

        printf '\n\n'
    done < "$paths_file"
}

if [[ ${SHELL_LIB_DRY_RUN:-false} == true ]]; then
    log::info "DRY-RUN combine files from $paths_file"
    exit 0
fi

output=$(temp::file mono-ccp)

trap 'fs::remove_file "$output"' EXIT

ccp::write_files | fs::write "$output"
fs::read "$output"

if args::has copy; then clipboard::copy < "$output"; fi
