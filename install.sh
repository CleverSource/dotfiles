sudo -v
sudo pacman -S --needed --noconfirm lua

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..

bash system/nvidia.sh
lua installer.lua