#!/usr/bin/env bash
install_core_packages() {
    log "Installing system packages"

    local pkgs=()
    while read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        pkgs+=("$line")
    done < packages

    if ((${#pkgs[@]})); then
        run_cmd "sudo pacman -S --needed --noconfirm ${pkgs[*]}"
    else
        warn "No system packages found in packages file."
    fi
}
