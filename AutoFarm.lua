local a = game:GetService("Players")
local b = game:GetService("Workspace")
local c = game:GetService("VirtualInputManager")
local d = game:GetService("UserInputService")
local e = a.LocalPlayer
local f = "AutoFarm_Positions.txt"

getgenv().AutoFarm = getgenv().AutoFarm or {}
getgenv().AutoFarm.Enabled = true
getgenv().AutoFarm.StartPos = getgenv().AutoFarm.StartPos or nil
getgenv().AutoFarm.SkipPos = getgenv().AutoFarm.SkipPos or nil

local function g()
    if isfile and readfile and isfile(f) then
        local h, i = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(f))
        end)
        if h and i then
            getgenv().AutoFarm.StartPos = i.StartPos
            getgenv().AutoFarm.SkipPos = i.SkipPos
        end
    end
end

local function j()
    local k = {
        StartPos = getgenv().AutoFarm.StartPos,
        SkipPos = getgenv().AutoFarm.SkipPos
    }
    if writefile then
        writefile(f, game:GetService("HttpService"):JSONEncode(k))
    end
end

g()

local l = Instance.new("ScreenGui")
l.Name = "AutoFarmGUI"
l.ResetOnSpawn = false
l.Parent = e:WaitForChild("PlayerGui")

local m = Instance.new("Frame")
m.Size = UDim2.new(0, 260, 0, 175)
m.Position = UDim2.new(0.5, -130, 0.08, 0)
m.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
m.Active = true
m.Draggable = true
m.Parent = l

local n = Instance.new("TextLabel")
n.Size = UDim2.new(1, 0, 0, 28)
n.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
n.Text = "AutoFarm | Nightmare"
n.TextColor3 = Color3.fromRGB(255, 255, 255)
n.TextSize = 15
n.Font = Enum.Font.SourceSansBold
n.Parent = m

local o = Instance.new("TextLabel")
o.Size = UDim2.new(1, 0, 0, 18)
o.Position = UDim2.new(0, 0, 1, -18)
o.BackgroundTransparency = 1
o.Text = "by: Dristimich"
o.TextColor3 = Color3.fromRGB(180, 180, 180)
o.TextSize = 12
o.Font = Enum.Font.SourceSans
o.Parent = m

local p = Instance.new("TextLabel")
p.Size = UDim2.new(1, -20, 0, 22)
p.Position = UDim2.new(0, 10, 0, 35)
p.BackgroundTransparency = 1
p.Text = "Статус: Ожидание..."
p.TextColor3 = Color3.fromRGB(200, 200, 200)
p.TextSize = 13
p.Font = Enum.Font.SourceSans
p.Parent = m

local q = Instance.new("TextButton")
q.Size = UDim2.new(1, -20, 0, 24)
q.Position = UDim2.new(0, 10, 0, 60)
q.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
q.Text = "ВКЛЮЧЕНО"
q.TextColor3 = Color3.fromRGB(255, 255, 255)
q.TextSize = 14
q.Font = Enum.Font.SourceSansBold
q.Parent = m

local r = Instance.new("TextButton")
r.Size = UDim2.new(1, -20, 0, 24)
r.Position = UDim2.new(0, 10, 0, 88)
r.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
r.Text = "Задать координаты Start"
r.TextColor3 = Color3.fromRGB(255, 255, 255)
r.TextSize = 13
r.Font = Enum.Font.SourceSansBold
r.Parent = m

local s = Instance.new("TextButton")
s.Size = UDim2.new(1, -20, 0, 24)
s.Position = UDim2.new(0, 10, 0, 116)
s.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
s.Text = "Задать координаты Skip"
s.TextColor3 = Color3.fromRGB(255, 255, 255)
s.TextSize = 13
s.Font = Enum.Font.SourceSansBold
s.Parent = m

local function t(u)
    p.Text = "Кликни на кнопку " .. u .. "..."
    local v
    v = d.InputBegan:Connect(function(w)
        if w.UserInputType == Enum.UserInputType.MouseButton1 or w.UserInputType == Enum.UserInputType.Touch then
            if u == "Start" then
                getgenv().AutoFarm.StartPos = {X = w.Position.X, Y = w.Position.Y}
            else
                getgenv().AutoFarm.SkipPos = {X = w.Position.X, Y = w.Position.Y}
            end
            j()
            p.Text = u .. " координаты сохранены!"
            v:Disconnect()
        end
    end)
end

r.MouseButton1Click:Connect(function() t("Start") end)
s.MouseButton1Click:Connect(function() t("Skip") end)

q.MouseButton1Click:Connect(function()
    getgenv().AutoFarm.Enabled = not getgenv().AutoFarm.Enabled
    q.Text = getgenv().AutoFarm.Enabled and "ВКЛЮЧЕНО" or "ВЫКЛЮЧЕНО"
    q.BackgroundColor3 = getgenv().AutoFarm.Enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

local function x(y)
    p.Text = "Статус: " .. y
end

local function z()
    local A = b:FindFirstChild("Lifts")
    return A and A:FindFirstChild("ToiletHQ") ~= nil
end

local function B(C)
    if C then
        c:SendMouseButtonEvent(C.X, C.Y, 0, true, game, 1)
        task.wait(0.03)
        c:SendMouseButtonEvent(C.X, C.Y, 0, false, game, 1)
    end
end

task.spawn(function()
    while true do
        if getgenv().AutoFarm.Enabled then
            if z() then
                x("Лобби - телепорт + Start")
                local D = b:FindFirstChild("Lifts")
                if D then
                    local E = {}
                    for _, F in ipairs(D:GetChildren()) do
                        if F.Name == "ToiletHQ" then
                            table.insert(E, F)
                        end
                    end
                    if #E > 0 then
                        local G = 1
                        e.Character.HumanoidRootPart.CFrame = E[G]:GetPivot() + Vector3.new(0, 9, 0)
                        task.wait(3)
                        B(getgenv().AutoFarm.StartPos)
                        local H = tick()
                        while z() and (tick() - H) < 60 do
                            task.wait(1)
                        end
                        if z() and #E > 1 then
                            G = G % #E + 1
                            x("Пробуем другой ToiletHQ...")
                            e.Character.HumanoidRootPart.CFrame = E[G]:GetPivot() + Vector3.new(0, 9, 0)
                            task.wait(3)
                            B(getgenv().AutoFarm.StartPos)
                        end
                    end
                end
                task.wait(8)
            else
                x("В катке - жмём Skip")
                B(getgenv().AutoFarm.SkipPos)
                task.wait(1)
            end
        else
            x("Выключено")
            task.wait(3)
        end
    end
end)

print("[AutoFarm] Скрипт запущен (by: Dristimich)")
