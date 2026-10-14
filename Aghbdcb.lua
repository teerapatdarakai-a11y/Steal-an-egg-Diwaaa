-- ==============================================================================
-- DELTA HUB - MM2 RAGE AIMBOT + UI MENU (Instant Headlock)
-- ==============================================================================

if not Drawing or not getgenv then
    print("Executor ของคุณไม่รองรับ Drawing API")
    return
end

-- ป้องกันการรันซ้ำและเคลียร์ของเก่า
if getgenv().MM2_RageUI then
    pcall(function()
        getgenv().MM2_RageUI:Destroy()
    end)
end

if getgenv().MM2_RageConnection then
    getgenv().MM2_RageConnection:Disconnect()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ค่าการตั้งค่า (Settings)
local RageSettings = {
    Enabled = false,           -- ปิดไว้ก่อนเริ่ม ให้กดเปิดจาก UI ได้
    TargetPart = "Head",       -- ล็อกเข้าที่หัว 100%
    WallCheck = true,          -- เช็คกำแพง (ไม่ยิงทะลุกำแพงมั่ว)
    FOV = 600                  -- รัศมีการกวาดเป้ากว้างพิเศษ
}

-- สร้าง ScreenGui สำหรับหน้าต่าง UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2_RageGui"
ScreenGui.ResetOnSpawn = false

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end
getgenv().MM2_RageUI = ScreenGui

-- ปุ่มลอยเปิด/ปิดเมนู (ไอคอนหัวกะโหลก 💀 สายโหด)
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Size = UDim2.new(0, 52, 0, 52)
FloatingBtn.Position = UDim2.new(0, 30, 0.4, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
FloatingBtn.Text = "💀"
FloatingBtn.TextColor3 = Color3.fromRGB(231, 76, 60)
FloatingBtn.TextSize = 24
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.Active = true
FloatingBtn.Draggable = true
FloatingBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatingBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(231, 76, 60)
FloatStroke.Thickness = 2.5
FloatStroke.Parent = FloatingBtn

-- หน้าต่างควบคุมหลัก (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 180)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- หัวข้อเมนู
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "RAGE AIMBOT [HEADLOCK]"
Title.TextColor3 = Color3.fromRGB(231, 76, 60)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- ปุ่มเปิด/ปิด Aimbot
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 45)
ToggleBtn.Position = UDim2.new(0, 10, 0, 45)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
ToggleBtn.Text = "Rage Aimbot: ปิด ❌"
ToggleBtn.TextColor3 = Color3.fromRGB(231, 76, 60)
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function()
    RageSettings.Enabled = not RageSettings.Enabled
    if RageSettings.Enabled then
        ToggleBtn.Text = "Rage Aimbot: เปิด ✅"
        ToggleBtn.TextColor3 = Color3.fromRGB(46, 204, 113)
    else
        ToggleBtn.Text = "Rage Aimbot: ปิด ❌"
        ToggleBtn.TextColor3 = Color3.fromRGB(231, 76, 60)
    end
end)

-- ปุ่มเปิด/ปิด WallCheck
local WallCheckBtn = Instance.new("TextButton")
WallCheckBtn.Size = UDim2.new(1, -20, 0, 45)
WallCheckBtn.Position = UDim2.new(0, 10, 0, 100)
WallCheckBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
WallCheckBtn.Text = "WallCheck: เปิด ✅"
WallCheckBtn.TextColor3 = Color3.fromRGB(46, 204, 113)
WallCheckBtn.TextSize = 14
WallCheckBtn.Font = Enum.Font.GothamBold
WallCheckBtn.Parent = MainFrame

local WallCheckCorner = Instance.new("UICorner")
WallCheckCorner.CornerRadius = UDim.new(0, 8)
WallCheckCorner.Parent = WallCheckBtn

WallCheckBtn.MouseButton1Click:Connect(function()
    RageSettings.WallCheck = not RageSettings.WallCheck
    if RageSettings.WallCheck then
        WallCheckBtn.Text = "WallCheck: เปิด ✅"
        WallCheckBtn.TextColor3 = Color3.fromRGB(46, 204, 113)
    else
        WallCheckBtn.Text = "WallCheck: ปิด ❌ (ทะลุกำแพง)"
        WallCheckBtn.TextColor3 = Color3.fromRGB(231, 76, 60)
    end
end)

-- ควบคุมเปิด/ปิดหน้าต่าง UI ด้วยปุ่มลอยรูปกะโหลก
local uiVisible = true
FloatingBtn.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    MainFrame.Visible = uiVisible
end)

-- ฟังก์ชันเช็คกำแพง (Wallcheck)
local function IsVisible(targetPart)
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("Head") then return false end
    
    local origin = myChar.Head.Position
    local destination = targetPart.Position
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {myChar, targetPart.Parent}
    raycastParams.IgnoreWater = true
    
    local result = Workspace:Raycast(origin, destination - origin, raycastParams)
    if result then
        return false
    else
        return true
    end
end

-- ฟังก์ชันหากลุ่มเป้าหมาย
local function GetRageTarget()
    local target = nil
    local shortestDist = math.huge
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local pChar = player.Character
            local humanoid = pChar:FindFirstChild("Humanoid")
            local targetPart = pChar:FindFirstChild(RageSettings.TargetPart)
            
            if humanoid and humanoid.Health > 0 and targetPart then
                local vector, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    if not RageSettings.WallCheck or IsVisible(targetPart) then
                        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        local distToCenter = (Vector2.new(vector.X, vector.Y) - screenCenter).Magnitude
                        
                        if distToCenter < RageSettings.FOV and distToCenter < shortestDist then
                            shortestDist = distToCenter
                            target = targetPart
                        end
                    end
                end
            end
        end
    end
    return target
end

-- ลูปการทำงาน Aimbot (Instant Snap เข้าหัว)
getgenv().MM2_RageConnection = RunService.RenderStepped:Connect(function()
    if not RageSettings.Enabled then return end
    
    local targetPart = GetRageTarget()
    if targetPart then
        local myChar = LocalPlayer.Character
        local tool = myChar and (myChar:FindFirstChildOfClass("Tool"))
        
        if tool and (tool.Name:lower():find("knife") or tool.Name:lower():find("gun") or tool.Name:lower():find("revolver") or tool.Name:lower():find("blade")) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
        end
    end
end)
