local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local AimbotTargetPart = "Head"
local ViewportCamera = nil
local AvatarModel = nil
local HighlightedPart = nil

local function createViewport()
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "AvatarViewport"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	
	local ViewportFrame = Instance.new("ViewportFrame")
	ViewportFrame.Name = "ViewportFrame"
	ViewportFrame.Size = UDim2.new(0, 300, 0, 400)
	ViewportFrame.Position = UDim2.new(0, 20, 0, 20)
	ViewportFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	ViewportFrame.BorderSizePixel = 1
	ViewportFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
	ViewportFrame.Parent = ScreenGui
	
	ViewportCamera = Instance.new("Camera")
	ViewportCamera.Parent = ViewportFrame
	ViewportFrame.CurrentCamera = ViewportCamera
	
	local InfoLabel = Instance.new("TextLabel")
	InfoLabel.Name = "InfoLabel"
	InfoLabel.Size = UDim2.new(1, 0, 0, 40)
	InfoLabel.Position = UDim2.new(0, 0, 1, -40)
	InfoLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	InfoLabel.TextSize = 14
	InfoLabel.Text = "Target Part: Head"
	InfoLabel.Parent = ViewportFrame
	
	return ViewportFrame, InfoLabel
end

local function clonePlayerModel()
	if not LocalPlayer.Character then return nil end
	
	local clone = LocalPlayer.Character:Clone()
	clone.Name = "AvatarClone"
	
	for _, part in pairs(clone:GetDescendants()) do
		if part:IsA("Humanoid") then
			part:Destroy()
		elseif part:IsA("Script") or part:IsA("LocalScript") then
			part:Destroy()
		elseif part:IsA("BodyVelocity") or part:IsA("BodyGyro") or part:IsA("Motor6D") then
			part:Destroy()
		end
	end
	
	for _, part in pairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
	
	return clone
end

local function setupAvatar(viewportFrame)
	if AvatarModel and AvatarModel.Parent then
		AvatarModel:Destroy()
	end
	
	AvatarModel = clonePlayerModel()
	if not AvatarModel then return end
	
	AvatarModel.Parent = viewportFrame
	
	local humanoidRootPart = AvatarModel:FindFirstChild("HumanoidRootPart")
	if humanoidRootPart then
		ViewportCamera.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 0, 5)
		ViewportCamera.Focus = humanoidRootPart.CFrame
	end
end

local function highlightBodyPart(partName)
	if HighlightedPart then
		if HighlightedPart:FindFirstChild("HighlightSurface") then
			HighlightedPart:FindFirstChild("HighlightSurface"):Destroy()
		end
		if HighlightedPart:FindFirstChild("SelectionBox") then
			HighlightedPart:FindFirstChild("SelectionBox"):Destroy()
		end
	end
	
	if AvatarModel then
		local part = AvatarModel:FindFirstChild(partName)
		if part and part:IsA("BasePart") then
			local selection = Instance.new("SelectionBox")
			selection.Name = "SelectionBox"
			selection.Adornee = part
			selection.Color3 = Color3.fromRGB(0, 255, 100)
			selection.LineThickness = 0.05
			selection.Parent = part
			
			HighlightedPart = part
		end
	end
end

local ViewportFrame, InfoLabel = createViewport()
setupAvatar(ViewportFrame)

LocalPlayer.CharacterAdded:Connect(function()
	wait(0.5)
	setupAvatar(ViewportFrame)
	highlightBodyPart(AimbotTargetPart)
end)

local function updateViewport()
	if LocalPlayer.Character and AvatarModel and AvatarModel.Parent then
		local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local avatarRootPart = AvatarModel:FindFirstChild("HumanoidRootPart")
		
		if humanoidRootPart and avatarRootPart then
			local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
			if humanoid then
				local humanoidClone = AvatarModel:FindFirstChild("Humanoid")
				if not humanoidClone then
					humanoidClone = Instance.new("Humanoid")
					humanoidClone.Parent = AvatarModel
				end
				humanoidClone.Health = humanoid.Health
				humanoidClone.MaxHealth = humanoid.MaxHealth
			end
		end
	end
end

RunService.RenderStepped:Connect(updateViewport)

local function updateTargetPart(newPart)
	AimbotTargetPart = newPart
	InfoLabel.Text = "Target Part: " .. newPart
	highlightBodyPart(newPart)
end

return {
	updateTargetPart = updateTargetPart,
	getTargetPart = function() return AimbotTargetPart end
}
