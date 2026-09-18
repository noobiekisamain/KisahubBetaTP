-- Load LinoriaLib and addons
local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Create Main Window
local Window = Library:CreateWindow({
    Title = 'kisahub {pre release 1.2}',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- Tabs
local MainTab = Window:AddTab('Main')
local SettingsTab = Window:AddTab('UI Settings')

-- Groups
local TeleportGroup = MainTab:AddLeftGroupbox('Teleport & Orbit')
local PlayerGroup = MainTab:AddLeftGroupbox('Local Player')
local MovementGroup = MainTab:AddRightGroupbox('Spin & Visual')

--------------------------------------------------------
-- TELEPORT & ORBIT CONTROLS
--------------------------------------------------------
TeleportGroup:AddToggle('TPAboveToggle', {
    Text = 'TP Above Enemy',
    Default = false,
    Tooltip = 'Teleports you above the closest enemy',
    Callback = function(Value)
        if Value then
            Toggles.TPUnderToggle:SetValue(false)
            Toggles.OrbitToggle:SetValue(false)
        end
    end
})

TeleportGroup:AddToggle('TPUnderToggle', {
    Text = 'TP Under Enemy',
    Default = false,
    Tooltip = 'Teleports you beneath the closest enemy',
    Callback = function(Value)
        if Value then
            Toggles.TPAboveToggle:SetValue(false)
            Toggles.OrbitToggle:SetValue(false)
        end
    end
})

TeleportGroup:AddToggle('OrbitToggle', {
    Text = 'Orbit Enemy',
    Default = false,
    Tooltip = 'Orbits continuously around the closest enemy',
    Callback = function(Value)
        if Value then
            Toggles.TPAboveToggle:SetValue(false)
            Toggles.TPUnderToggle:SetValue(false)
        end
    end
})

TeleportGroup:AddSlider('HeightOffsetSlider', {
    Text = 'Height Offset',
    Default = 10,
    Min = 1,
    Max = 50,
    Rounding = 0,
    Compact = false
})

TeleportGroup:AddSlider('ForwardOffsetSlider', {
    Text = 'Forward Offset',
    Default = 0,
    Min = -20,
    Max = 20,
    Rounding = 0,
    Compact = false
})

TeleportGroup:AddSlider('OrbitRadiusSlider', {
    Text = 'Orbit Radius',
    Default = 15,
    Min = 5,
    Max = 50,
    Rounding = 0,
    Compact = false
})

TeleportGroup:AddSlider('OrbitSpeedSlider', {
    Text = 'Orbit Speed',
    Default = 5,
    Min = 1,
    Max = 20,
    Rounding = 0,
    Compact = false
})

--------------------------------------------------------
-- LOCAL PLAYER CONTROLS (WalkSpeed, Jump, Noclip, Fly)
--------------------------------------------------------
PlayerGroup:AddToggle('WalkSpeedToggle', {
    Text = 'Enable WalkSpeed',
    Default = false,
    Tooltip = 'Modifies movement speed'
})

PlayerGroup:AddSlider('WalkSpeedSlider', {
    Text = 'WalkSpeed',
    Default = 16,
    Min = 16,
    Max = 250,
    Rounding = 0,
    Compact = false
})

PlayerGroup:AddToggle('JumpHeightToggle', {
    Text = 'Enable Jump Power/Height',
    Default = false,
    Tooltip = 'Modifies jump height'
})

PlayerGroup:AddSlider('JumpHeightSlider', {
    Text = 'Jump Height',
    Default = 50,
    Min = 50,
    Max = 300,
    Rounding = 0,
    Compact = false
})

PlayerGroup:AddToggle('NoclipToggle', {
    Text = 'Noclip',
    Default = false,
    Tooltip = 'Pass through solid objects and walls'
})

PlayerGroup:AddToggle('FlyToggle', {
    Text = 'Flight',
    Default = false,
    Tooltip = 'Allows full 3D directional flight'
})

PlayerGroup:AddSlider('FlySpeedSlider', {
    Text = 'Flight Speed',
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 0,
    Compact = false
})

--------------------------------------------------------
-- SPIN CONTROLS
--------------------------------------------------------
MovementGroup:AddToggle('SpinToggle', {
    Text = 'Spin Character',
    Default = false,
    Tooltip = 'Spins character in multiple axes'
})

MovementGroup:AddSlider('SpinSpeedSlider', {
    Text = 'Spin Speed',
    Default = 30,
    Min = 5,
    Max = 100,
    Rounding = 0,
    Compact = false
})

--------------------------------------------------------
-- HELPER FUNCTIONS
--------------------------------------------------------
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

--------------------------------------------------------
-- MAIN EXECUTION LOOPS
--------------------------------------------------------
local spinAngleX, spinAngleY, spinAngleZ = 0, 0, 0
local orbitAngle = 0

-- Flight Variables
local bodyGyro, bodyVelocity

RunService.Stepped:Connect(function()
    -- Noclip Execution
    if Toggles.NoclipToggle and Toggles.NoclipToggle.Value then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    -- WalkSpeed Modifier
    if Toggles.WalkSpeedToggle and Toggles.WalkSpeedToggle.Value then
        humanoid.WalkSpeed = Options.WalkSpeedSlider.Value
    end

    -- Jump Height / Power Modifier
    if Toggles.JumpHeightToggle and Toggles.JumpHeightToggle.Value then
        if humanoid.UseJumpPower then
            humanoid.JumpPower = Options.JumpHeightSlider.Value
        else
            humanoid.JumpHeight = Options.JumpHeightSlider.Value
        end
    end

    -- Flight Execution
    if Toggles.FlyToggle and Toggles.FlyToggle.Value then
        if not bodyGyro then
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.P = 9e4
            bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bodyGyro.cframe = hrp.CFrame
            bodyGyro.Parent = hrp
        end

        if not bodyVelocity then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.velocity = Vector3.new(0, 0, 0)
            bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyVelocity.Parent = hrp
        end

        local camera = Workspace.CurrentCamera
        local flySpeed = Options.FlySpeedSlider.Value
        local velocity = Vector3.new(0, 0, 0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            velocity = velocity + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            velocity = velocity - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            velocity = velocity - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            velocity = velocity + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            velocity = velocity + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            velocity = velocity - Vector3.new(0, 1, 0)
        end

        bodyVelocity.velocity = velocity * flySpeed
        bodyGyro.cframe = camera.CFrame
    else
        if bodyGyro then
            bodyGyro:Destroy()
            bodyGyro = nil
        end
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
    end

    -- Target Positions (TP & Orbit)
    local enemy = GetClosestEnemyToPlayer()
    local enemyHrp = (enemy and enemy.Character) and enemy.Character:FindFirstChild("HumanoidRootPart")

    if Toggles.TPAboveToggle and Toggles.TPAboveToggle.Value and enemyHrp then
        local height = Options.HeightOffsetSlider.Value
        local forward = Options.ForwardOffsetSlider.Value
        hrp.CFrame = enemyHrp.CFrame * CFrame.new(0, height, forward) * CFrame.Angles(math.rad(-90), 0, 0)

    elseif Toggles.TPUnderToggle and Toggles.TPUnderToggle.Value and enemyHrp then
        local height = Options.HeightOffsetSlider.Value
        local forward = Options.ForwardOffsetSlider.Value
        hrp.CFrame = enemyHrp.CFrame * CFrame.new(0, -height, forward) * CFrame.Angles(math.rad(90), 0, 0)

    elseif Toggles.OrbitToggle and Toggles.OrbitToggle.Value and enemyHrp then
        local radius = Options.OrbitRadiusSlider.Value
        local speed = Options.OrbitSpeedSlider.Value
        
        orbitAngle = (orbitAngle + math.rad(speed)) % (math.pi * 2)
        local offsetX = math.cos(orbitAngle) * radius
        local offsetZ = math.sin(orbitAngle) * radius
        
        local targetPosition = enemyHrp.Position + Vector3.new(offsetX, 0, offsetZ)
        hrp.CFrame = CFrame.new(targetPosition, enemyHrp.Position)
    end

    -- Character Spin Logic
    if Toggles.SpinToggle and Toggles.SpinToggle.Value then
        local speed = Options.SpinSpeedSlider.Value
        spinAngleX = (spinAngleX + speed) % 360
        spinAngleY = (spinAngleY + (speed * 1.5)) % 360
        spinAngleZ = (spinAngleZ + (speed * 2)) % 360
        
        local currentPos = hrp.Position
        hrp.CFrame = CFrame.new(currentPos) * CFrame.Angles(math.rad(spinAngleX), math.rad(spinAngleY), math.rad(spinAngleZ))
    end
end)

--------------------------------------------------------
-- LINORIA SAVE & THEME SETUP
--------------------------------------------------------
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('kisahub')
SaveManager:SetFolder('kisahub/rivals')

SaveManager:BuildConfigSection(SettingsTab)
ThemeManager:ApplyToTab(SettingsTab)

SaveManager:LoadAutoloadConfig()
