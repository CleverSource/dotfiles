#!/usr/bin/env bash
update_bash_rc() {
    local user_home="$1"
    local bash_rc="$user_home/.bash_rc"

    log "Updating bash rc at $bash_rc"

    local autostart_block="# Added by installer
if command -v fzf &> /dev/null; then
  if [[ -f /usr/share/fzf/completion.bash ]]; then
    source /usr/share/fzf/completion.bash
  fi
  if [[ -f /usr/share/fzf/key-bindings.bash ]]; then
    source /usr/share/fzf/key-bindings.bash
  fi
fi"

    # Ensure the file exists
    run_cmd "touch \"$bash_rc\""

    # Skip if already present
    if file_contains "$bash_rc" "# Added by installer"; then
        warn "Autocomplete block already exists in bash rc, skipping."
        return
    fi

    if $DRY_RUN; then
        echo "[dry-run] Append autocomplete block to $bash_rc"
    else
        echo -e "\n$autostart_block" >> "$bash_rc"
        success "Added autocomplete block to bash rc."
    fi
}