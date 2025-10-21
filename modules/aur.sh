#!/usr/bin/env bash
install_yay() {
    log "Installing yay if needed"

    if ! command -v yay &>/dev/null; then
        run_cmd "git clone https://aur.archlinux.org/yay.git /tmp/yay"
        pushd /tmp/yay >/dev/null
        run_cmd "makepkg -si --noconfirm"
        popd >/dev/null
    fi
}
