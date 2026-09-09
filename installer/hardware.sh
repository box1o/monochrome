#!/usr/bin/env bash

hardware::_cpu_vendor() {
    [[ -r /proc/cpuinfo ]] || return 1

    local __key__
    local __value__
    while IFS=: read -r __key__ __value__; do
        __key__=${__key__//[[:space:]]/}
        [[ "${__key__}" == vendor_id ]] || continue
        __value__=${__value__//[[:space:]]/}
        printf '%s\n' "${__value__}"
        return 0
    done </proc/cpuinfo

    return 1
}

hardware::_gpu_vendor_ids_sysfs() {
    local __vendor_file__
    local __vendor__
    local -A __seen__=()

    for __vendor_file__ in /sys/class/drm/card*/device/vendor; do
        [[ -r "${__vendor_file__}" ]] || continue
        IFS= read -r __vendor__ <"${__vendor_file__}" || continue
        __vendor__=${__vendor__,,}
        [[ -v "__seen__[${__vendor__}]" ]] && continue
        __seen__["${__vendor__}"]=true
        printf '%s\n' "${__vendor__}"
    done

    ((${#__seen__[@]} > 0))
}

hardware::_gpu_vendor_ids_lspci() {
    proc::exists lspci || return 1

    local __output__
    __output__=$(proc::capture lspci -nn) || return

    local __line__
    local -A __seen__=()
    while IFS= read -r __line__; do
        [[ "${__line__}" == *VGA* || "${__line__}" == *"3D controller"* || "${__line__}" == *"Display controller"* ]] || continue

        local __vendor__
        case "${__line__,,}" in
            *"[1002:"*) __vendor__=0x1002 ;;
            *"[8086:"*) __vendor__=0x8086 ;;
            *"[10de:"*) __vendor__=0x10de ;;
            *) continue ;;
        esac

        [[ -v "__seen__[${__vendor__}]" ]] && continue
        __seen__["${__vendor__}"]=true
        printf '%s\n' "${__vendor__}"
    done <<<"${__output__}"

    ((${#__seen__[@]} > 0))
}

hardware::_gpu_vendor_ids() {
    local __vendors__
    __vendors__=$(hardware::_gpu_vendor_ids_sysfs) && {
        printf '%s\n' "${__vendors__}"
        return 0
    }

    hardware::_gpu_vendor_ids_lspci
}

hardware::_nvidia_group() {
    if proc::exists pacman; then
        local __installed_packages__
        __installed_packages__=$(proc::capture pacman -Qq) || return
        case $'\n'"${__installed_packages__}"$'\n' in
            *$'\nnvidia-open-dkms\n'*)
                printf 'hardware-nvidia-dkms\n'
                return 0
                ;;
            *$'\nnvidia-open\n'*)
                printf 'hardware-nvidia\n'
                return 0
                ;;
        esac
    fi

    local __kernel__
    __kernel__=$(system::kernel) || return
    case "${__kernel__}" in
        *-arch*) printf 'hardware-nvidia\n' ;;
        *) printf 'hardware-nvidia-dkms\n' ;;
    esac
}

hardware::groups() {
    local __cpu_vendor__=
    __cpu_vendor__=$(hardware::_cpu_vendor) || true
    case "${__cpu_vendor__}" in
        AuthenticAMD) printf 'hardware-amd-cpu\n' ;;
        GenuineIntel) printf 'hardware-intel-cpu\n' ;;
        '') log::warn 'CPU vendor could not be detected; no microcode package was selected' ;;
        *) log::warn "Unsupported CPU vendor: ${__cpu_vendor__}" ;;
    esac

    local __gpu_vendors__=
    __gpu_vendors__=$(hardware::_gpu_vendor_ids) || true
    if [[ -z "${__gpu_vendors__}" ]]; then
        log::warn 'No supported GPU was detected; no GPU-specific packages were selected'
        return 0
    fi

    local __vendor__
    while IFS= read -r __vendor__; do
        case "${__vendor__}" in
            0x1002) printf 'hardware-amd-gpu\n' ;;
            0x8086) printf 'hardware-intel-gpu\n' ;;
            0x10de) hardware::_nvidia_group ;;
            *) log::warn "Unsupported GPU vendor ID: ${__vendor__}" ;;
        esac
    done <<<"${__gpu_vendors__}"
}

hardware::additional_packages() {
    local __groups__=${1:-}
    [[ "${__groups__}" == *hardware-nvidia-dkms* ]] || return 0

    local __kernel__
    __kernel__=$(system::kernel) || return
    case "${__kernel__}" in
        *-lts*) printf 'linux-lts-headers\n' ;;
        *-zen*) printf 'linux-zen-headers\n' ;;
        *-hardened*) printf 'linux-hardened-headers\n' ;;
        *-arch*) printf 'linux-headers\n' ;;
        *) log::warn "Cannot infer the header package for custom kernel ${__kernel__}; install its headers before using NVIDIA DKMS" ;;
    esac
}
