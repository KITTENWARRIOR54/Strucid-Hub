local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()

local Window = MacLib:Window({
	Title = "Strucid Hub",
	Subtitle = "-Private",
	Size = UDim2.fromOffset(868, 650),
	DragStyle = 1,
	Keybind = Enum.KeyCode.RightControl,
	AcrylicBlur = true,
})

local tabs = Window:TabGroup()

local Main = tabs:Tab({ Name = "Main", Image = "rbxassetid://10734950309" })
local Visuals = tabs:Tab({ Name = "Visuals", Image = "rbxassetid://18821914323" })
local Player = tabs:Tab({ Name = "Player", Image = "rbxassetid://10734950309" })
local Scripts = tabs:Tab({ Name = "Scripts", Image = "rbxassetid://10734950309" })
local Settings = tabs:Tab({ Name = "Settings", Image = "rbxassetid://10734950309" })

local M1 = Main:Section({ Side = "Left" })
local M2 = Main:Section({ Side = "Right" })

M1:Header({ Name = "Main Controls" })

M1:Button({
	Name = "Execute",
	Callback = function()
		print("Execute pressed")
	end
})

M1:Input({
	Name = "Command",
	Placeholder = "Enter command",
	Callback = function(text)
		print("Command:", text)
	end
})

M1:Toggle({
	Name = "Auto Execute",
	Default = false,
	Callback = function(v)
		print("Auto Execute:", v)
	end
})

M2:Slider({
	Name = "Execution Delay",
	Default = 0,
	Minimum = 0,
	Maximum = 5,
	Precision = 2,
	Callback = function(v)
		print("Delay:", v)
	end
})

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local AimbotEnabled = false
local AimbotActive = false
local AimbotSensitivity = 0.5
local AimbotFOV = 90
local AimbotTargetPart = "Head"
local AimbotMode = "Toggle"
local AimbotKeybind = Enum.KeyCode.E
local StickyAimEnabled = false
local CurrentStickyTarget = nil
local WaitingForKeybind = false

local function getNearestEnemy()
	local camera = workspace.CurrentCamera
	local nearestEnemy = nil
	local nearestDistance = AimbotFOV

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= Players.LocalPlayer and player.Character then
			local targetPart = player.Character:FindFirstChild(AimbotTargetPart)
			if targetPart then
				local screenPos = camera:WorldToScreenPoint(targetPart.Position)
				local screenSize = camera.ViewportSize
				local distance = math.sqrt((screenPos.X - screenSize.X / 2) ^ 2 + (screenPos.Y - screenSize.Y / 2) ^ 2)

				if distance < nearestDistance then
					nearestDistance = distance
					nearestEnemy = targetPart
				end
			end
		end
	end

	return nearestEnemy
end

local function aimAtTarget(targetPart)
	if not targetPart or not targetPart.Parent then return end
	
	local camera = workspace.CurrentCamera
	local targetPosition = targetPart.Position
	
	local direction = (targetPosition - camera.CFrame.Position).Unit
	local newCFrame = CFrame.lookAt(camera.CFrame.Position, camera.CFrame.Position + direction)
	
	camera.CFrame = camera.CFrame:Lerp(newCFrame, AimbotSensitivity)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed and not WaitingForKeybind then return end
	
	if WaitingForKeybind then
		AimbotKeybind = input.KeyCode
		WaitingForKeybind = false
		print("Aimbot keybind set to:", AimbotKeybind.Name)
		return
	end
	
	if input.KeyCode == AimbotKeybind then
		if AimbotMode == "Hold" then
			AimbotActive = true
		elseif AimbotMode == "Toggle" then
			AimbotActive = not AimbotActive
		end
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.KeyCode == AimbotKeybind then
		if AimbotMode == "Hold" then
			AimbotActive = false
			CurrentStickyTarget = nil
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if AimbotEnabled and AimbotActive then
		if StickyAimEnabled and CurrentStickyTarget and CurrentStickyTarget.Parent then
			aimAtTarget(CurrentStickyTarget)
		else
			local target = getNearestEnemy()
			if target then
				CurrentStickyTarget = target
				aimAtTarget(target)
			end
		end
	end
end)

M1:Header({ Name = "Aimbot" })

M1:Toggle({
	Name = "Enable Aimbot",
	Default = false,
	Callback = function(v)
		AimbotEnabled = v
		if not v then AimbotActive = false end
		print("Aimbot:", v)
	end
})

M2:Dropdown({
	Name = "Aimbot Mode",
	Options = { "Toggle", "Hold" },
	Default = 1,
	Callback = function(opt)
		AimbotMode = opt
		AimbotActive = false
		CurrentStickyTarget = nil
		print("Aimbot Mode:", opt)
	end
})

M1:Slider({
	Name = "Aimbot Sensitivity",
	Default = 0.5,
	Minimum = 0.1,
	Maximum = 1,
	Precision = 2,
	Callback = function(v)
		AimbotSensitivity = v
		print("Sensitivity:", v)
	end
})

M1:Slider({
	Name = "Aimbot FOV",
	Default = 90,
	Minimum = 10,
	Maximum = 360,
	Precision = 0,
	Callback = function(v)
		AimbotFOV = v
		print("FOV:", v)
	end
})

M2:Dropdown({
	Name = "Target Body Part",
	Options = { "Head", "Torso", "UpperTorso", "LowerTorso" },
	Default = 1,
	Callback = function(opt)
		AimbotTargetPart = opt
		CurrentStickyTarget = nil
		print("Target Part:", opt)
	end
})

M2:Toggle({
	Name = "Sticky Aim",
	Default = false,
	Callback = function(v)
		StickyAimEnabled = v
		if not v then CurrentStickyTarget = nil end
		print("Sticky Aim:", v)
	end
})

M1:Button({
	Name = "Keybind: " .. AimbotKeybind.Name,
	Callback = function()
		WaitingForKeybind = true
		print("Press any key to set aimbot keybind...")
	end
})

local V1 = Visuals:Section({ Side = "Left" })
local V2 = Visuals:Section({ Side = "Right" })

V1:Toggle({
	Name = "Enable UI Glow",
	Default = false,
	Callback = function(v)
		print("Glow:", v)
	end
})

V1:Colorpicker({
	Name = "Theme Color",
	Default = Color3.fromRGB(0,200,255),
	Callback = function(c)
		print("Theme color:", c)
	end
})

V2:Slider({
	Name = "UI Transparency",
	Default = 1,
	Minimum = 0.1,
	Maximum = 1,
	Precision = 2,
	Callback = function(v)
		print("Transparency:", v)
	end
})

local P1 = Player:Section({ Side = "Left" })
local P2 = Player:Section({ Side = "Right" })

P1:Toggle({
	Name = "Anti AFK",
	Default = false,
	Callback = function(v)
		print("Anti AFK:", v)
	end
})

P1:Slider({
	Name = "WalkSpeed",
	Default = 16,
	Minimum = 0,
	Maximum = 100,
	Callback = function(v)
		print("WalkSpeed slider:", v)
	end
})

P1:Slider({
	Name = "JumpPower",
	Default = 50,
	Minimum = 0,
	Maximum = 200,
	Callback = function(v)
		print("JumpPower:", v)
	end
})

P2:Dropdown({
	Name = "Movement Mode",
	Options = { "Default", "Smooth", "Arcade" },
	Default = 1,
	Callback = function(opt)
		print("Movement Mode:", opt)
	end
})

local S1 = Scripts:Section({ Side = "Left" })
local S2 = Scripts:Section({ Side = "Right" })

S1:Input({
	Name = "URL Loader",
	Placeholder = "Paste script URL",
	Callback = function(url)
		print("URL entered:", url)
	end
})

S1:Button({
	Name = "Run URL",
	Callback = function()
		print("Run URL pressed")
	end
})

S2:Dropdown({
	Name = "Preloaded Scripts",
	Options = { "Example 1", "Example 2", "Example 3" },
	Default = 1,
	Callback = function(opt)
		print("Selected Script:", opt)
	end
})

S2:Button({
	Name = "Run Selected Script",
	Callback = function()
		print("Run selected script pressed")
	end
})

Settings:InsertConfigSection("Left")

Window.onUnloaded(function()
	print("UI closed")
end)

Main:Select()
MacLib:LoadAutoLoadConfig()

wait(0.5)
local success, AvatarViewer = pcall(function()
	return loadstring(readfile("c:\\Users\\Developer Trap\\Desktop\\my strucid universal script\\avatar_viewer.lua"))()
end)

if success and AvatarViewer then
	spawn(function()
		while true do
			AvatarViewer.updateTargetPart(AimbotTargetPart)
			wait(0.1)
		end
	end)
end
