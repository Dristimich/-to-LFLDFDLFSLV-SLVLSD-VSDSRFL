getgenv().AutoFarm = getgenv().AutoFarm or {}
getgenv().AutoFarm.Enabled = true
getgenv().AutoFarm.StartPos = getgenv().AutoFarm.StartPos or nil
getgenv().AutoFarm.SkipPos = getgenv().AutoFarm.SkipPos or nil

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local fileName = "AutoFarm_Positions.txt"

-- Загрузка координат
local function loadPositions()
    if isfile and readfile and isfile(fileName) then
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(fileName))
        end)
        if success and data then
            getgenv().AutoFarm.StartPos = data.StartPos
            getgenv().AutoFarm.SkipPos = data.SkipPos
        end
    end
end

local function savePositions()
    local data = {
        StartPos = getgenv().AutoFarm.StartPos,
        SkipPos = getgenv().AutoFarm.SkipPos
    }
    if writefile then
        writefile(fileName, game:GetService("HttpService"):JSONEncode(data))
    end
end

loadPositions()

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 175)
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
toggle.Size = UDim2.new(1, -20, 0, 24)
toggle.Position = UDim2.new(0, 10, 0, 60)
toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
toggle.Text = "ВКЛЮЧЕНО"
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.TextSize = 14
toggle.Font = Enum.Font.SourceSansBold
toggle.Parent = frame

local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(1, -20, 0, 24)
startBtn.Position = UDim2.new(0, 10, 0, 88)
startBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
startBtn.Text = "Задать координаты Start"
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.TextSize = 13
startBtn.Font = Enum.Font.SourceSansBold
startBtn.Parent = frame

local skipBtn = Instance.new("TextButton")
skipBtn.Size = UDim2.new(1, -20, 0, 24)
skipBtn.Position = UDim2.new(0, 10, 0, 116)
skipBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
skipBtn.Text = "Задать координаты Skip"
skipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
skipBtn.TextSize = 13
skipBtn.Font = Enum.Font.SourceSansBold
skipBtn.Parent = frame

-- Калибровка
local function calibrate(name)
    statusLabel.Text = "Кликни на кнопку " .. name .. "..."
    local connection
    connection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if name == "Start" then
                getgenv().AutoFarm.StartPos = {X = input.Position.X, Y = input.Position.Y}
            else
                getgenv().AutoFarm.SkipPos = {X = input.Position.X, Y = input.Position.Y}
            end
            savePositions()
            statusLabel.Text = name .. " координаты сохранены!"
            connection:Disconnect()
        end
    end)
end

startBtn.MouseButton1Click:Connect(function()
    calibrate("Start")
end)

skipBtn.MouseButton1Click:Connect(function()
    calibrate("Skip")
end)

toggle.MouseButton1Click:Connect(function()
    getgenv().AutoFarm.Enabled = not getgenv().AutoFarm.Enabled
    toggle.Text = getgenv().AutoFarm.Enabled and "ВКЛЮЧЕНО" or "ВЫКЛЮЧЕНО"
    toggle.BackgroundColor3 = getgenv().AutoFarm.Enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

local function updateStatus(text)
    statusLabel.Text = "Статус: " .. text
end

local function isInLobby()
    local lifts = Workspace:FindFirstChild("Lifts")
    return lifts and lifts:FindFirstChild("ToiletHQ") ~= nil
end

local function click(pos)
    if pos then
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
        task.wait(0.03)
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
    end
end
-- ==================== ГЛАВНЫЙ ЦИКЛ С АНТИ-ЗАВИСАНИЕМ ====================
task.spawn(function()
    while true do
        if getgenv().AutoFarm.Enabled then
            if isInLobby() then
                updateStatus("Лобби - телепорт + Start")
                
                local lifts = Workspace:FindFirstChild("Lifts")
                if lifts then
                    local allHQ = {}
                    for _, obj in ipairs(lifts:GetChildren()) do
                        if obj.Name == "ToiletHQ" then
                            table.insert(allHQ, obj)
                        end
                    end
                    
                    if #allHQ > 0 then
                        local index = 1
                        
                        -- Телепорт в первый ToiletHQ
                        player.Character.HumanoidRootPart.CFrame = allHQ[index]:GetPivot() + Vector3.new(0, 9, 0)
                        task.wait(3)
                        click(getgenv().AutoFarm.StartPos)
                        
                        local startTime = tick()
                        
                        -- Ждём 60 секунд
                        while isInLobby() and (tick() - startTime) < 60 do
                            task.wait(1)
                        end
                        
                        -- Если за 60 секунд не ушли — переключаемся на следующий ToiletHQ
                        if isInLobby() and #allHQ > 1 then
                            index = index % #allHQ + 1
                            updateStatus("Пробуем другой ToiletHQ...")
                            
                            player.Character.HumanoidRootPart.CFrame = allHQ[index]:GetPivot() + Vector3.new(0, 9, 0)
                            task.wait(3)
                            click(getgenv().AutoFarm.StartPos)
                        end
                    end
                end
                
                task.wait(8)
            else
                updateStatus("В катке - жмём Skip")
                click(getgenv().AutoFarm.SkipPos)
                task.wait(1)
            end
        else
            updateStatus("Выключено")
            task.wait(3)
        end
    end
end)

print("[AutoFarm] Скрипт запущен (by: Dristimich)") 
