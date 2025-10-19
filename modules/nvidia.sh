#!/usr/bin/env bash
setup_nvidia() {
    log "Checking for NVIDIA GPU..."
    if ! lspci | grep -iq 'nvidia'; then
        warn "No NVIDIA GPU detected. Skipping NVIDIA setup."
        return
    fi

    if [[ -f /etc/modprobe.d/nvidia.conf ]]; then
        warn "NVIDIA setup already exists. Skipping."
        return
    fi

    local driver_package kernel_headers
    if lspci | grep -Eiq "RTX [2-9][0-9]|GTX 16"; then
        driver_package="nvidia-open-dkms"
    else
        driver_package="nvidia-dkms"
    fi

    if pacman -Q linux-zen &>/dev/null; then
        kernel_headers="linux-zen-headers"
    elif pacman -Q linux-lts &>/dev/null; then
        kernel_headers="linux-lts-headers"
    elif pacman -Q linux-hardened &>/dev/null; then
        kernel_headers="linux-hardened-headers"
    else
        kernel_headers="linux-headers"
    fi

    local pkgs=(
        "$kernel_headers"
        "$driver_package"
        "nvidia-utils"
        "lib32-nvidia-utils"
        "egl-wayland"
        "libva-nvidia-driver"
        "qt5-wayland"
        "qt6-wayland"
    )
    run_cmd "sudo pacman -S --needed --noconfirm ${pkgs[*]}"

    run_cmd "echo 'options nvidia_drm modeset=1' | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null"

    local conf="/etc/mkinitcpio.conf"
    run_cmd "sudo cp $conf ${conf}.backup"
    run_cmd "sudo sed -i -E 's/(MODULES=\\()/\\1nvidia nvidia_modeset nvidia_uvm nvidia_drm /' $conf"
    run_cmd "sudo mkinitcpio -P"

    local hypr_conf="$HOME/.config/hypr/hyprland.conf"
    if [[ -f "$hypr_conf" ]] && ! file_contains "$hypr_conf" "NVD_BACKEND"; then
        cat <<'EOF' | tee -a "$hypr_conf" >/dev/null

# NVIDIA environment variables
env = NVD_BACKEND,direct
env = LIBVA_DRIVER_NAME,nvidia
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
EOF
        success "NVIDIA variables added to hyprland.conf"
    fi
}
