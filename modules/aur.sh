#!/usr/bin/env bash
install_aur_packages() {
    log "Installing AUR helper (yay) if needed"

    if ! command -v yay &>/dev/null; then
        run_cmd "git clone https://aur.archlinux.org/yay.git /tmp/yay"
        pushd /tmp/yay >/dev/null
        run_cmd "makepkg -si --noconfirm"
        popd >/dev/null
    fi

    log "Installing AUR packages individually"

    while read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        local pkg="$line"
        log "Installing AUR package: $pkg"
        run_cmd "yay -S --needed --noconfirm $pkg"
    done < packages-yay
}
