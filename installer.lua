local user_home = os.getenv("HOME")
local sudo_user = os.getenv("SUDO_USER")

if sudo_user and sudo_user ~= "root" then
    user_home = "/home/" .. sudo_user
end

local function run(cmd)
    local ok, _, code = os.execute(cmd)
    return code == 0
end

local function has_cmd(cmd)
    return run("command -v " .. cmd .. " >/dev/null 2>&1")
end

local pacman_cmd
if has_cmd("sudo") then
    pacman_cmd = "sudo pacman -S --needed --noconfirm"
else
    error("Error: You must either run this as root or have sudo installed")
end

if has_cmd("sudo") then
    print("Requesting sudo access")
    run("sudo -v")
end

-- Install packages
print("==> Installing packages")

local pkg_file = io.open("packages", "r")
if not pkg_file then
    error("Error: Could not open 'packages' file.")
end

for line in pkg_file:lines() do
    line = line:match("^%s*(.-)%s*$")
    if line ~= "" and not line:match("^#") then
        print("→ Installing: " .. line)
        if not run(pacman_cmd .. " " .. line) then
            print("⚠️  Failed to install: " .. line)
        end
    end
end
pkg_file:close()

print("==> Updating bash profile")

local bash_profile_path = user_home .. "/.bash_profile"
local bash_profile = io.open(bash_profile_path, "a+")
if not bash_profile then
    error("Error: Could not open " .. bash_profile_path .. " for writing.")
end

bash_profile:write("\n# Added by Lua installer script\n")
bash_profile:write("if uwsm check may-start; then\n")
bash_profile:write("    exec uwsm start hyprland.desktop\n")
bash_profile:write("fi\n")
bash_profile:close()

print("==> Setting up dotfiles")

local config_dir = user_home .. "/.config"
run("mkdir -p " .. config_dir)
run("cp -r dotfiles/* " .. config_dir .. "/")

local once_dir = "dotfiles-once"
if run("[ -d " .. once_dir .. " ]") then
    print("==> Copying dotfiles-once (skipping existing files)")
    -- Copy only files that do not already exist in ~/.config
    run(string.format(
        "find %s -type f | while read file; do " ..
        "rel=${file#%s/}; dest=%s/$rel; " ..
        "if [ ! -f \"$dest\" ]; then " ..
        "mkdir -p \"$(dirname \"$dest\")\" && cp \"$file\" \"$dest\" && echo \"→ Copied $rel\"; " ..
        "else echo \"⚙️  Skipped existing $rel\"; fi; done",
        once_dir, once_dir, config_dir
    ))
end

if sudo_user and sudo_user ~= "root" then
    print("==> Fixing file ownership...")
    run(string.format("sudo chown -R %s:%s %s", sudo_user, sudo_user, user_home))
end

print("==> Setting themes")

run("gsettings set org.gnome.desktop.interface gtk-theme \"Adwaita-dark\"")
run("gsettings set org.gnome.desktop.interface color-scheme \"prefer-dark\"")
run("gsettings set org.gnome.desktop.interface icon-theme \"Adwaita\"")
run("gtk-update-icon-cache /usr/share/icons/Adwaita")

print("==> Activating bluetooth")

run("sudo systemctl enable --now bluetooth.service")