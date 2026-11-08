# Shared Bash/Zsh settings; the Bash runtime is invoked through profile::run.
# shellcheck shell=bash
if [[ -z ${MONO_LIB_DIR:-} ]]; then
    if [[ -r "$MONO_SHELL_HOME/../../lib/profile.sh" ]]; then
        MONO_LIB_DIR="$MONO_SHELL_HOME/../../lib"
    else
        MONO_LIB_DIR="$HOME/.local/lib/mono"
    fi
fi
MONO_LIB_DIR=$(cd -- "$MONO_LIB_DIR" && pwd -P) || return
export MONO_LIB_DIR

# shellcheck source=../../lib/profile.sh
source "$MONO_LIB_DIR/profile.sh" || return

export SCRIPT_DIR="$HOME/.local/bin"
export EDITOR=nvim
export VISUAL=nvim

profile::path_prepend "$SCRIPT_DIR"
profile::path_prepend "$HOME/go/bin"
profile::path_prepend "$HOME/.opencode/bin"

# aliases
alias ls='profile::run ls --color=auto'
alias grep='profile::run grep --color=auto'
alias l='ls -a'
alias vim='nvim'
alias x='nvim'
alias c='clear'
alias r='profile::run rm -rf'
alias m='profile::run mkdir'
alias t='profile::run touch'
alias i='profile::run sudo pacman -Syu'
alias f='profile::run fzf'
alias dps="profile::run docker ps --format '{{.Names}} {{.Image}} {{.Status}}'"
alias mp='profile::run mpremote connect /dev/ttyACM0'
alias rdp='rdp.sh'
alias scaffold='scaffold.sh'
alias d-init='d-init.sh'
alias ai='ai.sh'
alias ccp='ccp.sh'
alias cc='cd ~/Code/cc && profile::run tmux new -A -s cc'

if [[ -z ${STARSHIP_CONFIG:-} && -r "${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml" ]]; then
    export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml"
fi

# fzf
export FZF_DEFAULT_OPTS="
--layout=reverse
--border=rounded
--padding=1
--margin=1
--info=inline
--prompt='> '
--pointer='>'
--marker='*'
--cycle
"
if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/mono/applications/fzf/mono.conf" ]]; then
    export FZF_DEFAULT_OPTS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/mono/applications/fzf/mono.conf"
fi
if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/bat/themes/Mono.tmTheme" ]]; then
    export BAT_THEME=Mono
fi

# nvm
export NVM_DIR="$HOME/.nvm"

profile::source_optional "$NVM_DIR/nvm.sh"

if [[ -n "${BASH_VERSION:-}" && -s "$NVM_DIR/bash_completion" ]]; then
    source "$NVM_DIR/bash_completion"
fi

# bun
export BUN_INSTALL="$HOME/.bun"

profile::path_prepend "$BUN_INSTALL/bin"

if [[ -n "${ZSH_VERSION:-}" && -s "$BUN_INSTALL/_bun" ]]; then
    source "$BUN_INSTALL/_bun"
fi

# java
export JAVA_HOME=${JAVA_HOME:-/usr/lib/jvm/java-17-openjdk}

profile::path_prepend "$JAVA_HOME/bin"

# android
export ANDROID_HOME=${ANDROID_HOME:-$HOME/Android/Sdk}
export ANDROID_SDK_ROOT="$ANDROID_HOME"

profile::path_prepend "$ANDROID_HOME/cmdline-tools/latest/bin"
profile::path_prepend "$ANDROID_HOME/emulator"
profile::path_prepend "$ANDROID_HOME/platform-tools"
profile::path_prepend "$ANDROID_HOME/build-tools/35.0.0"

# emscripten
export EMSDK_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/emsdk"

if [[ -s "$EMSDK_ROOT/emsdk_env.sh" ]]; then
    EMSDK_QUIET=1 source "$EMSDK_ROOT/emsdk_env.sh" >/dev/null 2>&1
fi

export PATH

# d — GBashLib-compatible ./d.bl.sh runner
if [[ -x "$SCRIPT_DIR/d" ]]; then
    if [[ -n "${ZSH_VERSION:-}" ]]; then
        eval "$(profile::query "$SCRIPT_DIR/d" _print_zsh_setup 2>/dev/null)" 2>/dev/null || true
        zstyle ':completion:*:*:d:*' file-patterns ''
        zstyle ':completion:*:*:d:*' menu select=2
    else
        eval "$(profile::query "$SCRIPT_DIR/d" _print_autocomplete 2>/dev/null)" 2>/dev/null || true
        # Restore normal Tab (undo old broken mono d bind -x that ran "\t" as a command)
        bind -r '\C-i' 2>/dev/null || true
        bind '"\C-i": complete' 2>/dev/null || bind '"\C-i": "\C-i"' 2>/dev/null || true
    fi
fi

# codex
[[ -f "$HOME/.config/codex-azure-openai.env" ]] && source "$HOME/.config/codex-azure-openai.env"

export AZURE_RESOURCE_NAME="teckstaters"

[[ -n "${OPENAI_API_KEY:-}" ]] && export AZURE_OPENAI_API_KEY="$OPENAI_API_KEY"

# python
export PYTHONPATH="$HOME/work/Core"

# Machine-local settings and secrets belong here and are never tracked by Mono.
[[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/mono/local.sh" ]] &&
    source "${XDG_CONFIG_HOME:-$HOME/.config}/mono/local.sh"

ap() {
    export PYTHONPATH="$HOME/work/Core"

    source "$HOME/work/Core/.venv/bin/activate"
}

# bp
bp() {
    local -a exclude_dirs
    exclude_dirs=(".git" "docs" "node_modules" "vendor" "dist" "build")

    local copy_clipboard=true

    while [[ "${1:-}" != "" ]]; do
        case "$1" in
            -n | --no-copy)
                copy_clipboard=false

                shift
                ;;
            *)
                exclude_dirs=("$@")
                break
                ;;
        esac
    done

    local -a exclude_args=()
    local d

    for d in "${exclude_dirs[@]}"; do
        exclude_args+=(-not -path "*/$d/*")
    done

    local result
    result="$(profile::run find "$PWD" -type f "${exclude_args[@]}" -exec printf '"%s"\n' '{}' \;)"

    echo "$result"

    if [[ "$copy_clipboard" == true ]] && profile::exists wl-copy; then
        printf '%s\n' "$result" | profile::run wl-copy
        profile::log info 'Copied project paths to clipboard'
    fi
}

# tmux
ta() {
    profile::exists tmux || return 0
    profile::exists fzf || {
        profile::log error 'tmux: fzf not found'
        return 1
    }

    [[ -t 0 && -t 1 ]] || {
        profile::log error 'tmux: not a terminal'
        return 1
    }

    local sessions
    sessions="$(profile::run tmux list-sessions -F '#{session_name} :: #{session_windows} :: #{?session_attached,yes,no}' 2>/dev/null || true)"

    if [[ -z "$sessions" ]]; then
        local name

        if [[ -n "${ZSH_VERSION:-}" ]]; then
            read -r "name?No tmux sessions. Create one [main]: "
        else
            read -r -p "No tmux sessions. Create one [main]: " name
        fi

        profile::run tmux new-session -A -s "${name:-main}"
        return 0
    fi

    local picked
    picked="$(
        printf '%s\n' "$sessions" | profile::run fzf \
            --height=55% \
            --layout=reverse \
            --border=rounded \
            --padding=1 \
            --margin=1 \
            --info=inline \
            --cycle \
            --prompt='tmux> ' \
            --delimiter=' :: ' \
            --with-nth=1,2,3 \
            --header='Enter: attach/switch | Tab: select | /: search | Esc: cancel' \
            --preview='tmux list-windows -t {1} -F "#{window_index}: #{window_name} (#{window_panes})" 2>/dev/null | sed -n "1,140p"' \
            --preview-window='down:60%:wrap' \
            --no-separator
    )" || return 0

    [[ -z "$picked" ]] && return 0

    local name="${picked%% :: *}"

    [[ -z "$name" ]] && return 0

    if [[ -n "${TMUX:-}" ]]; then
        profile::run tmux switch-client -t "$name"
    else
        profile::run tmux new-session -A -s "$name"
    fi
}

tk() {
    profile::run tmux list-sessions -F '#{session_name}' |
        profile::run fzf --multi --prompt='kill> ' |
        profile::run xargs -r -I {} tmux kill-session -t {}
}

# mgw
ssd() {
    cd "$HOME/work/mgw/ugw/repo" || return
    profile::run bash --rcfile "${XDG_CONFIG_HOME:-$HOME/.config}/mono/shell/mgw.bashrc"
}
