--================================================================--
--                   STEAL EGG CHILLI HUB (ANTI GUARD)            --
--================================================================--

-- [ Services & Globals ]
local CoreGui   = game:GetService("CoreGui")
local Players   = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- [ Theme Colors ]
local COLOR_MAIN_BG      = Color3.fromRGB(45, 45, 45)
local COLOR_DARK_BG      = Color3.fromRGB(30, 30, 30)
local COLOR_BTN_BG       = Color3.fromRGB(35, 35, 35)
local COLOR_BORDER_RED   = Color3.fromRGB(255, 0, 0)
local COLOR_BORDER_DARK  = Color3.fromRGB(150, 0, 0)
local COLOR_TEXT_WHITE   = Color3.fromRGB(255, 255, 255)
local COLOR_TEXT_ON      = Color3.fromRGB(100, 255, 100)
local COLOR_TEXT_OFF     = Color3.fromRGB(255, 100, 100)

-- [ State Variables ]
local SuperSpeedEnabled = false
local FlyEnabled        = false
local SpeedMultiplier   = 2.5
local FlySpeed          = 150

local speedConnection   = nil
local flyConnection     = nil
local platformPart      = nil

--================================================================--
-- 1. CLEANUP PREVIOUS INSTANCES
--================================================================--
if CoreGui:FindFirstChild("StealEggChilliHub") then
    CoreGui.StealEggChilliHub:Destroy()
end

--================================================================--
-- 2. UI INITIALIZATION
--================================================================--

-- ScreenGui Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealEggChilliHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Main Frame (200 x 140)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 140)
MainFrame.Position = UDim2.new(0.5, -100, 0.3, -70)
MainFrame.BackgroundColor3 = COLOR_MAIN_BG
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = COLOR_BORDER_RED
MainStroke.Thickness = 2
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("TextLabel")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 25)
TitleBar.BackgroundColor3 = COLOR_DARK_BG
TitleBar.BorderSizePixel = 0
TitleBar.Text = "  STEAL EGG - ANTI GUARD"
TitleBar.TextColor3 = COLOR_TEXT_WHITE
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Font = Enum.Font.Code
TitleBar.TextSize = 11
TitleBar.Parent = MainFrame

-- Minimize Button (-)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
MinimizeBtn.Position = UDim2.new(1, -45, 0, 2.5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = COLOR_TEXT_WHITE
MinimizeBtn.Font = Enum.Font.Code
MinimizeBtn.TextSize = 14
MinimizeBtn.Parent = MainFrame

local MinStroke = Instance.new("UIStroke")
MinStroke.Color = COLOR_BORDER_RED
MinStroke.Thickness = 1
MinStroke.Parent = MinimizeBtn

-- Close Button (×)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -22, 0, 2.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "×"
CloseBtn.TextColor3 = COLOR_TEXT_WHITE
CloseBtn.Font = Enum.Font.Code
CloseBtn.TextSize = 14
CloseBtn.Parent = MainFrame

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Color = COLOR_BORDER_RED
CloseStroke.Thickness = 1
CloseStroke.Parent = CloseBtn

-- Controls Container
local ButtonContainer = Instance.new("Frame")
ButtonContainer.Name = "ButtonContainer"
ButtonContainer.Size = UDim2.new(1, 0, 1, -25)
ButtonContainer.Position = UDim2.new(0, 0, 0, 25)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Parent = MainFrame

-- --- Speed Bypass Elements ---
local WalkInput = Instance.new("TextBox")
WalkInput.Name = "WalkInput"
WalkInput.Size = UDim2.new(1, -20, 0, 22)
WalkInput.Position = UDim2.new(0, 10, 0, 6)
WalkInput.BackgroundColor3 = COLOR_DARK_BG
WalkInput.BorderSizePixel = 0
WalkInput.Text = "2.5"
WalkInput.PlaceholderText = "Speed Multiplier"
WalkInput.TextColor3 = COLOR_TEXT_WHITE
WalkInput.Font = Enum.Font.Code
WalkInput.TextSize = 11
WalkInput.Parent = ButtonContainer

local WalkInputStroke = Instance.new("UIStroke")
WalkInputStroke.Color = COLOR_BORDER_DARK
WalkInputStroke.Thickness = 1
WalkInputStroke.Parent = WalkInput

local WalkToggle = Instance.new("TextButton")
WalkToggle.Name = "WalkToggle"
WalkToggle.Size = UDim2.new(1, -20, 0, 24)
WalkToggle.Position = UDim2.new(0, 10, 0, 32)
WalkToggle.BackgroundColor3 = COLOR_BTN_BG
WalkToggle.BorderSizePixel = 0
WalkToggle.Text = "SPEED BYPASS: OFF"
WalkToggle.TextColor3 = COLOR_TEXT_OFF
WalkToggle.Font = Enum.Font.Code
WalkToggle.TextSize = 11
WalkToggle.Parent = ButtonContainer

local WalkStroke = Instance.new("UIStroke")
WalkStroke.Color = COLOR_BORDER_RED
WalkStroke.Thickness = 1
WalkStroke.Parent = WalkToggle

-- --- Fly Bypass Elements ---
local FlyInput = Instance.new("TextBox")
FlyInput.Name = "FlyInput"
FlyInput.Size = UDim2.new(1, -20, 0, 22)
FlyInput.Position = UDim2.new(0, 10, 0, 62)
FlyInput.BackgroundColor3 = COLOR_DARK_BG
FlyInput.BorderSizePixel = 0
FlyInput.Text = "150"
FlyInput.PlaceholderText = "Fly Speed Value"
FlyInput.TextColor3 = COLOR_TEXT_WHITE
FlyInput.Font = Enum.Font.Code
FlyInput.TextSize = 11
FlyInput.Parent = ButtonContainer

local FlyInputStroke = Instance.new("UIStroke")
FlyInputStroke.Color = COLOR_BORDER_DARK
FlyInputStroke.Thickness = 1
FlyInputStroke.Parent = FlyInput

local FlyToggle = Instance.new("TextButton")
FlyToggle.Name = "FlyToggle"
FlyToggle.Size = UDim2.new(1, -20, 0, 24)
FlyToggle.Position = UDim2.new(0, 10, 0, 88)
FlyToggle.BackgroundColor3 = COLOR_BTN_BG
FlyToggle.BorderSizePixel = 0
FlyToggle.Text = "FLY BYPASS: OFF"
FlyToggle.TextColor3 = COLOR_TEXT_OFF
FlyToggle.Font = Enum.Font.Code
FlyToggle.TextSize = 11
FlyToggle.Parent = ButtonContainer

local FlyStroke = Instance.new("UIStroke")
FlyStroke.Color = COLOR_BORDER_RED
FlyStroke.Thickness = 1
FlyStroke.Parent = FlyToggle

-- Floating Minimal Logo (SYS)
local FloatingLogo = Instance.new("TextButton")
FloatingLogo.Name = "FloatingLogo"
FloatingLogo.Size = UDim2.new(0, 40, 0, 40)
FloatingLogo.BackgroundColor3 = COLOR_MAIN_BG
FloatingLogo.BorderSizePixel = 0
FloatingLogo.Text = "SYS"
FloatingLogo.TextColor3 = COLOR_TEXT_WHITE
FloatingLogo.Font = Enum.Font.Code
FloatingLogo.TextSize = 12
FloatingLogo.Visible = false
FloatingLogo.Active = true
FloatingLogo.Draggable = true
FloatingLogo.Parent = ScreenGui

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = COLOR_BORDER_RED
LogoStroke.Thickness = 2
LogoStroke.Parent = FloatingLogo

--================================================================--
-- 3. CORE LOGIC & ANTI-GUARD ENGINE
--================================================================--

-- Platform Lock Generator (Invis Platform to Bypass Fly Detection)
local function managePlatform(state)
    if platformPart then 
        pcall(function() platformPart:Destroy() end)
        platformPart = nil 
    end
    
    if state then
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            platformPart = Instance.new("Part")
            platformPart.Name = "AntiGuard_Platform"
            platformPart.Size = Vector3.new(6, 1, 6)
            platformPart.Transparency = 1
            platformPart.Anchored = true
            platformPart.CanCollide = true
            platformPart.Parent = workspace
        end
    end
end

-- Update Movement Loops
local function updateBypassLoops()
    if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    managePlatform(false)

    -- Speed Bypass Loop
    if SuperSpeedEnabled and not FlyEnabled then
        speedConnection = RunService.Heartbeat:Connect(function(deltaTime)
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            
            if hum and root and hum.MoveDirection.Magnitude > 0 then
                local currentSpeed = hum.WalkSpeed
                root.CFrame = root.CFrame + (hum.MoveDirection * (currentSpeed * SpeedMultiplier) * deltaTime)
            end
        end)
    end

    -- Fly Bypass Loop (Anti Guard with Floating Platform)
    if FlyEnabled then
        managePlatform(true)
        flyConnection = RunService.Heartbeat:Connect(function(deltaTime)
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            
            if not root or not hum then return end
            
            root.Velocity = Vector3.zero
            local camera = workspace.CurrentCamera
            
            if hum.MoveDirection.Magnitude > 0 and camera then
                local flyVelocity = (camera.CFrame.LookVector * (hum.MoveDirection.Z * -1) + camera.CFrame.RightVector * hum.MoveDirection.X).Unit
                local nextCFrame = root.CFrame + (flyVelocity * FlySpeed * deltaTime)
                
                -- Height Clamping
                local currentY = nextCFrame.Y
                if currentY < -50 then
                    nextCFrame = CFrame.new(nextCFrame.X, -50, nextCFrame.Z)
                elseif currentY > 1000 then
                    nextCFrame = CFrame.new(nextCFrame.X, 1000, nextCFrame.Z)
                end
                
                root.CFrame = nextCFrame
            end
            
            -- Keep platform directly under feet
            if platformPart then
                platformPart.CFrame = root.CFrame - Vector3.new(0, 3, 0)
            end
        end)
    end
end

-- Client Anti-Kick Hook
pcall(function()
    local oldNamecall
    oldNamecall = hookmetatable(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if tostring(self) == "BAC_ClientCheck" or method == "Kick" then
            return nil
        end
        return oldNamecall(self, ...)
    end)
end)

--================================================================--
-- 4. EVENT LISTENERS
--================================================================--

-- Window Toggle (Minimize / Restore)
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatingLogo.Position = UDim2.new(0, MainFrame.AbsolutePosition.X + 80, 0, MainFrame.AbsolutePosition.Y + 50)
    FloatingLogo.Visible = true
end)

FloatingLogo.MouseButton1Click:Connect(function()
    FloatingLogo.Visible = false
    MainFrame.Position = UDim2.new(0, FloatingLogo.AbsolutePosition.X - 80, 0, FloatingLogo.AbsolutePosition.Y - 50)
    MainFrame.Visible = true
end)

-- Speed Controls
WalkToggle.MouseButton1Click:Connect(function()
    SuperSpeedEnabled = not SuperSpeedEnabled
    if SuperSpeedEnabled then FlyEnabled = false end
    
    WalkToggle.Text = SuperSpeedEnabled and "SPEED BYPASS: ON" or "SPEED BYPASS: OFF"
    WalkToggle.TextColor3 = SuperSpeedEnabled and COLOR_TEXT_ON or COLOR_TEXT_OFF
    
    FlyToggle.Text = "FLY BYPASS: OFF"
    FlyToggle.TextColor3 = COLOR_TEXT_OFF
    
    updateBypassLoops()
end)

WalkInput.FocusLost:Connect(function()
    local num = tonumber(WalkInput.Text)
    if num then 
        SpeedMultiplier = num 
    else 
        WalkInput.Text = tostring(SpeedMultiplier) 
    end
    
    if SuperSpeedEnabled then updateBypassLoops() end
end)

-- Fly Controls
FlyToggle.MouseButton1Click:Connect(function()
    FlyEnabled = not FlyEnabled
    if FlyEnabled then SuperSpeedEnabled = false end
    
    FlyToggle.Text = FlyEnabled and "FLY BYPASS: ON" or "FLY BYPASS: OFF"
    FlyToggle.TextColor3 = FlyEnabled and COLOR_TEXT_ON or COLOR_TEXT_OFF
    
    WalkToggle.Text = "SPEED BYPASS: OFF"
    WalkToggle.TextColor3 = COLOR_TEXT_OFF
    
    if not FlyEnabled then
        pcall(function() 
            LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.zero 
        end)
    end
    
    updateBypassLoops()
end)

FlyInput.FocusLost:Connect(function()
    local num = tonumber(FlyInput.Text)
    if num then 
        FlySpeed = num 
    else 
        FlyInput.Text = tostring(FlySpeed) 
    end
    
    if FlyEnabled then updateBypassLoops() end
end)

-- Close Button
CloseBtn.MouseButton1Click:Connect(function()
    SuperSpeedEnabled = false
    FlyEnabled = false
    
    if speedConnection then speedConnection:Disconnect() end
    if flyConnection then flyConnection:Disconnect() end
    
    managePlatform(false)
    
    pcall(function() 
        LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.zero 
    end)
    
    ScreenGui:Destroy()
end)
