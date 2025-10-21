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

enable_multilib
install_yay
install_core_packages
setup_dotfiles "$USER_HOME"
setup_nvidia
update_keyring "$USER_HOME"
setup_sddm

log "Setting default applications and themes"

run_cmd "gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'"
run_cmd "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'"
run_cmd "gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'"
run_cmd "gtk-update-icon-cache /usr/share/icons/Adwaita"
run_cmd "xdg-settings set default-web-browser chromium.desktop"
run_cmd "xdg-mime default chromium.desktop x-scheme-handler/http"
run_cmd "xdg-mime default chromium.desktop x-scheme-handler/https"

run_cmd "sudo systemctl enable --now bluetooth.service"
run_cmd "sudo systemctl enable --now iwd.service"
run_cmd "sudo systemctl disable systemd-networkd-wait-online.service"
run_cmd "sudo systemctl mask systemd-networkd-wait-online.service"

WALLPAPER_SRC="$(pwd)/wallpaper.jpg"
WALLPAPER_DEST="$USER_HOME/.config/wallpaper.jpg"
log "Installing wallpaper..."

if [[ -f "$WALLPAPER_SRC" ]]; then
    safe_copy "$WALLPAPER_SRC" "$WALLPAPER_DEST"
    log "Wallpaper installed at $WALLPAPER_DEST"
else
    warn "No wallpaper.jpg found in $(pwd) — skipping wallpaper setup."
fi

log "Setting up Nautilus extensions..."
run_cmd "gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal alacritty"
run_cmd "gsettings set com.github.stunkymonkey.nautilus-open-any-terminal new-tab false"

log "Setting up Fish shell as default..."
run_cmd "sudo fish setup.fish"

log "Setting bash rc"
safe_copy "$(pwd)/dotfiles/.bashrc" "$USER_HOME/.bashrc"

success "System configured"