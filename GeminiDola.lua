-- ==============================================================================
-- DELTA HUB - PROFESSIONAL EDITION (Final Complete Version)
-- ==============================================================================

if not Drawing or not getgenv then
    print("Executor ของคุณไม่รองรับ Drawing API")
    return
end

-- ป้องกันการรันซ้ำและเคลียร์ของเก่า
if getgenv().LoadedUI then
    pcall(function()
        getgenv().LoadedUI:Destroy()
    end)
end

if getgenv().MainConnection then getgenv().MainConnection:Disconnect() end
if getgenv().NoclipConnection then getgenv().NoclipConnection:Disconnect() end
if getgenv().PlayerRemovingConnection then getgenv().PlayerRemovingConnection:Disconnect() end
if getgenv().CharacterAddedConnection then getgenv().CharacterAddedConnection:Disconnect() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ค่าการตั้งค่า (Settings)
local Settings = {
    Aimbot = false,
    AimPart = "Head",
    TeamCheck = true,
    VisibleCheck = true,
    FOV = 120,
    ShowFOV = true,
    ESPBox = false,
    ESPDistance = false,
    Wallhack = false,
    Speedhack = false,
    SpeedValue = 25,
    Noclip = false
}

-- สร้าง FOV Circle (Drawing API)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = Settings.FOV
FOVCircle.Color = Color3.fromRGB(46, 204, 113)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7

-- สร้าง ScreenGui หลัก
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaHub_Pro"
ScreenGui.ResetOnSpawn = false

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end
getgenv().LoadedUI = ScreenGui

-- 1. ไอคอนปุ่มลอย (Floating Button) สำหรับเปิด/ปิด UI
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Size = UDim2.new(0, 52, 0, 52)
FloatingBtn.Position = UDim2.new(0, 30, 0.4, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
FloatingBtn.Text = "⚡"
FloatingBtn.TextColor3 = Color3.fromRGB(46, 204, 113)
FloatingBtn.TextSize = 24
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.Active = true
FloatingBtn.Draggable = true
FloatingBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatingBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(46, 204, 113)
FloatStroke.Thickness = 2.5
FloatStroke.Parent = FloatingBtn

-- 2. หน้าต่างหลัก (Main Frame) ดีไซน์ Pro
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 420)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 45, 65)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- แถบหัวข้อ (Top Bar)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 14)
TopCorner.Parent = TopBar

local FixTopBar = Instance.new("Frame")
FixTopBar.Size = UDim2.new(1, 0, 0, 10)
FixTopBar.Position = UDim2.new(0, 0, 1, -10)
FixTopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
FixTopBar.BorderSizePixel = 0
FixTopBar.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DELTA HUB | PRO"
Title.TextColor3 = Color3.fromRGB(46, 204, 113)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- ปุ่มกากบาท (Close Button)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -42, 0.5, -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 15
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- ปุ่มย่อหน้าต่าง (-)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
MinimizeBtn.Position = UDim2.new(1, -80, 0.5, -16)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 18
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinimizeBtn

-- Container สำหรับฟังก์ชัน (ScrollingFrame)
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -65)
Container.Position = UDim2.new(0, 10, 0, 58)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.CanvasSize = UDim2.new(0, 0, 0, 0)
Container.ScrollBarThickness = 4
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = Container

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end)

-- ฟังก์ชันสร้างปุ่ม Toggle
local function CreateToggle(name, default, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, 0, 0, 48)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    ToggleBtn.Text = ""
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.Parent = Container

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 10)
    ToggleCorner.Parent = ToggleBtn

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -65, 1, 0)
    Label.Position = UDim2.new(0, 16, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(230, 230, 240)
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleBtn

    local StatusIndicator = Instance.new("Frame")
    StatusIndicator.Size = UDim2.new(0, 26, 0, 26)
    StatusIndicator.Position = UDim2.new(1, -38, 0.5, -13)
    StatusIndicator.BackgroundColor3 = default and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(50, 50, 70)
    StatusIndicator.Parent = ToggleBtn

    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(0, 8)
    IndicatorCorner.Parent = StatusIndicator

    local state = default
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        StatusIndicator.BackgroundColor3 = state and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(50, 50, 70)
        callback(state)
    end)
end

-- เพิ่มฟังก์ชันลงใน UI
CreateToggle("Aimbot (กดคลิกขวาเพื่อล็อคเป้าหมาย)", Settings.Aimbot, function(v) Settings.Aimbot = v end)
CreateToggle("Team Check (ยกเว้นเพื่อนร่วมทีม)", Settings.TeamCheck, function(v) Settings.TeamCheck = v end)
CreateToggle("Visible Check (ไม่ล็อคเป้าหลังกำแพง)", Settings.VisibleCheck, function(v) Settings.VisibleCheck = v end)
CreateToggle("ESP Box (กรอบสีเขียว)", Settings.ESPBox, function(v) Settings.ESPBox = v end)
CreateToggle("ESP Distance (แสดงระยะทาง)", Settings.ESPDistance, function(v) Settings.ESPDistance = v end)
CreateToggle("Wallhack (มองทะลุกำแพง/วัตถุ)", Settings.Wallhack, function(v) Settings.Wallhack = v end)
CreateToggle("Speedhack (วิ่งเร็วพิเศษ)", Settings.Speedhack, function(v) Settings.Speedhack = v end)
CreateToggle("Noclip (เดินทะลุกำแพง/สิ่งกีดขวาง)", Settings.Noclip, function(v) Settings.Noclip = v end)

-- ควบคุม UI
local menuVisible = true
FloatingBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    MainFrame.Visible = menuVisible
end)

local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Container.Visible = not minimized
    MainFrame.Size = minimized and UDim2.new(0, 340, 0, 50) or UDim2.new(0, 340, 0, 420)
    MinimizeBtn.Text = minimized and "+" or "-"
end)

-- ระบบ ESP Cache & Helpers
local ESPCache = {}

local function RemoveESP(player)
    if not ESPCache[player] then return end
    local cache = ESPCache[player]
    if cache.Box then cache.Box:Remove() end
    if cache.DistanceText then cache.DistanceText:Remove() end
    ESPCache[player] = nil
end

local function IsTeammate(player)
    if not Settings.TeamCheck then return false end
    if not LocalPlayer.Team or not player.Team then return false end
    return player.Team == LocalPlayer.Team
end

-- ฟังก์ชันตรวจสอบการมองเห็นแบบแม่นยำ (Advanced Raycast / Multi-Point Check)
local function IsVisible(targetCharacter)
    if not Settings.VisibleCheck then return true end
    
    local localChar = LocalPlayer.Character
    if not localChar then return true end
    
    local head = targetCharacter:FindFirstChild("Head")
    local rootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
    
    if not head or not rootPart then return false end
    
    local checkPoints = {
        head.Position,
        rootPart.Position,
        head.Position + Vector3.new(0, 0.5, 0),
        rootPart.Position + Vector3.new(0, 1, 0)
    }
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {localChar, targetCharacter}
    raycastParams.IgnoreWater = true
    
    for _, targetPos in ipairs(checkPoints) do
        local origin = Camera.CFrame.Position
        local direction = (targetPos - origin)
        local result = Workspace:Raycast(origin, direction, raycastParams)
        
        if not result or (result.Distance >= direction.Magnitude - 0.1) then
            return true
        end
    end
    
    return false
end

-- ระบบ Noclip
local OriginalCanCollide = {}

getgenv().NoclipConnection = RunService.Stepped:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end

    if Settings.Noclip then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if OriginalCanCollide[part] == nil then
                    OriginalCanCollide[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    else
        for part, canCollide in pairs(OriginalCanCollide) do
            if part and part:IsDescendantOf(Workspace) then
                part.CanCollide = canCollide
            end
        end
        table.clear(OriginalCanCollide)
    end
end)

getgenv().CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function()
    table.clear(OriginalCanCollide)
end)

-- ฟังก์ชัน Cleanup
local function Cleanup()
    if getgenv().MainConnection then getgenv().MainConnection:Disconnect() end
    if getgenv().NoclipConnection then getgenv().NoclipConnection:Disconnect() end
    if getgenv().PlayerRemovingConnection then getgenv().PlayerRemovingConnection:Disconnect() end
    if getgenv().CharacterAddedConnection then getgenv().CharacterAddedConnection:Disconnect() end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end

    for part, canCollide in pairs(OriginalCanCollide) do
        if part and part:IsDescendantOf(Workspace) then
            part.CanCollide = canCollide
        end
    end
    table.clear(OriginalCanCollide)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = 0
                end
            end
        end
        RemoveESP(player)
    end

    if FOVCircle then FOVCircle:Remove() end
    if ScreenGui then ScreenGui:Destroy() end

    getgenv().LoadedUI = nil
    print("ทำความสะอาดและปิดสคริปต์เสร็จสิ้น")
end

CloseBtn.MouseButton1Click:Connect(Cleanup)
getgenv().PlayerRemovingConnection = Players.PlayerRemoving:Connect(RemoveESP)

-- ลูปการทำงานหลัก (RenderStepped)
getgenv().MainConnection = RunService.RenderStepped:Connect(function()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")

    -- อัปเดตตำแหน่ง FOV Circle
    if Settings.Aimbot then
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = mousePos
        FOVCircle.Radius = Settings.FOV
        FOVCircle.Visible = Settings.ShowFOV
    else
        FOVCircle.Visible = false
    end

    -- 1. Speedhack
    if humanoid then
        humanoid.WalkSpeed = Settings.Speedhack and Settings.SpeedValue or 16
    end

    -- 2. Wallhack
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local pChar = player.Character
            local isTeamMates = IsTeammate(player)

            for _, part in ipairs(pChar:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = (Settings.Wallhack and not isTeamMates) and 0.5 or 0
                end
            end
        end
    end

    -- 3. ESP Box & Distance (แสดงเฉพาะกรอบสีเขียวและระยะทาง ไม่มีชื่อ)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local pChar = player.Character
            if pChar and pChar:FindFirstChild("HumanoidRootPart") and pChar:FindFirstChild("Humanoid") and pChar.Humanoid.Health > 0 then
                
                if not ESPCache[player] then
                    local box = Drawing.new("Square")
                    box.Visible = false
                    box.Color = Color3.fromRGB(46, 204, 113)
                    box.Thickness = 1.5
                    box.Filled = false

                    local distText = Drawing.new("Text")
                    distText.Visible = false
                    distText.Color = Color3.fromRGB(46, 204, 113)
                    distText.Size = 13
                    distText.Center = true
                    distText.Outline = true

                    ESPCache[player] = {Box = box, DistanceText = distText}
                end

                local cache = ESPCache[player]
                local box = cache.Box
                local distText = cache.DistanceText
                local isTeamMates = IsTeammate(player)

                if Settings.ESPBox and not isTeamMates then
                    local rootPart = pChar.HumanoidRootPart
                    local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

                    if onScreen then
                        local head = pChar:FindFirstChild("Head")
                        local topPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or vector
                        local bottomPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))

                        local height = math.abs(topPos.Y - bottomPos.Y)
                        local width = height / 2

                        box.Size = Vector2.new(width, height)
                        box.Position = Vector2.new(vector.X - width / 2, topPos.Y)
                        box.Visible = true

                        if Settings.ESPDistance then
                            local distance = math.floor((Camera.CFrame.Position - rootPart.Position).Magnitude)
                            distText.Text = "[" .. distance .. "m]"
                            distText.Position = Vector2.new(vector.X, bottomPos.Y + 4)
                            distText.Visible = true
                        else
                            distText.Visible = false
                        end
                    else
                        box.Visible = false
                        distText.Visible = false
                    end
                else
                    box.Visible = false
                    distText.Visible = false
                end
            else
                RemoveESP(player)
            end
        end
    end

    -- 4. Aimbot (ทำงานเมื่อคลิกขวาเมาส์ค้างไว้ + ตรวจสอบการมองเห็นขั้นสูง)
    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = nil
        local shortestDist = Settings.FOV

        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                if IsTeammate(v) then continue end

                local part = v.Character:FindFirstChild(Settings.AimPart)
                if not part then
                    part = v.Character:FindFirstChild("HumanoidRootPart")
                end
                
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        if IsVisible(v.Character) then
                            local mousePos = UserInputService:GetMouseLocation()
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                            if dist < shortestDist then
                                shortestDist = dist
                                target = part
                            end
                        end
                    end
                end
            end
        end

        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)
