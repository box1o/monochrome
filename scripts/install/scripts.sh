#!/usr/bin/env bash

scripts::deploy() {
    local dry_run=${1:-false}

    validate::boolean dry-run "$dry_run" || return
    fs::require_dir scripts "${MONO_ROOT}/scripts" || return
    fs::require_dir runtime "${MONO_ROOT}/lib" || return

    local target_user home source name
    target_user=$(deploy::target_user) || return
    home=$(user::home "$target_user") || return

    deploy::replace "$target_user" "$dry_run" "${MONO_ROOT}/lib" "$home/.local/lib/mono" || return

    deploy::replace "$target_user" "$dry_run" "${MONO_ROOT}/scripts/.init.sh" "$home/.local/bin/.init.sh" || return
    deploy::replace "$target_user" "$dry_run" "${MONO_ROOT}/scripts/.init.sh" "$home/.local/libexec/mono/.init.sh" || return

    local count=0

    for source in "${MONO_ROOT}/scripts"/*; do
        fs::is_file "$source" || continue

        name=${source##*/}

        deploy::replace "$target_user" "$dry_run" "$source" "$home/.local/bin/$name" u+x || return

        ((count += 1))
    done

    # Helpers keep their relative paths and stay separate from public commands.
    for name in audio bluetooth capture desktop network vpn tools freecad d-support; do
        source="${MONO_ROOT}/scripts/$name"

        fs::is_dir "$source" || continue
        deploy::replace "$target_user" "$dry_run" "$source" "$home/.local/libexec/mono/$name" || return
    done

    # Remove only the obsolete project-owned Python runtime after migration.
    deploy::run "$target_user" "$dry_run" fs::remove_tree "$home/.local/libexec/mono/python" || return

    log::info "Processed $count public commands and their helper folders for $target_user"
}
