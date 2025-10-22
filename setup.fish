#!/usr/bin/env fish

if set -q SUDO_USER; and test "$SUDO_USER" != "root"
    set REAL_USER $SUDO_USER
else
    set REAL_USER (whoami)
end

chsh -s (which fish) $REAL_USER

# Install fisher and fzf plugin
if not functions -q fisher
    echo "Installing fisher..."
    pacman -S --noconfirm fisher
end

fisher install PatrickF1/fzf.fish