#!/usr/bin/env bash
setup_dotfiles() {
    local user_home="$1"
    local config_dir="$user_home/.config"

    log "Setting up dotfiles"
    run_cmd "mkdir -p '$config_dir'"
    run_cmd "cp -r dotfiles/* '$config_dir/'"

    if [[ -d "dotfiles-once" ]]; then
        log "Copying dotfiles-once (skip existing)"
        find dotfiles-once -type f | while read -r file; do
            rel="${file#dotfiles-once/}"
            dest="$config_dir/$rel"
            if [[ ! -f "$dest" ]]; then
                run_cmd "mkdir -p \"$(dirname "$dest")\""
                safe_copy "$file" "$dest"
                echo "→ Copied $rel"
            else
                echo "⚙️  Skipped existing $rel"
            fi
        done
    fi

    if [[ -n "${SUDO_USER:-}" && "$SUDO_USER" != "root" ]]; then
        log "Fixing ownership for $SUDO_USER"
        run_cmd "sudo chown -R $SUDO_USER:$SUDO_USER '$user_home'"
    fi
}
