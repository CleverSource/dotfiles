#!/usr/bin/env bash
update_bash_profile() {
    local user_home="$1"
    local bash_profile="$user_home/.bash_profile"

    log "Updating bash profile at $bash_profile"

    local autostart_block="# Added by installer
if uwsm check may-start; then
    exec uwsm start hyprland.desktop
fi"

    # Ensure the file exists
    run_cmd "touch \"$bash_profile\""

    # Skip if already present
    if file_contains "$bash_profile" "uwsm start hyprland.desktop"; then
        warn "Hyprland autostart already exists in bash profile, skipping."
        return
    fi

    if $DRY_RUN; then
        echo "[dry-run] Append Hyprland autostart block to $bash_profile"
    else
        echo -e "\n$autostart_block" >> "$bash_profile"
        success "Added Hyprland autostart block to bash profile."
    fi
}