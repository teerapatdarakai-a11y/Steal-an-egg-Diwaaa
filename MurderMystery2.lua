-- ==============================================================================
-- DELTA HUB - MM2 ULTIMATE ESP + NOCLIP + PINK DROPPED GUN ESP + FAST AUTO COIN (NOCLIP AUTO)
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

if getgenv().MM2_NoclipConnection then
    getgenv().MM2_NoclipConnection:Disconnect()
end

if getgenv().MM2_CoinConnection then
    getgenv().MM2_CoinConnection:Disconnect()
end

if getgenv().MM2_PlayerRemoving then
    getgenv().MM2_PlayerRemoving:Disconnect()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ค่าการตั้งค่า (Settings)
local Settings = {
    Noclip = false,
    AutoCoin = false,
    CoinSpeed = 25 -- ⚙️ ปรับเพิ่มความเร็วเป็น 38 (ไวขึ้นอย่างเห็นได้ชัดและไม่ช้า)
}

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
FloatingBtn.Size = UDim2.new(0, 52, 0, 52)
FloatingBtn.Position = UDim2.new(0, 30, 0.4, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
FloatingBtn.Text = "🔪"
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

-- หน้าต่างควบคุมสถานะ
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 245)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -122)
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
Title.Text = "MM2 ULTIMATE HUB"
Title.TextColor3 = Color3.fromRGB(231, 76, 60)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 35)
StatusLabel.Position = UDim2.new(0, 10, 0, 40)
StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
StatusLabel.Text = "บทบาท: กำลังตรวจสอบ..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusLabel

-- ปุ่มเปิด/ปิด Noclip
local NoclipBtn = Instance.new("TextButton")
NoclipBtn.Size = UDim2.new(1, -20, 0, 45)
NoclipBtn.Position = UDim2.new(0, 10, 0, 85)
NoclipBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
NoclipBtn.Text = "Noclip: ปิด ❌"
NoclipBtn.TextColor3 = Color3.fromRGB(231, 76, 60)
NoclipBtn.TextSize = 14
NoclipBtn.Font = Enum.Font.GothamBold
NoclipBtn.Parent = MainFrame

local NoclipCorner = Instance.new("UICorner")
NoclipCorner.CornerRadius = UDim.new(0, 8)
NoclipCorner.Parent = NoclipBtn

NoclipBtn.MouseButton1Click:Connect(function()
    Settings.Noclip = not Settings.Noclip
    if Settings.Noclip then
        NoclipBtn.Text = "Noclip: เปิด ✅"
        NoclipBtn.TextColor3 = Color3.fromRGB(46, 204, 113)
    else
        NoclipBtn.Text = "Noclip: ปิด ❌"
        NoclipBtn.TextColor3 = Color3.fromRGB(231, 76, 60)
    end
end)

-- ปุ่มเปิด/ปิด Auto Coin
local CoinBtn = Instance.new("TextButton")
CoinBtn.Size = UDim2.new(1, -20, 0, 45)
CoinBtn.Position = UDim2.new(0, 10, 0, 140)
CoinBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
CoinBtn.Text = "Auto Coin: ปิด ❌"
CoinBtn.TextColor3 = Color3.fromRGB(231, 76, 60)
CoinBtn.TextSize = 14
CoinBtn.Font = Enum.Font.GothamBold
CoinBtn.Parent = MainFrame

local CoinCorner = Instance.new("UICorner")
CoinCorner.CornerRadius = UDim.new(0, 8)
CoinCorner.Parent = CoinBtn

CoinBtn.MouseButton1Click:Connect(function()
    Settings.AutoCoin = not Settings.AutoCoin
    if Settings.AutoCoin then
        CoinBtn.Text = "Auto Coin: เปิด ✅"
        CoinBtn.TextColor3 = Color3.fromRGB(46, 204, 113)
    else
        CoinBtn.Text = "Auto Coin: ปิด ❌"
        CoinBtn.TextColor3 = Color3.fromRGB(231, 76, 60)
    end
end)

-- ควบคุมเปิด/ปิด UI ด้วยปุ่มลอย
local uiVisible = true
FloatingBtn.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    MainFrame.Visible = uiVisible
end)

-- ระบบแคชบทบาทผู้เล่นและ ESP
local RoleCache = {}
local ESPCache = {}
local GunCache = {}

local function RemoveESP(player)
    if ESPCache[player] then
        if ESPCache[player].Box then ESPCache[player].Box:Remove() end
        if ESPCache[player].NameText then ESPCache[player].NameText:Remove() end
        ESPCache[player] = nil
    end
    RoleCache[player] = nil
end

local function RemoveGunESP(gun)
    if GunCache[gun] then
        if GunCache[gun].Box then GunCache[gun].Box:Remove() end
        if GunCache[gun].Text then GunCache[gun].Text:Remove() end
        GunCache[gun] = nil
    end
end

-- ฟังก์ชันตรวจสอบบทบาท
local function UpdatePlayerRole(player)
    local char = player.Character
    if not char then return "Innocent" end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return "Innocent" end

    local function checkContainer(container)
        if not container then return nil end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                local itemName = item.Name:lower()
                if itemName == "knife" or itemName:find("knife") or itemName:find("blade") then
                    return "Murderer"
                elseif itemName == "gun" or itemName == "revolver" then
                    return "Sheriff"
                end
            end
        end
        return nil
    end

    local role = checkContainer(char)
    if role then return role end

    if player:FindFirstChild("Backpack") then
        role = checkContainer(player.Backpack)
        if role then return role end
    end
    
    return "Innocent"
end

-- ผูก Event ติดตามผู้เล่น
local function SetupPlayerTracking(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        RoleCache[player] = UpdatePlayerRole(player)
        
        char.ChildAdded:Connect(function()
            RoleCache[player] = UpdatePlayerRole(player)
        end)
        char.ChildRemoved:Connect(function()
            task.wait(0.1)
            RoleCache[player] = UpdatePlayerRole(player)
        end)

        task.wait(0.2)
        if player:FindFirstChild("Backpack") then
            player.Backpack.ChildAdded:Connect(function()
                RoleCache[player] = UpdatePlayerRole(player)
            end)
            player.Backpack.ChildRemoved:Connect(function()
                task.wait(0.1)
                RoleCache[player] = UpdatePlayerRole(player)
            end)
        end
    end)
    
    if player.Character then
        RoleCache[player] = UpdatePlayerRole(player)
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    SetupPlayerTracking(p)
end

Players.PlayerAdded:Connect(SetupPlayerTracking)
getgenv().MM2_PlayerRemoving = Players.PlayerRemoving:Connect(RemoveESP)

if LocalPlayer.Character then
    RoleCache[LocalPlayer] = UpdatePlayerRole(LocalPlayer)
end

-- ระบบ Noclip (ปรับให้เปิดทะลุตัวอัตโนมัติเมื่อเปิด Noclip หรือ Auto Coin)
local OriginalCanCollide = {}
getgenv().MM2_NoclipConnection = RunService.Stepped:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end

    -- ทำงานเมื่อกดเปิด Noclip หรือเปิดใช้งาน Auto Coin
    if Settings.Noclip or Settings.AutoCoin then
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

-- ==============================================================================
-- ระบบ AUTO COIN แบบนุ่มนวลและรวดเร็ว (ความเร็ว 38 + ทะลุสิ่งกีดขวาง)
-- ==============================================================================
local processedCoins = {}
local isTweening = false
local currentTween = nil

LocalPlayer.CharacterAdded:Connect(function(newChar)
    table.clear(processedCoins)
    if currentTween then
        currentTween:Cancel()
    end
    isTweening = false
end)

getgenv().MM2_CoinConnection = RunService.Heartbeat:Connect(function()
    if not Settings.AutoCoin or isTweening then return end

    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or humanoid.Health <= 0 or not hrp then return end

    local coinContainer = Workspace:FindFirstChild("Normal") or Workspace:FindFirstChild("CoinContainer")
    if not coinContainer then
        for _, v in ipairs(Workspace:GetChildren()) do
            if v:FindFirstChild("CoinContainer") then
                coinContainer = v.CoinContainer
                break
            end
        end
    end

    if coinContainer then
        local coinChildren = coinContainer:GetChildren()
        
        if #coinChildren == 0 then
            table.clear(processedCoins)
            return
        end

        for _, coin in ipairs(coinChildren) do
            if (coin.Name == "Coin" or coin:FindFirstChild("CoinVisual")) and not processedCoins[coin] then
                local coinPart = coin:IsA("BasePart") and coin or coin:FindFirstChildWhichIsA("BasePart")
                if coinPart then
                    processedCoins[coin] = true
                    isTweening = true
                    
                    -- คำนวณระยะทางและใช้ความเร็วระดับ 38
                    local distance = (hrp.Position - coinPart.Position).Magnitude
                    local duration = distance / Settings.CoinSpeed
                    
                    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
                    currentTween = TweenService:Create(hrp, tweenInfo, {CFrame = coinPart.CFrame})
                    currentTween:Play()
                    
                    currentTween.Completed:Connect(function()
                        isTweening = false
                    end)

                    coin.AncestryChanged:Connect(function(_, parent)
                        if not parent then
                            processedCoins[coin] = nil
                        end
                    end)
                    break
                end
            end
        end
    end
end)

-- ตัวแปรควบคุมความถี่ (Throttling)
local lastUpdate = 0
local updateInterval = 0.2

-- ลูปการทำงานหลัก (RenderStepped)
getgenv().MM2_Connection = RunService.RenderStepped:Connect(function()
    local tickTime = tick()
    
    if tickTime - lastUpdate >= updateInterval then
        lastUpdate = tickTime
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                RoleCache[player] = UpdatePlayerRole(player)
            end
        end
    end

    local myRole = RoleCache[LocalPlayer] or UpdatePlayerRole(LocalPlayer)
    StatusLabel.Text = "บทบาทของคุณ: " .. myRole

    -- 1. จัดการ ESP ผู้เล่น
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local pChar = player.Character
            if pChar and pChar:FindFirstChild("HumanoidRootPart") and pChar:FindFirstChild("Humanoid") and pChar.Humanoid.Health > 0 then
                
                local targetRole = RoleCache[player] or "Innocent"
                local showBox = false
                local boxColor = Color3.fromRGB(231, 76, 60)

                if myRole == "Innocent" then
                    if targetRole == "Murderer" then
                        showBox = true
                        boxColor = Color3.fromRGB(231, 76, 60)
                    elseif targetRole == "Sheriff" then
                        showBox = true
                        boxColor = Color3.fromRGB(52, 152, 219)
                    end
                elseif myRole == "Murderer" then
                    if targetRole == "Sheriff" then
                        showBox = true
                        boxColor = Color3.fromRGB(52, 152, 219)
                    elseif targetRole == "Innocent" then
                        showBox = true
                        boxColor = Color3.fromRGB(231, 76, 60)
                    end
                elseif myRole == "Sheriff" then
                    if targetRole == "Murderer" then
                        showBox = true
                        boxColor = Color3.fromRGB(231, 76, 60)
                    end
                end

                if not ESPCache[player] then
                    local box = Drawing.new("Square")
                    box.Visible = false
                    box.Thickness = 1.5
                    box.Filled = false

                    local nameText = Drawing.new("Text")
                    nameText.Visible = false
                    nameText.Size = 13
                    nameText.Center = true
                    nameText.Outline = true

                    ESPCache[player] = {Box = box, NameText = nameText}
                end

                local cache = ESPCache[player]

                if showBox then
                    for _, part in ipairs(pChar:GetDescendants()) do
                        if part:IsA("BasePart") and part.LocalTransparencyModifier ~= 0.5 then
                            part.LocalTransparencyModifier = 0.5
                        end
                    end

                    cache.Box.Color = boxColor
                    cache.NameText.Color = boxColor

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
                        if part:IsA("BasePart") and part.LocalTransparencyModifier ~= 0 then
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

    -- 2. จัดการ Dropped Gun ESP (ปืนที่ตกพื้น สีชมพู)
    local activeGuns = {}
    
    for _, obj in ipairs(Workspace:GetChildren()) do
        local objName = obj.Name:lower()
        if objName == "gundrop" or objName == "gun" or objName:find("gun") then
            if obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Tool") then
                activeGuns[obj] = true
                
                if not GunCache[obj] then
                    local box = Drawing.new("Square")
                    box.Visible = false
                    box.Color = Color3.fromRGB(255, 105, 180) -- สีชมพู (Pink)
                    box.Thickness = 1.5
                    box.Filled = false

                    local text = Drawing.new("Text")
                    text.Visible = false
                    text.Color = Color3.fromRGB(255, 105, 180) -- สีชมพู
                    text.Size = 13
                    text.Center = true
                    text.Outline = true
                    text.Text = "[Dropped Gun]"

                    GunCache[obj] = {Box = box, Text = text}
                end

                local gunCache = GunCache[obj]
                local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or (obj:IsA("Tool") and obj:FindFirstChild("Handle") or obj)
                
                if targetPart and targetPart:IsA("BasePart") then
                    local vector, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        gunCache.Box.Size = Vector2.new(22, 22)
                        gunCache.Box.Position = Vector2.new(vector.X - 11, vector.Y - 11)
                        gunCache.Box.Visible = true

                        gunCache.Text.Position = Vector2.new(vector.X, vector.Y - 26)
                        gunCache.Text.Visible = true
                    else
                        gunCache.Box.Visible = false
                        gunCache.Text.Visible = false
                    end
                end
            end
        end
    end

    -- ลบแคชปืนที่ถูกเก็บหรือหายไป
    for gun, _ in pairs(GunCache) do
        if not activeGuns[gun] or not gun.Parent then
            RemoveGunESP(gun)
        end
    end
end)
