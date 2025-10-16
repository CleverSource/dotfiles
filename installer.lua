local user_home = os.getenv("HOME")
local sudo_user = os.getenv("SUDO_USER")
if sudo_user and sudo_user ~= "root" then
    user_home = "/home/" .. sudo_user
end

print("Beginning installation...")

os.execute("sudo -v")

for line in io.lines("packages") do
    if line:sub(1, 1) ~= "#" and line:match("%S") then
        print("Installing package: " .. line)
        os.execute("sudo pacman -S --needed --noconfirm " .. line)
    end
end

print("Updating bash profile")

local bash_profile_path = user_home .. "/.bash_profile"
local bash_profile = io.open(bash_profile_path, "a+")

if bash_profile == nil then
    error("Error: Could not open .bash_profile for writing.")
end

bash_profile:write("\n# Added by Lua installer script\n")
bash_profile:write("if uwsm check may-start; then\n")
bash_profile:write("    exec uwsm start hyprland.desktop\n")
bash_profile:write("fi\n")
bash_profile:close()

print("Setting up dotfiles")

os.execute("mkdir -p " .. user_home .. "/.config")
os.execute("cp -r dotfiles/* " .. user_home .. "/.config/")