#!/usr/bin/env bash
# jq/awk expressions are intentionally not shell-expanded.
# shellcheck disable=SC2016

set -euo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/../scripts/.init.sh" || exit $?

script::init
args::option --name root --default "${BASH_SOURCE[0]%/*}/.."
script::parse "$@"
if args::has help; then
    script::usage '[--root PROJECT-DIRECTORY]'
    exit 0
fi
script::require_count 0 0
proc::require jq find sort cmp realpath

engine=$(path::absolute "${BASH_SOURCE[0]%/*}")
root=$(path::absolute "$(args::get root)")
fs::require_dir project "$root"
theme=$(yaml::to_json "$root/themes/mono.yaml" | exec::query jq -s -e 'if length == 1 then .[0] else error("Expected one YAML document") end')
exec::query jq -e -f "$engine/validate.jq" <<<"$theme" >/dev/null
values=$(exec::query jq --arg config "${XDG_CONFIG_HOME:-$HOME/.config}" --arg data "${XDG_DATA_HOME:-$HOME/.local/share}" -f "$engine/render.jq" <<<"$theme")

declare -A rendered=() sources=() outputs=()
while IFS=$'\t' read -r template relative; do
    [[ $relative != nvim/* || -d $root/configs/nvim ]] || continue
    [[ $relative != quickshell/* || -d $root/configs/quickshell ]] || continue
    rendered["$relative"]=$(exec::query jq -nr --argjson values "$values" --rawfile template "$engine/templates/$template" '
        $template | gsub("\\{\\{(?<name>[^}]+)\\}\\}"; $values[.name] // error("Unknown template field: " + .name))')
    outputs["$relative"]=true
done < <(exec::query jq -r 'to_entries[] | [.key,.value] | @tsv' "$engine/adapters.json")

if [[ -d $root/configs ]]; then
    while IFS= read -r -d '' file; do
        [[ -f $file ]] || continue
        resolved=$(path::absolute "$file")
        [[ $resolved == "$root/configs/"* ]] || log::fatal "Configuration source escapes project: $file"
        relative=${file#"$root/configs/"}
        sources["$relative"]=$file
        outputs["$relative"]=true
    done < <(exec::query find "$root/configs" \( -type f -o -type l \) -print0)
fi

# Validate every destination before the first write, including existing symlinks.
for relative in "${!outputs[@]}"; do
    resolved=$(path::absolute "$root/generated/$relative")
    [[ $resolved == "$root/generated/"* ]] || log::fatal "Output escapes generated folder: $relative"
done

for relative in "${!outputs[@]}"; do
    target="$root/generated/$relative"
    if [[ -v rendered["$relative"] ]]; then
        if [[ ! -f $target ]] || ! printf '%s\n' "${rendered[$relative]}" | exec::query cmp -s "$target" - 2>/dev/null; then
            printf '%s\n' "${rendered[$relative]}" | fs::atomic_write "$target"
        fi
    elif [[ ! -f $target ]] || ! exec::query cmp -s "${sources[$relative]}" "$target" 2>/dev/null; then
        fs::copy_file "${sources[$relative]}" "$target"
    fi
done

if [[ -d $root/generated ]]; then
    while IFS= read -r -d '' file; do
        relative=${file#"$root/generated/"}
        [[ -v outputs["$relative"] ]] || fs::remove_file "$file"
    done < <(exec::query find "$root/generated" -type f -print0)
fi
log::info "Theme validated; ${#rendered[@]} native adapters"
