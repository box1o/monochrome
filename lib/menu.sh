#!/usr/bin/env bash

MENU_ACCENT=${MENU_ACCENT:-6}
MENU_MUTED=${MENU_MUTED:-8}
MENU_HEIGHT=${MENU_HEIGHT:-10}

menu::_require_gum() {
    proc::require gum
}

menu::_require_option_value() {
    local __caller__=${1:-function}
    local __option__=${2:-}
    local __argument_count__=${3:-0}

    if ((__argument_count__ < 2)); then
        log::error "${__caller__}: ${__option__} requires a value"
        return 2
    fi
}

# Select one value from an interactive list and print it to stdout.
#
# Usage:
#   menu::select [--prompt <text>] [--selected <index>] [--height <lines>] -- <choice>...
menu::select() {
    local __prompt__="Select an option:"
    local __selected__=0
    local __height__=${MENU_HEIGHT}

    while (($# > 0)); do
        case "$1" in
            --prompt | --selected | --height)
                menu::_require_option_value menu::select "$1" "$#" || return

                case "$1" in
                    --prompt) __prompt__=$2 ;;
                    --selected) __selected__=$2 ;;
                    --height) __height__=$2 ;;
                esac

                shift 2
                ;;
            --)
                shift
                break
                ;;
            -*)
                log::error "menu::select: unknown option: $1"
                return 2
                ;;
            *) break ;;
        esac
    done

    (($# > 0)) || {
        log::error "menu::select requires at least one choice"
        return 2
    }

    validate::non_negative_integer selected-index "${__selected__}" || return
    validate::positive_integer height "${__height__}" || return

    local -a __choices__=("$@")
    if ((__selected__ >= ${#__choices__[@]})); then
        log::error "Selected index is outside the choice list: ${__selected__}"
        return 2
    fi

    menu::_require_gum || return

    gum choose \
        --header "◇  ${__prompt__}" \
        --height "${__height__}" \
        --cursor "● " \
        --selected "${__choices__[${__selected__}]}" \
        --header.foreground "${MENU_MUTED}" \
        --cursor.foreground "${MENU_ACCENT}" \
        --selected.foreground "${MENU_ACCENT}" \
        "${__choices__[@]}"
}

# Filter a list interactively and print the selected value to stdout.
#
# Usage:
#   menu::filter [--prompt <text>] [--height <lines>] -- <choice>...
menu::filter() {
    local __prompt__="Filter options..."
    local __height__=${MENU_HEIGHT}

    while (($# > 0)); do
        case "$1" in
            --prompt | --height)
                menu::_require_option_value menu::filter "$1" "$#" || return

                case "$1" in
                    --prompt) __prompt__=$2 ;;
                    --height) __height__=$2 ;;
                esac

                shift 2
                ;;
            --)
                shift
                break
                ;;
            -*)
                log::error "menu::filter: unknown option: $1"
                return 2
                ;;
            *) break ;;
        esac
    done

    (($# > 0)) || {
        log::error "menu::filter requires at least one choice"
        return 2
    }

    validate::positive_integer height "${__height__}" || return
    menu::_require_gum || return

    printf '%s\n' "$@" | gum filter \
        --placeholder "${__prompt__}" \
        --height "${__height__}" \
        --prompt "● " \
        --prompt.foreground "${MENU_ACCENT}" \
        --indicator.foreground "${MENU_ACCENT}" \
        --match.foreground "${MENU_ACCENT}" \
        --cursor-text.foreground "${MENU_ACCENT}"
}

# Read one line interactively and print it to stdout.
#
# Usage:
#   menu::input [--prompt <text>] [--default <value>] [--required] [--password]
menu::input() {
    local __prompt__="Enter a value:"
    local __default__=
    local __required__=false
    local __password__=false

    while (($# > 0)); do
        case "$1" in
            --prompt | --default)
                menu::_require_option_value menu::input "$1" "$#" || return

                case "$1" in
                    --prompt) __prompt__=$2 ;;
                    --default) __default__=$2 ;;
                esac

                shift 2
                ;;
            --required)
                __required__=true
                shift
                ;;
            --password)
                __password__=true
                shift
                ;;
            --)
                shift
                break
                ;;
            -*)
                log::error "menu::input: unknown option: $1"
                return 2
                ;;
            *) break ;;
        esac
    done

    if (($# != 0)); then
        log::error "Usage: menu::input [--prompt <text>] [--default <value>] [--required] [--password]"
        return 2
    fi

    menu::_require_gum || return

    local -a __arguments__=(
        --header "◇  ${__prompt__}"
        --prompt "   "
        --value "${__default__}"
        --header.foreground "${MENU_MUTED}"
        --cursor.foreground "${MENU_ACCENT}"
    )

    [[ "${__password__}" == true ]] && __arguments__+=(--password)

    local __value__
    while true; do
        __value__=$(gum input "${__arguments__[@]}") || return $?

        if [[ "${__required__}" != true || -n "${__value__}" ]]; then
            printf '%s\n' "${__value__}"
            return 0
        fi

        gum style --foreground 1 "   value is required" >&2
    done
}

# Ask a yes/no question. Success means yes; status 1 means no.
#
# Usage:
#   menu::confirm [--default-no] <prompt>
menu::confirm() {
    local __default__=true

    if [[ ${1:-} == --default-no ]]; then
        __default__=false
        shift
    fi

    if (($# != 1)); then
        log::error "Usage: menu::confirm [--default-no] <prompt>"
        return 2
    fi

    menu::_require_gum || return

    gum confirm \
        --default="${__default__}" \
        --prompt.foreground "${MENU_ACCENT}" \
        "$1"
}

# Display a spinner while a command runs and return its exit status.
#
# Usage:
#   menu::spin [--title <text>] [--spinner <name>] [--show-output] -- <command>...
menu::spin() {
    local __title__="Working..."
    local __spinner__=dot
    local __show_output__=false

    while (($# > 0)); do
        case "$1" in
            --title | --spinner)
                menu::_require_option_value menu::spin "$1" "$#" || return

                case "$1" in
                    --title) __title__=$2 ;;
                    --spinner) __spinner__=$2 ;;
                esac

                shift 2
                ;;
            --show-output)
                __show_output__=true
                shift
                ;;
            --)
                shift
                break
                ;;
            -*)
                log::error "menu::spin: unknown option: $1"
                return 2
                ;;
            *) break ;;
        esac
    done

    proc::_require_command menu::spin "$#" || return
    menu::_require_gum || return

    if [[ ${SHELL_LIB_DRY_RUN:-false} == true ]]; then
        log::info "DRY-RUN ${__title__}: $(proc::format_command "$@")"
        return 0
    fi

    local -a __arguments__=(
        --title "${__title__}"
        --spinner "${__spinner__}"
        --spinner.foreground "${MENU_ACCENT}"
    )

    [[ "${__show_output__}" == true ]] && __arguments__+=(--show-output)

    gum spin "${__arguments__[@]}" -- "$@"
}
