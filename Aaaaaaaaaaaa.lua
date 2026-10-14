-- ==============================================================================
-- DELTA HUB - PROFESSIONAL EDITION (Mobile Fixed & Lag-Free + FOV 200)
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
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ค่าการตั้งค่า (Settings)
local Settings = {
    Aimbot = false,
    AimPart = "Head",
    TeamCheck = false,
    VisibleCheck = false,
    FOV = 200,
    ShowFOV = true,
    ESPBox = false,
    ESPDistance = false,
    Wallhack = false,
    Speedhack = false,
    SpeedValue = 30,
    Noclip = false
}

-- สร้าง FOV Circle (Drawing API) ครั้งเดียว
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

-- 1. ไอคอนปุ่มลอย (Floating Button)
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

-- 2. หน้าต่างหลัก (Main Frame)
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

-- ปุ่มปิด
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

-- ปุ่มย่อ
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

-- Container (ScrollingFrame)
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
CreateToggle("Aimbot", Settings.Aimbot, function(v) Settings.Aimbot = v end)
CreateToggle("Show FOV Circle", Settings.ShowFOV, function(v) Settings.ShowFOV = v end)
CreateToggle("Team Check", Settings.TeamCheck, function(v) Settings.TeamCheck = v end)
CreateToggle("Visible Check", Settings.VisibleCheck, function(v) Settings.VisibleCheck = v end)
CreateToggle("ESP Box", Settings.ESPBox, function(v) Settings.ESPBox = v end)
CreateToggle("ESP Distance", Settings.ESPDistance, function(v) Settings.ESPDistance = v end)
CreateToggle("Wallhack", Settings.Wallhack, function(v) Settings.Wallhack = v end)
CreateToggle("Speedhack", Settings.Speedhack, function(v) Settings.Speedhack = v end)
CreateToggle("Noclip", Settings.Noclip, function(v) Settings.Noclip = v end)

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

-- ระบบ ESP Cache (ป้องกันสร้างวัตถุซ้ำซ้อน)
local ESPCache = {}

local function CreateESP(player)
    if ESPCache[player] then return ESPCache[player] end

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

    local cache = {Box = box, DistanceText = distText}
    ESPCache[player] = cache
    return cache
end

local function RemoveESP(player)
    if ESPCache[player] then
        if ESPCache[player].Box then ESPCache[player].Box:Remove() end
        if ESPCache[player].DistanceText then ESPCache[player].DistanceText:Remove() end
        ESPCache[player] = nil
    end
end

local function IsTeammate(player)
    if not Settings.TeamCheck then return false end
    if not LocalPlayer.Team or not player.Team then return false end
    return player.Team == LocalPlayer.Team
end

-- ฟังก์ชันตรวจสอบการมองเห็น (Raycast)
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
        head.Position + Vector3.new(0, 0.5, 0)
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
    print("ทำความสะอาดเรียบร้อย")
end

CloseBtn.MouseButton1Click:Connect(Cleanup)
getgenv().PlayerRemovingConnection = Players.PlayerRemoving:Connect(RemoveESP)

-- ลูปการทำงานหลัก (RenderStepped) สำหรับมือถือโดยเฉพาะ ลื่น ไม่ค้าง และล็อกแรง
getgenv().MainConnection = RunService.RenderStepped:Connect(function()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")

    -- คำนวณกึ่งกลางหน้าจอสำหรับมือถือ และเช็คปุ่มเปิด/ปิด ShowFOV
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    if Settings.ShowFOV then
        FOVCircle.Position = screenCenter
        FOVCircle.Radius = Settings.FOV
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end

    -- 1. Speedhack
    if humanoid then
        humanoid.WalkSpeed = Settings.Speedhack and Settings.SpeedValue or 16
    end

    -- 2. วนลูปจัดการ Wallhack, ESP และ Aimbot พร้อมกันเพื่อความลื่นไหล
    local target = nil
    local shortestDist = Settings.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local pChar = player.Character
            if pChar and pChar:FindFirstChild("HumanoidRootPart") and pChar:FindFirstChild("Humanoid") and pChar.Humanoid.Health > 0 then
                
                local isTeamMates = IsTeammate(player)

                -- Wallhack
                for _, part in ipairs(pChar:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.LocalTransparencyModifier = (Settings.Wallhack and not isTeamMates) and 0.5 or 0
                    end
                end

                -- ESP Box & Distance
                local cache = CreateESP(player)
                if Settings.ESPBox and not isTeamMates then
                    local rootPart = pChar.HumanoidRootPart
                    local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

                    if onScreen then
                        local head = pChar:FindFirstChild("Head")
                        local topPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or vector
                        local bottomPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))

                        local height = math.abs(topPos.Y - bottomPos.Y)
                        local width = height / 2

                        cache.Box.Size = Vector2.new(width, height)
                        cache.Box.Position = Vector2.new(vector.X - width / 2, topPos.Y)
                        cache.Box.Visible = true

                        if Settings.ESPDistance then
                            local distance = math.floor((Camera.CFrame.Position - rootPart.Position).Magnitude)
                            cache.DistanceText.Text = "[" .. distance .. "m]"
                            cache.DistanceText.Position = Vector2.new(vector.X, bottomPos.Y + 4)
                            cache.DistanceText.Visible = true
                        else
                            cache.DistanceText.Visible = false
                        end
                    else
                        cache.Box.Visible = false
                        cache.DistanceText.Visible = false
                    end
                else
                    cache.Box.Visible = false
                    cache.DistanceText.Visible = false
                end

                -- Aimbot สำหรับมือถือ (เช็คระยะจากกึ่งกลางจอ)
                if Settings.Aimbot and not isTeamMates then
                    local aimPart = pChar:FindFirstChild(Settings.AimPart) or pChar:FindFirstChild("HumanoidRootPart")
                    if aimPart then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
                        if onScreen then
                            if IsVisible(pChar) then
                                local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                                if dist < shortestDist then
                                    shortestDist = dist
                                    target = aimPart
                                end
                            end
                        end
                    end
                end

            else
                RemoveESP(player)
            end
        end
    end

    -- ล็อกเป้าหมายทันทีที่เปิด Aimbot บนมือถือ
    if Settings.Aimbot and target then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
    end
end)
