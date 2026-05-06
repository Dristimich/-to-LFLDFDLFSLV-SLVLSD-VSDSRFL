getgenv().AutoFarm = getgenv().AutoFarm or {}
getgenv().AutoFarm.Enabled = true
getgenv().AutoFarm.ClickPosition = getgenv().AutoFarm.ClickPosition or nil

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- ==================== GUI ====================
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 145)
frame.Position = UDim2.new(0.5, -130, 0.08, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 28)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBar.Text = "AutoFarm | Nightmare"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.TextSize = 15
titleBar.Font = Enum.Font.SourceSansBold
titleBar.Parent = frame

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, 0, 0, 18)
credit.Position = UDim2.new(0, 0, 1, -18)
credit.BackgroundTransparency = 1
credit.Text = "by: Dristimich"
credit.TextColor3 = Color3.fromRGB(180, 180, 180)
credit.TextSize = 12
credit.Font = Enum.Font.SourceSans
credit.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 22)
statusLabel.Position = UDim2.new(0, 10, 0, 35)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Статус: Ожидание..."
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.SourceSans
statusLabel.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 26)
toggle.Position = UDim2.new(0, 10, 0, 60)
toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
toggle.Text = "ВКЛЮЧЕНО"
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.TextSize = 14
toggle.Font = Enum.Font.SourceSansBold
toggle.Parent = frame

local calibrateBtn = Instance.new("TextButton")
calibrateBtn.Size = UDim2.new(1, -20, 0, 26)
calibrateBtn.Position = UDim2.new(0, 10, 0, 92)
calibrateBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
calibrateBtn.Text = "Перенастроить клик"
calibrateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
calibrateBtn.TextSize = 13
calibrateBtn.Font = Enum.Font.SourceSansBold
calibrateBtn.Parent = frame

-- ==================== КАЛИБРОВКА ====================
local isCalibrating = false

calibrateBtn.MouseButton1Click:Connect(function()
    if isCalibrating then return end
    isCalibrating = true
    statusLabel.Text = "Кликни на кнопку Start..."

    local connection
    connection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            
            -- Добавляем небольшой оффсет (чтобы точнее попадать)
            getgenv().AutoFarm.ClickPosition = {
                X = input.Position.X + 2,   -- немного правее
                Y = input.Position.Y + 6    -- немного ниже
            }
            
            statusLabel.Text = "Координаты сохранены!"
            print("[AutoFarm] Новые координаты:", getgenv().AutoFarm.ClickPosition)
            
            isCalibrating = false
            connection:Disconnect()
        end
    end)
end)

toggle.MouseButton1Click:Connect(function()
    getgenv().AutoFarm.Enabled = not getgenv().AutoFarm.Enabled
    toggle.Text = getgenv().AutoFarm.Enabled and "ВКЛЮЧЕНО" or "ВЫКЛЮЧЕНО"
    toggle.BackgroundColor3 = getgenv().AutoFarm.Enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

local function updateStatus(text)
    statusLabel.Text = "Статус: " .. text
end

-- ==================== ЗАПУСК ====================
local function tryStartGame()
    updateStatus("Телепортируемся...")
[06.05.2026 16:00] 𝐃𝐫𝐢𝐬𝐭𝐢𝐦𝐢𝐜𝐡: local lifts = Workspace:FindFirstChild("Lifts")
    if lifts then
        local toiletHQ = lifts:FindFirstChild("ToiletHQ")
        if toiletHQ then
            player.Character.HumanoidRootPart.CFrame = toiletHQ:GetPivot() + Vector3.new(0, 9, 0)
        end
    end

    task.wait(3.5)
    updateStatus("Нажимаем кнопку...")

    local clickPos = getgenv().AutoFarm.ClickPosition

    if clickPos then
        for i = 1, 5 do
            VirtualInputManager:SendMouseButtonEvent(clickPos.X, clickPos.Y, 0, true, game, 1)
            task.wait(0.02)
            VirtualInputManager:SendMouseButtonEvent(clickPos.X, clickPos.Y, 0, false, game, 1)
            task.wait(0.08)
        end
    else
        for _, v in ipairs(player.PlayerGui:GetDescendants()) do
            if v:IsA("TextButton") and (v.Text == "Начать" or v.Text == "Start") then
                local pos = v.AbsolutePosition
                local size = v.AbsoluteSize
                local clickX = pos.X + (size.X / 2)
                local clickY = pos.Y + size.Y + 35

                for i = 1, 5 do
                    VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
                    task.wait(0.02)
                    VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)
                    task.wait(0.08)
                end
                break
            end
        end
    end

    updateStatus("Кнопка нажата!")
    task.wait(2)
end

task.spawn(function()
    while true do
        if getgenv().AutoFarm.Enabled then
            tryStartGame()
            task.wait(10)
        else
            updateStatus("Выключено")
            task.wait(3)
        end
    end
end)

print("[AutoFarm] Скрипт запущен (by: Dristimich)")
