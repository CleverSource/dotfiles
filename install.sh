#!/usr/bin/env bash
sudo -v || { echo "This script requires sudo privileges. Please run as root or with sudo."; exit 1; }

DRY_RUN=false
[[ "${1:-}" == "--dry-run" || "${1:-}" == "-n" ]] && DRY_RUN=true

source "$(dirname "$0")/helpers.sh"

if [[ -n "${SUDO_USER:-}" && "$SUDO_USER" != "root" ]]; then
    USER_HOME="/home/$SUDO_USER"
else
    USER_HOME="$HOME"
fi

log "Running as: $(whoami)"
log "User home: $USER_HOME"

# run_cmd "sudo pacman -Syu --noconfirm"

source modules/system.sh
source modules/aur.sh
source modules/dotfiles.sh
source modules/nvidia.sh
source modules/bash_rc.sh

enable_multilib
install_core_packages
install_aur_packages
setup_dotfiles "$USER_HOME"
setup_nvidia
update_bash_rc "$USER_HOME"
update_keyring "$USER_HOME"
setup_sddm

run_cmd "gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'"
run_cmd "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'"
run_cmd "gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'"
run_cmd "gtk-update-icon-cache /usr/share/icons/Adwaita"
run_cmd "sudo systemctl enable --now bluetooth.service"
run_cmd "xdg-settings set default-web-browser chromium.desktop"
run_cmd "xdg-mime default chromium.desktop x-scheme-handler/http"
run_cmd "xdg-mime default chromium.desktop x-scheme-handler/https"

success "System configured"