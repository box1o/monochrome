#!/usr/bin/env bash

mps::install() {
    local dry_run=${1:-false} target_user home

    validate::boolean dry-run "$dry_run" || return
    target_user=$(deploy::target_user) || return
    home=$(user::home "$target_user") || return

    mps::deploy "$target_user" "$dry_run" "$home"
}

mps::deploy() {
    local target_user=$1 dry_run=$2 home=$3
    local build="$home/.cache/mono/mps"

    validate::boolean dry-run "$dry_run" || return
    fs::require_dir mps "$MONO_ROOT/ps" || return
    proc::require cmake c++ || return

    deploy::run "$target_user" "$dry_run" cmake -S "$MONO_ROOT/ps" -B "$build" \
        -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$home/.local" || return
    deploy::run "$target_user" "$dry_run" cmake --build "$build" --parallel 2 || return
    deploy::run "$target_user" "$dry_run" cmake --install "$build" --prefix "$build/stage" || return
    if [[ $dry_run == true ]]; then
        log::info "DRY-RUN deploy MPS binary and user service to $home/.local"
    else
        deploy::replace "$target_user" false "$build/stage/bin/mps" "$home/.local/bin/mps" u+x || return
        deploy::replace "$target_user" false "$build/stage/share/systemd/user/mps.service" \
            "$home/.local/share/systemd/user/mps.service" || return
    fi

    local uid runtime
    uid=$(user::uid "$target_user") || return
    runtime="/run/user/$uid"
    if [[ $dry_run == true || -S $runtime/bus ]]; then
        deploy::run "$target_user" "$dry_run" env "XDG_RUNTIME_DIR=$runtime" \
            "DBUS_SESSION_BUS_ADDRESS=unix:path=$runtime/bus" systemctl --user daemon-reload || return
        deploy::run "$target_user" "$dry_run" env "XDG_RUNTIME_DIR=$runtime" \
            "DBUS_SESSION_BUS_ADDRESS=unix:path=$runtime/bus" systemctl --user enable mps.service || return
        deploy::run "$target_user" "$dry_run" env "XDG_RUNTIME_DIR=$runtime" \
            "DBUS_SESSION_BUS_ADDRESS=unix:path=$runtime/bus" systemctl --user restart mps.service || return
    else
        log::info 'MPS installed; enable mps.service from the desktop session'
    fi

    log::info "Processed MPS binary and user service for $target_user"
}
