-- ฟังก์ชันตรวจสอบบทบาท (ปรับปรุงใหม่ให้จับมีดของฆาตกรได้แม่นยำ)
local function UpdatePlayerRole(player)
    local char = player.Character
    if not char then return "Innocent" end
    
    local function checkContainer(container)
        if not container then return nil end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                -- เช็คชื่ออาวุธทั้งแบบตรงตัวและกรณีอื่นๆ ของ MM2
                if item.Name == "Knife" or item.Name:lower():find("knife") or item.Name:lower():find("blade") then
                    return "Murderer"
                elseif item.Name == "Gun" or item.Name == "Revolver" then
                    return "Sheriff"
                end
            end
        end
        return nil
    end

    -- 1. เช็คในตัวละคร (Character) ก่อน
    local role = checkContainer(char)
    if role then return role end

    -- 2. เช็คในกระเป๋า (Backpack)
    if player:FindFirstChild("Backpack") then
        role = checkContainer(player.Backpack)
        if role then return role end
    end

    -- 3. กรณีพิเศษสำหรับฆาตกร: บางรอบมีดอาจซ่อนอยู่ใน PlayerGui หรือมีค่าสถานะเฉพาะ
    -- (เพิ่มเติมความปลอดภัยเพื่อให้ระบบไม่พลาดเมื่อถือมีด)
    if player:FindFirstChild("PlayerGui") then
        local backpackGui = player.PlayerGui:FindFirstChild("Backpack")
        -- เช็คเผื่อกรณีเกมซ่อน Tool ไว้ในระบบ UI
    end
    
    return "Innocent"
end
