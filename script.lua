-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Configuration & State
local Config = {
	TeleportEnabled = false,
	SpinEnabled = false,
	OrbitEnabled = false,
	UnderEnabled = false,
	HeightOffset = 10,
	ForwardOffset = 0,
	SpinSpeed = 30,
	OrbitRadius = 15,
	OrbitSpeed = 5
}

-- Destroy existing UI instance
if PlayerGui:FindFirstChild("KisaHubGUI") then
	PlayerGui.KisaHubGUI:Destroy()
end

-- Create GUI Elements
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KisaHubGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 480)
MainFrame.Position = UDim2.new(0.5, -130, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 170, 255)
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "kisahub {alpha 1}"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Draggable UI
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

MainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Helper Builders
local function CreateButton(text, pos, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9, 0, 0, 32)
	btn.Position = pos
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansSemibold
	btn.TextSize = 13
	btn.Parent = MainFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		callback(btn)
	end)
	return btn
end

local function CreateSlider(text, pos, defaultVal, minVal, maxVal, callback)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.9, 0, 0, 18)
	label.Position = pos
	label.BackgroundTransparency = 1
	label.Text = text .. ": " .. tostring(defaultVal)
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Font = Enum.Font.SourceSans
	label.TextSize = 12
	label.Parent = MainFrame

	local sliderBg = Instance.new("TextButton")
	sliderBg.Size = UDim2.new(0.9, 0, 0, 8)
	sliderBg.Position = pos + UDim2.new(0, 0, 0, 18)
	sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	sliderBg.Text = ""
	sliderBg.Parent = MainFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = sliderBg

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	fill.BorderSizePixel = 0
	fill.Parent = sliderBg

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 4)
	fillCorner.Parent = fill

	local sliding = false
	local function update(input)
		local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
		fill.Size = UDim2.new(percent, 0, 1, 0)
		local val = math.floor(minVal + (maxVal - minVal) * percent)
		label.Text = text .. ": " .. tostring(val)
		callback(val)
	end

	sliderBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = true
			update(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
			update(input)
		end
	end)
end

-- Controls
CreateButton("TP Above Enemy: OFF", UDim2.new(0.05, 0, 0, 45), function(btn)
	Config.TeleportEnabled = not Config.TeleportEnabled
	btn.Text = "TP Above Enemy: " .. (Config.TeleportEnabled and "ON" or "OFF")
	btn.BackgroundColor3 = Config.TeleportEnabled and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(40, 40, 50)
end)

CreateButton("TP Under Enemy: OFF", UDim2.new(0.05, 0, 0, 82), function(btn)
	Config.UnderEnabled = not Config.UnderEnabled
	btn.Text = "TP Under Enemy: " .. (Config.UnderEnabled and "ON" or "OFF")
	btn.BackgroundColor3 = Config.UnderEnabled and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(40, 40, 50)
end)

CreateButton("Orbit Enemy: OFF", UDim2.new(0.05, 0, 0, 119), function(btn)
	Config.OrbitEnabled = not Config.OrbitEnabled
	btn.Text = "Orbit Enemy: " .. (Config.OrbitEnabled and "ON" or "OFF")
	btn.BackgroundColor3 = Config.OrbitEnabled and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(40, 40, 50)
end)

CreateButton("Spin Character: OFF", UDim2.new(0.05, 0, 0, 156), function(btn)
	Config.SpinEnabled = not Config.SpinEnabled
	btn.Text = "Spin Character: " .. (Config.SpinEnabled and "ON" or "OFF")
	btn.BackgroundColor3 = Config.SpinEnabled and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(40, 40, 50)
end)

CreateSlider("Height Offset", UDim2.new(0.05, 0, 0, 195), Config.HeightOffset, 1, 50, function(val)
	Config.HeightOffset = val
end)

CreateSlider("Forward Offset", UDim2.new(0.05, 0, 0, 235), Config.ForwardOffset, -20, 20, function(val)
	Config.ForwardOffset = val
end)

CreateSlider("Orbit Radius", UDim2.new(0.05, 0, 0, 275), Config.OrbitRadius, 5, 50, function(val)
	Config.OrbitRadius = val
end)

CreateSlider("Orbit Speed", UDim2.new(0.05, 0, 0, 315), Config.OrbitSpeed, 1, 20, function(val)
	Config.OrbitSpeed = val
end)

CreateSlider("Spin Speed", UDim2.new(0.05, 0, 0, 355), Config.SpinSpeed, 5, 100, function(val)
	Config.SpinSpeed = val
end)

-- Target Selection Helper
local function GetClosestEnemyToPlayer()
	local closestPlayer = nil
	local shortestDist = math.huge
	local myChar = LocalPlayer.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
	local myPos = myChar.HumanoidRootPart.Position

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and (player.Team == nil or player.Team ~= LocalPlayer.Team) then
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
				if char.Humanoid.Health > 0 then
					local dist = (char.HumanoidRootPart.Position - myPos).Magnitude
					if dist < shortestDist then
						shortestDist = dist
						closestPlayer = player
					end
				end
			end
		end
	end
	return closestPlayer
end

-- Teleport, Under, Orbit, and Spin Execution Loop
local spinAngleX, spinAngleY, spinAngleZ = 0, 0, 0
local orbitAngle = 0

RunService.Heartbeat:Connect(function()
	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local enemy = GetClosestEnemyToPlayer()
	local enemyHrp = (enemy and enemy.Character) and enemy.Character:FindFirstChild("HumanoidRootPart")

	-- Teleport Above Logic
	if Config.TeleportEnabled and enemyHrp then
		local targetCFrame = enemyHrp.CFrame 
			* CFrame.new(0, Config.HeightOffset, Config.ForwardOffset) 
			* CFrame.Angles(math.rad(-90), 0, 0)
		
		hrp.CFrame = targetCFrame

	-- Teleport Under Logic
	elseif Config.UnderEnabled and enemyHrp then
		local targetCFrame = enemyHrp.CFrame 
			* CFrame.new(0, -Config.HeightOffset, Config.ForwardOffset) 
			* CFrame.Angles(math.rad(90), 0, 0)
		
		hrp.CFrame = targetCFrame

	-- Orbit Logic
	elseif Config.OrbitEnabled and enemyHrp then
		orbitAngle = (orbitAngle + math.rad(Config.OrbitSpeed)) % (math.pi * 2)
		local offsetX = math.cos(orbitAngle) * Config.OrbitRadius
		local offsetZ = math.sin(orbitAngle) * Config.OrbitRadius
		
		local targetPosition = enemyHrp.Position + Vector3.new(offsetX, 0, offsetZ)
		hrp.CFrame = CFrame.new(targetPosition, enemyHrp.Position)
	end

	-- Character Spin Logic
	if Config.SpinEnabled then
		spinAngleX = (spinAngleX + Config.SpinSpeed) % 360
		spinAngleY = (spinAngleY + (Config.SpinSpeed * 1.5)) % 360
		spinAngleZ = (spinAngleZ + (Config.SpinSpeed * 2)) % 360
		
		local currentPos = hrp.Position
		hrp.CFrame = CFrame.new(currentPos) * CFrame.Angles(math.rad(spinAngleX), math.rad(spinAngleY), math.rad(spinAngleZ))
	end
end)
