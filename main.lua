local base = "https://raw.githubusercontent.com/KITTENWARRIOR54/REPO-NAME/main/"

local function import(file)
    return loadstring(game:HttpGet(base .. file))()
end

local avatar = import("avatar_viewer.lua")

if avatar and avatar.Init then
    avatar.Init()
end
