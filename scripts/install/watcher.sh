#!/usr/bin/env bash

watcher::_selected() {
    case $'\n'"${2:-}"$'\n' in
        *$'\n'"${1:-}"$'\n'*) return 0 ;;
        *) return 1 ;;
    esac
}

watcher::_configs_for_path() {
    local path=${1:-} name source
    if [[ "$path" == "$MONO_ROOT/themes/"* ]]; then
        configs::available
        return
    fi
    while IFS= read -r name; do
        source=$(configs::source "$name") || return
        case "$source" in
            "$MONO_ROOT/generated/"*) source="$MONO_ROOT/configs/${source#"$MONO_ROOT/generated/"}" ;;
        esac
        case "$path" in
            "$source" | "$source"/*) printf '%s\n' "$name" ;;
        esac
    done < <(configs::available)
}

watcher::_queue() {
    local path=${1:-} selected=${2:-} reference=${3:-} name
    var::_validate_reference "$reference" || return
    local -n pending_ref=$reference
    while IFS= read -r name; do
        watcher::_selected "$name" "$selected" || continue
        # shellcheck disable=SC2034 # The caller consumes this nameref.
        pending_ref["$name"]=true
    done < <(watcher::_configs_for_path "$path")
}

watcher::configs() {
    local selection=${1:-all} dry_run=${2:-false}
    validate::boolean dry-run "$dry_run" || return
    configs::validate_manifest || return
    proc::require inotifywait || return

    local selected
    selected=$(configs::normalize "$selection") || return
    local -a roots=("$MONO_ROOT/configs" "$MONO_ROOT/themes" "$MONO_ROOT/assets")
    local root
    for root in "${roots[@]}"; do
        fs::require_dir watch-root "$root" || return
    done

    log::info 'Watching selected configurations, theme source and shared assets'
    if [[ "$dry_run" == true ]]; then
        exec::run --dry-run -- inotifywait --monitor --recursive \
            --event close_write,create,delete,move -- "${roots[@]}"
        return
    fi

    coproc MONO_CONFIG_WATCH {
        exec::run --quiet -- inotifywait --monitor --recursive --quiet \
            --event close_write,create,delete,move --format '%w%f' -- "${roots[@]}"
    }
    local watch_fd=${MONO_CONFIG_WATCH[0]} watch_pid=$MONO_CONFIG_WATCH_PID
    local path names
    local -A pending=()
    while IFS= read -r -u "$watch_fd" path; do
        watcher::_queue "$path" "$selected" pending || return
        while IFS= read -r -t 0.15 -u "$watch_fd" path; do
            watcher::_queue "$path" "$selected" pending || return
        done
        ((${#pending[@]})) || continue
        names=$(list::csv "$(printf '%s\n' "${!pending[@]}")") || return
        configs::deploy "$names" false || {
            exec::run --quiet -- kill "$watch_pid" >/dev/null 2>&1 || true
            return 1
        }
        pending=()
    done
    wait "$watch_pid"
}
