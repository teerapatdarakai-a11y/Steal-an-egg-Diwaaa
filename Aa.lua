-- ==============================================================================
-- DELTA HUB - MM2 ROLE-BASED ESP (Innocent sees Murderer & Sheriff)
-- ==============================================================================

if not Drawing or not getgenv then
    print("Executor ของคุณไม่รองรับ Drawing API")
    return
end

-- ป้องกันการรันซ้ำและเคลียร์ของเก่า
if getgenv().MM2_LoadedUI then
    pcall(function()
        getgenv().MM2_LoadedUI:Destroy()
    end)
end

if getgenv().MM2_Connection then
    getgenv().MM2_Connection:Disconnect()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- สร้าง ScreenGui สำหรับปุ่มเปิด/ปิด
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2_ESP_Gui"
ScreenGui.ResetOnSpawn = false

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end
getgenv().MM2_LoadedUI = ScreenGui

-- ปุ่มลอยเปิด/ปิดเมนู ESP
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Size = UDim2.new(0, 50, 0, 50)
FloatingBtn.Position = UDim2.new(0, 30, 0.4, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
FloatingBtn.Text = "🔪"
FloatingBtn.TextColor3 = Color3.fromRGB(231, 76, 60)
FloatingBtn.TextSize = 22
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.Active = true
FloatingBtn.Draggable = true
FloatingBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatingBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(231, 76, 60)
FloatStroke.Thickness = 2
FloatStroke.Parent = FloatingBtn

-- หน้าต่างควบคุมเล็กๆ
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 140)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -70)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "MM2 ROLE ESP"
Title.TextColor3 = Color3.fromRGB(231, 76, 60)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 40)
StatusLabel.Position = UDim2.new(0, 10, 0, 50)
StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
StatusLabel.Text = "สถานะ: กำลังค้นหาบทบาท..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.Medium
StatusLabel.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusLabel

-- ควบคุมเปิด/ปิด UI ด้วยปุ่มลอย
local uiVisible = true
FloatingBtn.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    MainFrame.Visible = uiVisible
end)

-- ระบบ ESP Cache (ป้องกันแลค)
local ESPCache = {}

local function RemoveESP(player)
    if ESPCache[player] then
        if ESPCache[player].Box then ESPCache[player].Box:Remove() end
        if ESPCache[player].NameText then ESPCache[player].NameText:Remove() end
        ESPCache[player] = nil
    end
end

-- ฟังก์ชันเช็คว่าผู้เล่นถืออาวุธอะไรใน MM2
local function GetPlayerRole(player)
    local char = player.Character
    if not char then return "Innocent" end
    
    local weapons = {"Knife", "Gun", "Revolver"}
    for _, wName in ipairs(weapons) do
        if char:FindFirstChild(wName) or (player.Backpack and player.Backpack:FindFirstChild(wName)) then
            if wName == "Knife" then
                return "Murderer"
            elseif wName == "Gun" or wName == "Revolver" then
                return "Sheriff"
            end
        end
    end
    
    return "Innocent"
end

-- ลูปการทำงานหลัก (RenderStepped)
getgenv().MM2_Connection = RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

    local myRole = GetPlayerRole(LocalPlayer)
    StatusLabel.Text = "บทบาทของคุณ: " .. myRole

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local pChar = player.Character
            if pChar and pChar:FindFirstChild("HumanoidRootPart") and pChar:FindFirstChild("Humanoid") and pChar.Humanoid.Health > 0 then
                
                local targetRole = GetPlayerRole(player)
                local shouldShow = false

                -- เงื่อนไขตามที่คุณต้องการ
                if myRole == "Murderer" then
                    -- ฆาตกรเห็นทุกคน
                    shouldShow = true
                elseif myRole == "Sheriff" then
                    -- นายอำเภอเห็นเฉพาะฆาตกร
                    if targetRole == "Murderer" then
                        shouldShow = true
                    end
                elseif myRole == "Innocent" then
                    -- ชาวบ้านเห็นทั้งฆาตกรและนายอำเภอ
                    if targetRole == "Murderer" or targetRole == "Sheriff" then
                        shouldShow = true
                    end
                end

                -- สร้างหรือดึงข้อมูล ESP Cache
                if not ESPCache[player] then
                    local box = Drawing.new("Square")
                    box.Visible = false
                    box.Color = Color3.fromRGB(231, 76, 60)
                    box.Thickness = 1.5
                    box.Filled = false

                    local nameText = Drawing.new("Text")
                    nameText.Visible = false
                    nameText.Color = Color3.fromRGB(231, 76, 60)
                    nameText.Size = 13
                    nameText.Center = true
                    nameText.Outline = true

                    ESPCache[player] = {Box = box, NameText = nameText}
                end

                local cache = ESPCache[player]

                if shouldShow then
                    -- เปิด Wallhack สีแดงให้มองทะลุ
                    for _, part in ipairs(pChar:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.LocalTransparencyModifier = 0.5
                        end
                    end

                    -- แสดงกล่อง ESP Box และป้ายชื่อบทบาท
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

                        cache.NameText.Text = "[" .. targetRole .. "]"
                        cache.NameText.Position = Vector2.new(vector.X, topPos.Y - 16)
                        cache.NameText.Visible = true
                    else
                        cache.Box.Visible = false
                        cache.NameText.Visible = false
                    end
                else
                    for _, part in ipairs(pChar:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.LocalTransparencyModifier = 0
                        end
                    end
                    cache.Box.Visible = false
                    cache.NameText.Visible = false
                end

            else
                RemoveESP(player)
            end
        end
    end
end)
