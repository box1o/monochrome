#!/usr/bin/env bash
set -u
root="$HOME/.config"; dir="$HOME/Backups/mono"; mkdir -p "$dir"
case "${1:-backup}" in
  backup)
    out="$dir/mono-$(date +%Y-%m-%d_%H-%M-%S).tar.gz"
    tar -czf "$out" -C "$root" quickshell hypr kitty nvim 2>/dev/null || true
    notify-send -a Mono "Configuration backup" "$out"
    ;;
  restore)
    archive="$(ls -1t "$dir"/*.tar.gz 2>/dev/null | head -1)"
    [[ -n "$archive" ]] || { notify-send -a Mono "Configuration restore" "No backup found"; exit 1; }
    tar -xzf "$archive" -C "$root"; notify-send -a Mono "Configuration restore" "Restored $(basename "$archive")"
    ;;
  *) printf 'usage: %s backup|restore\n' "${0##*/}" >&2; exit 2 ;;
esac
