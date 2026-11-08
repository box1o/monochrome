#!/usr/bin/env bash
# Context is supplied by ../style.sh.
# shellcheck disable=SC2154

style::browser() {
    exec::run bash "$MONO_HELPER_DIR/desktop/browser.sh" firefox
    if proc::exists chromium; then
        local file="$config/chromium-flags.conf" content='' output
        [[ ! -f "$file" ]] || content=$(fs::read "$file") || return
        output=$(exec::query awk -v theme="$themes/chromium" '
            /^--load-extension=/ {
                sub(/^--load-extension=/, "")
                count = split($0, paths, ",")
                for (i = 1; i <= count; i++) {
                    if (paths[i] != "" && paths[i] != theme && !seen[paths[i]]++) {
                        extensions = extensions paths[i] ","
                    }
                }
                next
            }
            { print }
            END { print "--load-extension=" extensions theme }
        ' <<<"$content") || return
        printf '%s\n' "$output" | style::write "$file"
        log::info 'Chromium theme enabled for the next browser launch'
    fi
    log::info "Chrome theme ready to load unpacked: $themes/chromium"
}
