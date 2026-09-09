#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

MONO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly MONO_ROOT

# shellcheck disable=SC1091
source "${MONO_ROOT}/lib/shell.sh"

theme::_value() {
    local __key__=${1:-}
    proc::capture awk -v key="${__key__}" '
        $1 == key ":" {
            value = $2
            gsub(/^"|"$/, "", value)
            print value
            found = 1
            exit
        }
        END { if (!found) exit 1 }
    ' "${MONO_ROOT}/themes/mono.yaml"
}

theme::_require_color() {
    local __name__=${1:-}
    local __value__=${2:-}
    if [[ ! "${__value__}" =~ ^#[0-9a-fA-F]{6}$ ]]; then
        log::error "Invalid theme color ${__name__}: ${__value__}"
        return 1
    fi
}

theme::build() {
    local __background__ __surface__ __surface_bright__ __foreground__ __muted__
    local __accent__ __red__ __green__ __yellow__ __blue__ __magenta__ __cyan__
    local __white__ __black__

    __background__=$(theme::_value background)
    __surface__=$(theme::_value surface)
    __surface_bright__=$(theme::_value surface_bright)
    __foreground__=$(theme::_value foreground)
    __muted__=$(theme::_value muted)
    __accent__=$(theme::_value accent)
    __red__=$(theme::_value red)
    __green__=$(theme::_value green)
    __yellow__=$(theme::_value yellow)
    __blue__=$(theme::_value blue)
    __magenta__=$(theme::_value magenta)
    __cyan__=$(theme::_value cyan)
    __white__=$(theme::_value white)
    __black__=$(theme::_value black)

    local __name__
    for __name__ in background surface surface_bright foreground muted accent red green yellow blue magenta cyan white black; do
        local __value_reference__="__${__name__}__"
        local -n _value_="${__value_reference__}"
        theme::_require_color "${__name__}" "${_value_}" || return
    done

    local __kitty__
    __kitty__="# Generated from themes/mono.yaml. Do not edit directly.
foreground ${__foreground__}
background ${__background__}
selection_foreground ${__background__}
selection_background ${__foreground__}
cursor ${__accent__}
cursor_text_color ${__background__}
url_color ${__blue__}
active_border_color ${__accent__}
inactive_border_color ${__surface_bright__}
bell_border_color ${__yellow__}
active_tab_foreground ${__foreground__}
active_tab_background ${__surface_bright__}
inactive_tab_foreground ${__muted__}
inactive_tab_background ${__background__}
tab_bar_background ${__background__}
color0 ${__black__}
color1 ${__red__}
color2 ${__green__}
color3 ${__yellow__}
color4 ${__blue__}
color5 ${__magenta__}
color6 ${__cyan__}
color7 ${__white__}
color8 ${__muted__}
color9 ${__red__}
color10 ${__green__}
color11 ${__yellow__}
color12 ${__blue__}
color13 ${__magenta__}
color14 ${__cyan__}
color15 ${__foreground__}
"

    local __lua__
    __lua__="-- Generated from themes/mono.yaml. Do not edit directly.
return {
    background = \"${__background__}\",
    surface = \"${__surface__}\",
    surface_bright = \"${__surface_bright__}\",
    foreground = \"${__foreground__}\",
    muted = \"${__muted__}\",
    accent = \"${__accent__}\",
    red = \"${__red__}\",
    green = \"${__green__}\",
    yellow = \"${__yellow__}\",
    blue = \"${__blue__}\",
    magenta = \"${__magenta__}\",
    cyan = \"${__cyan__}\",
    white = \"${__white__}\",
    black = \"${__black__}\",
}
"

    fs::write "${MONO_ROOT}/configs/kitty/theme.conf" "${__kitty__}" || return
    fs::write "${MONO_ROOT}/configs/nvim/lua/mono/palette.lua" "${__lua__}" || return
    log::info 'Generated Kitty and Neovim theme adapters from themes/mono.yaml'
}

theme::build "$@"
