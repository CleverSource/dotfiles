#!/usr/bin/env fish

chsh -s (which fish) (whoami)

# Install fisher and fzf plugin
if not functions -q fisher
    echo "Installing fisher..."
    sudo pacman -S --noconfirm fish
end

fisher install PatrickF1/fzf.fish

fzf_configure_bindings --directory=\cf