#!/usr/bin/env bash
update_bash_rc() {
    local user_home="$1"
    local bashrc="$user_home/.bashrc"

    log "Updating bash rc at $bashrc"

    local autostart_block="# Added by installer
if command -v fzf &> /dev/null; then
  if [[ -f /usr/share/fzf/completion.bash ]]; then
    source /usr/share/fzf/completion.bash
  fi
  if [[ -f /usr/share/fzf/key-bindings.bash ]]; then
    source /usr/share/fzf/key-bindings.bash
  fi
fi

alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
"

    # Ensure the file exists
    run_cmd "touch \"$bashrc\""

    # Skip if already present
    if file_contains "$bashrc" "# Added by installer"; then
        warn "Autocomplete block already exists in bash rc, skipping."
        return
    fi

    if $DRY_RUN; then
        echo "[dry-run] Append autocomplete block to $bashrc"
    else
        echo -e "\n$autostart_block" >> "$bashrc"
        success "Added autocomplete block to bash rc."
    fi
}