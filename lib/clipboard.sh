#!/usr/bin/env bash

clipboard::copy() {
    local command
    command=$(proc::first_available wl-copy xclip) || return

    case "$command" in
        wl-copy) exec::run --quiet -- wl-copy ;;
        xclip) exec::run --quiet -- xclip -selection clipboard ;;
    esac
}
