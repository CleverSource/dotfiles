#!/usr/bin/env fish

chsh -s (which fish)

# Install fisher and fzf plugin
if not functions -q fisher
    echo "Installing fisher..."
    sudo pacman -S --noconfirm fisher
end

fisher install PatrickF1/fzf.fish