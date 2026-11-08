#!/usr/bin/env bash

style::link() {
    local source=$1 destination=$2 backup='' status
    fs::_require_source "$source" || return
    if [[ -L "$destination" ]] && [[ $(exec::query readlink -- "$destination") == "$source" ]]; then
        return
    fi
    if [[ -e "$destination" || -L "$destination" ]]; then
        backup="$destination.mono-backup"
        [[ ! -e "$backup" && ! -L "$backup" ]] || backup+=".$(exec::query date +%s%N)"
        fs::move "$destination" "$backup" || return
    fi
    if fs::symlink "$source" "$destination"; then
        return
    else
        status=$?
    fi
    if [[ -n "$backup" && ! -e "$destination" && ! -L "$destination" ]]; then
        fs::move "$backup" "$destination" || log::error "Could not restore $destination from $backup"
    fi
    return "$status"
}

style::write() {
    local file=$1 content
    content=$(exec::query cat) || return
    if [[ -f "$file" ]] && printf '%s\n' "$content" | exec::query cmp -s "$file" - 2>/dev/null; then
        return
    fi
    if [[ -f "$file" && ! -e "$file.mono-backup" ]]; then
        fs::copy_file "$file" "$file.mono-backup" || return
    fi
    printf '%s\n' "$content" | fs::atomic_write "$file"
}

style::json() {
    local file=$1 filter=$2 input='{}' output
    shift 2
    [[ ! -f "$file" ]] || input=$(fs::read "$file") || return
    output=$(exec::query jq "$@" "$filter" <<<"$input") || return
    printf '%s\n' "$output" | style::write "$file"
}

style::line() {
    local file=$1 line=$2 position=${3:-append} content=''
    if [[ -f "$file" ]] && exec::query awk -v line="$line" '$0 == line { found = 1 } END { exit !found }' "$file" 2>/dev/null; then
        return
    fi
    [[ ! -f "$file" ]] || content=$(fs::read "$file") || return
    if [[ -z "$content" ]]; then
        printf '%s\n' "$line"
    elif [[ "$position" == prepend ]]; then
        printf '%s\n%s\n' "$line" "$content"
    else
        printf '%s\n%s\n' "$content" "$line"
    fi | style::write "$file"
}

style::setting() {
    local file=$1 key=$2 value=$3 content='' output
    [[ ! -f "$file" ]] || content=$(fs::read "$file") || return
    output=$(exec::query awk -v key="$key" -v value="$value" '
        $0 ~ "^[[:space:]]*" key "[[:space:]]*=" { if (!found++) print key " = " value; next }
        { print }
        END { if (!found) print key " = " value }
    ' <<<"$content") || return
    printf '%s\n' "$output" | style::write "$file"
}

style::ini() {
    local file=$1 section=$2 key=$3 value=$4 content='' output
    [[ ! -f "$file" ]] || content=$(fs::read "$file") || return
    output=$(exec::query awk -v section="$section" -v key="$key" -v value="$value" '
        function finish() { if (inside && !written) { print key "=" value; written = 1 } }
        /^\[/ { finish(); inside = $0 == "[" section "]"; if (inside) seen = 1 }
        inside && index($0, key "=") == 1 { if (!written++) print key "=" value; next }
        { print }
        END { finish(); if (!seen) print "\n[" section "]\n" key "=" value }
    ' <<<"$content") || return
    printf '%s\n' "$output" | style::write "$file"
}
