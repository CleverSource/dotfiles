sudo -v
sudo pacman -S --needed --noconfirm lua
bash system/nvidia.sh
lua installer.lua