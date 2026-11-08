#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/../.init.sh" || exit $?

script::init
script::parse "$@"
if args::has help; then
    script::usage 'setup|list|edit|copy|add|delete ID|save ID'
    exit 0
fi
script::require_count 1 2
action=${SCRIPT_ARGS[0]}
if [[ $action == delete || $action == save ]]; then
    script::require_count 2 2
    [[ ${SCRIPT_ARGS[1]} =~ ^[A-Za-z0-9_.-]+$ ]] || log::fatal --code 2 'Invalid snippet id'
else
    script::require_count 1 1
fi
file="${XDG_CONFIG_HOME:-$HOME/.config}/mono/snippets.yaml"

case "$action" in
    setup)
        if [[ ! -e "$file" ]]; then
            fs::mkdir_parent "$file"
            fs::copy_file "${BASH_SOURCE[0]%/*}/snippets.yaml" "$file"
            fs::chmod 600 "$file"
        fi
        ;;
    list)
        yaml::to_json "$file"
        ;;
    edit)
        fs::require_file snippets "$file"
        exec::run --quiet -- kitty --class mono-snippets -e nvim -- "$file"
        ;;
    add)
        if [[ ${SHELL_LIB_DRY_RUN:-false} == true ]]; then
            log::info 'DRY-RUN add clipboard text to snippets'
            exit 0
        fi
        proc::require wl-paste jq
        clipboard=$(temp::file mono-snippet)
        document=$(temp::file mono-snippets)
        trap 'fs::remove_file "$clipboard"; fs::remove_file "$document"' EXIT
        exec::query wl-paste --no-newline --type text | fs::write "$clipboard"
        [[ -s "$clipboard" ]] || log::fatal 'Clipboard has no text'
        size=$(exec::query stat --format=%s -- "$clipboard")
        ((size <= 4194304)) || log::fatal 'Snippet exceeds 4 MiB'
        yaml::_require_yq
        id=$(fs::read /proc/sys/kernel/random/uuid)
        yaml::to_json "$file" | exec::query jq --arg id "$id" --rawfile body "$clipboard" '
        if (.snippets | type) != "array" then error("Expected snippets list") else
            .snippets = [{id: $id,
                title: (($body | split("\n") | map(select(test("\\S"))) | .[0] // "Untitled")[:56]),
                language: "auto", body: $body}] + .snippets
        end' | fs::write "$document"
        exec::query "$YAML_COMMAND" eval -P -o=yaml '.' "$document" | fs::atomic_write "$file"
        ;;
    save)
        if [[ ${SHELL_LIB_DRY_RUN:-false} == true ]]; then
            log::info 'DRY-RUN save snippet'
            exit 0
        fi
        document=$(temp::file mono-snippet)
        updated=$(temp::file mono-snippets)
        trap 'fs::remove_file "$document"; fs::remove_file "$updated"' EXIT
        fs::write "$document"
        exec::query jq -e '
            (.title | type == "string" and length > 0) and
            (.body | type == "string" and length > 0)' "$document" >/dev/null
        yaml::_require_yq
        yaml::to_json "$file" | exec::query jq --arg id "${SCRIPT_ARGS[1]}" --slurpfile draft "$document" '
            if any(.snippets[]; .id == $id) then
                .snippets |= map(if .id == $id then .title = $draft[0].title | .body = $draft[0].body else . end)
            else error("Snippet no longer exists") end' | fs::write "$updated"
        exec::query "$YAML_COMMAND" eval -P -o=yaml '.' "$updated" | fs::atomic_write "$file"
        ;;
    delete)
        if [[ ${SHELL_LIB_DRY_RUN:-false} == true ]]; then
            log::info 'DRY-RUN delete snippet'
            exit 0
        fi
        yaml::_require_yq
        updated=$(temp::file mono-snippets)
        trap 'fs::remove_file "$updated"' EXIT
        yaml::to_json "$file" | exec::query jq --arg id "${SCRIPT_ARGS[1]}" \
            '.snippets |= map(select(.id != $id))' | fs::write "$updated"
        exec::query "$YAML_COMMAND" eval -P -o=yaml '.' "$updated" | fs::atomic_write "$file"
        ;;
    copy)
        exec::run --quiet -- wl-copy
        ;;
    *) log::fatal --code 2 "Unknown snippets action: $action" ;;
esac
