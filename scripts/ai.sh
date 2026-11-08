#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/.init.sh" || exit $?

script::init
args::option --name ignore --default ""
args::option --name ignore-only
args::option --name prompt
script::parse "$@" || exit $?

if args::has help; then
    script::usage '[directory] [--ignore CSV] [--ignore-only CSV] [--prompt TEXT]'
    exit 0
fi

script::require_count 0 1 || exit $?

config::load_shell ai

target=${SCRIPT_ARGS[0]:-.}
ignore=${AI_IGNORE:-node_modules,build,dist,.next,.cache,__pycache__,vendor,target,coverage,.vscode,package-lock.json,yarn.lock,pnpm-lock.yaml}

if args::has ignore-only; then
    ignore=$(args::get ignore-only)
fi

if args::has ignore; then
    ignore+=,$(args::get ignore)
fi

prompt=$(args::get prompt "${AI_PROMPT:-Please analyze this project structure.}")

fs::require_dir project "$target"
proc::require tree file find

ai::write_context() {
    local file item
    local -a excluded=() find_args=("$target")

    IFS=',' read -r -a excluded <<< ".git,$ignore"

    local pattern='.git'

    for item in "${excluded[@]}"; do
        [[ -n "$item" ]] || continue

        pattern+="|$item"
        find_args+=(-not -name "$item" -not -path "*/$item/*")
    done

    printf 'AI PROJECT ANALYSIS PROMPT\n%s\n\nPROJECT STRUCTURE\n' "$prompt"

    exec::run --quiet -- tree --gitignore -a -I "$pattern" "$target"

    printf '\nFILE CONTENTS\n'

    while IFS= read -r -d '' file; do
        if [[ $(exec::query file --brief --mime-type -- "$file") != text/* ]]; then
            printf '\n--- FILE: %s (binary skipped) ---\n' "$file"
            continue
        fi

        printf '\n--- FILE: %s ---\n' "$file"

        fs::read "$file"
    done < <(exec::query find "${find_args[@]}" -type f -print0)
}

if [[ ${SHELL_LIB_DRY_RUN:-false} == true ]]; then
    log::info "DRY-RUN build project context for $target"
    exit 0
fi

output=$(temp::file mono-ai)

trap 'fs::remove_file "$output"' EXIT

ai::write_context | fs::write "$output"

if proc::exists wl-copy && [[ -n ${WAYLAND_DISPLAY:-} ]]; then
    clipboard::copy < "$output"

    log::info 'Copied project context to clipboard'
else
    fs::read "$output"
fi
