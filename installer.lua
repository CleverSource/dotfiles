print("Beginning installation...")

for line in io.lines("packages") do
    if line:sub(1, 1) ~= "#" and line:match("%S") then
        print("Installing package: " .. line)
        os.execute("pacman -S --noconfirm " .. line)
    end
end

print("Updating bash profile")

local bash_profile = io.open(os.getenv("USERPROFILE") .. "/.bash_profile", "a")
if bash_profile == nil then
    error("Error: Could not open .bash_profile for writing.")
end

bash_profile:write("\n# Added by Lua installer script\n")
bash_profile:write("if uwsm check may-start; then\n")
bash_profile:write("    exec uwsm start hyprland.desktop\n")
bash_profile:write("fi\n")
bash_profile:close()

print("Setting up dotfiles")

os.execute("mkdir -p " .. os.getenv("USERPROFILE") .. "/.config")
os.execute("cp -r dotfiles/* " .. os.getenv("USERPROFILE") .. "/.config/")