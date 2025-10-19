#!/usr/bin/env bash
DRY_RUN=${DRY_RUN:-false}

log()    { echo -e "\033[1;34m==>\033[0m $*"; }
warn()   { echo -e "\033[1;33m⚠️  $*\033[0m"; }
error()  { echo -e "\033[1;31m❌ $*\033[0m" >&2; exit 1; }
success(){ echo -e "\033[1;32m✔️  $*\033[0m"; }

run_cmd() {
    local cmd="$*"
    if $DRY_RUN; then
        echo "[dry-run] $cmd"
    else
        eval "$cmd"
    fi
}

confirm_sudo() {
    if ! command -v sudo &>/dev/null; then
        error "sudo is required. Run as root or install sudo first."
    fi
    log "Requesting sudo access..."
    run_cmd "sudo -v"
}

safe_copy() {
    local src="$1" dest="$2"
    if $DRY_RUN; then
        echo "[dry-run] cp -r \"$src\" \"$dest\""
    else
        mkdir -p "$(dirname "$dest")"
        cp -r "$src" "$dest"
    fi
}

file_contains() {
    local file="$1" pattern="$2"
    grep -q "$pattern" "$file" 2>/dev/null
}
