#!/usr/bin/env bash
install_aur_packages() {
    log "Installing AUR helper (yay) if needed"

    if ! command -v yay &>/dev/null; then
        run_cmd "git clone https://aur.archlinux.org/yay.git /tmp/yay"
        pushd /tmp/yay >/dev/null
        run_cmd "makepkg -si --noconfirm"
        popd >/dev/null
    fi

    log "Installing AUR packages"
    local pkgs=()
    while read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        pkgs+=("$line")
    done < packages-yay

    if ((${#pkgs[@]})); then
        run_cmd "yay -S --needed --noconfirm ${pkgs[*]}"
    else
        warn "No AUR packages found in packages-yay file."
    fi
}
