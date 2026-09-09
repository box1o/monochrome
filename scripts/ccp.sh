#!/usr/bin/env bash
set -euo pipefail

source "${MONO_LIB_DIR:-${HOME}/.local/lib/mono}/legacy.sh"
load_config ccp

CONFIG_FILE=''
VERBOSE=false
COPY=false
CCP_OUTPUT=''

usage() { printf 'Usage: %s -f <paths-file> [-v] [-c]\n' "$0"; }

parse_args() {
    while (($# > 0)); do
        case "$1" in
            -f | --file)
                [[ $# -ge 2 ]] || die "$1 requires a value"
                CONFIG_FILE="${2}"
                shift
                ;;
            -v | --verbose) VERBOSE=true ;;
            -c | --copy) COPY=true ;;
            -h | --help) usage; exit 0 ;;
            *) die "unknown option: $1" ;;
        esac
        shift
    done
}

normalize_path() {
    local path="$1"
    path="${path%\"}"
    path="${path#\"}"
    path="${path%\'}"
    path="${path#\'}"
    path="${path/#\~/${HOME}}"
    printf '%s\n' "${path}"
}

append_file() {
    local file="$1"
    local output="$2"
    if [[ ! -f "${file}" ]]; then
        warn "missing: ${file}"
        return 0
    fi
    ${VERBOSE} && log "reading ${file}"
    {
        printf '====\n%s\n====\n' "${file}"
        cat -- "${file}"
        printf '\n\n'
    } >>"${output}"
}

build_output() {
    local output="$1"
    local line file
    while IFS= read -r line || [[ -n "${line}" ]]; do
        [[ -z "${line}" || "${line}" =~ ^[[:space:]]*# ]] && continue
        file="$(normalize_path "${line}")"
        append_file "${file}" "${output}"
    done <"${CONFIG_FILE}"
}

main() {
    parse_args "$@"
    need_file "${CONFIG_FILE}"
    CCP_OUTPUT="$(mktemp)"
    trap 'rm -f "${CCP_OUTPUT}"' EXIT
    build_output "${CCP_OUTPUT}"
    cat -- "${CCP_OUTPUT}"
    if ${COPY}; then
        copy_text <"${CCP_OUTPUT}"
    fi
}

main "$@"
