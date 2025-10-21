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

enable_multilib() {
    log "Enabling multilib repository"

    local pacman_conf="/etc/pacman.conf"

    if grep -Eq '^\[multilib\]' "$pacman_conf"; then
        warn "Multilib repository already enabled, skipping."
        return
    fi

    if $DRY_RUN; then
        echo "[dry-run] Enable multilib in $pacman_conf"
    else
        if grep -Eq '^#\[multilib\]' "$pacman_conf"; then
            sudo sed -i '/^#\[multilib\]/,/^#Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' "$pacman_conf"
        else
            echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a "$pacman_conf" >/dev/null
        fi

        run_cmd "sudo pacman -Syy"
        success "Multilib repository enabled."
    fi
}

update_keyring() {
    local user_home="$1"
    local keyring_dir="$user_home/.local/share/keyrings"
    local keyring_file="$keyring_dir/Default_keyring.keyring"
    local default_file="$keyring_dir/default"

    log "Ensuring default keyring configuration exists"

    if [[ -f "$keyring_file" && -f "$default_file" ]]; then
        warn "Keyring files already exist, skipping creation."
        return
    fi

    run_cmd "mkdir -p \"$keyring_dir\""

    if $DRY_RUN; then
        echo "[dry-run] Create keyring at $keyring_file"
        echo "[dry-run] Create default file at $default_file"
        return
    fi

    cat <<EOF | tee "$keyring_file" >/dev/null
[keyring]
display-name=Default keyring
ctime=$(date +%s)
mtime=0
lock-on-idle=false
lock-after=false
EOF

    echo "Default_keyring" | tee "$default_file" >/dev/null

    run_cmd "chmod 700 \"$keyring_dir\""
    run_cmd "chmod 600 \"$keyring_file\""
    run_cmd "chmod 644 \"$default_file\""

    success "Default keyring initialized at $keyring_dir"
}


setup_sddm() {
    log "Configuring SDDM autologin"

    local conf_dir="/etc/sddm.conf.d"
    local conf_file="$conf_dir/autologin.conf"
    local theme_dir="/usr/share/sddm/themes/clever"
    local custom_theme_source="$PWD/sddm-theme"

    if ! sudo mkdir -p "$conf_dir"; then
        error "Failed to create $conf_dir"
        return 1
    fi

    if [[ -f "$conf_file" ]]; then
        warn "SDDM autologin.conf already exists, skipping creation."
    else
        sudo tee "$conf_file" >/dev/null <<EOF
[General]
InputMethod=qtvirtualkeyboard
GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/clever/components/,QT_IM_MODULE=qtvirtualkeyboard

[Theme]
Current=clever
EOF
        success "Created SDDM autologin.conf for user $USER"
    fi

    if [[ ! $DRY_RUN ]]; then
        if sudo cp -r "$custom_theme_source" "$theme_dir"; then
            sudo cp "$(pwd)/wallpaper.jpg" "$theme_dir/background.jpg"
            sudo cp "$(pwd)/faces/ryan.face.icon" "/usr/share/sddm/faces/ryan.face.icon"
            success "Copied custom SDDM theme to $theme_dir"
        else
            error "Failed to copy theme to $theme_dir"
        fi
    else
        warn "[dry-run] SDDM theme directory $theme_dir copied."
    fi

    if ! sudo systemctl enable sddm.service; then
        error "Failed to enable SDDM service."
        return 1
    fi

    success "SDDM service enabled successfully."
}