-- =====================================================================
-- SPEED SCRIPT (1 - 5000) - АНТИ-СБРОС ВЕРСИЯ
-- =====================================================================
local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")

-- ===== GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 200, 255)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
title.Text = "💨 SPEED HACK"
title.TextColor3 = Color3.fromRGB(0, 0, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

local valueLabel = Instance.new("TextLabel")
valueLabel.Size = UDim2.new(1, -20, 0, 30)
valueLabel.Position = UDim2.new(0, 10, 0, 35)
valueLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
valueLabel.Text = "Скорость: 16"
valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
valueLabel.Font = Enum.Font.GothamBold
valueLabel.TextSize = 16
valueLabel.Parent = frame

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, -20, 0, 20)
sliderBg.Position = UDim2.new(0, 10, 0, 75)
sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
sliderBg.Parent = frame

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg

local sliderBtn = Instance.new("TextButton")
sliderBtn.Size = UDim2.new(0, 20, 0, 20)
sliderBtn.Position = UDim2.new(0, -10, 0, 0)
sliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderBtn.Text = ""
sliderBtn.Parent = sliderBg

local applyBtn = Instance.new("TextButton")
applyBtn.Size = UDim2.new(1, -20, 0, 35)
applyBtn.Position = UDim2.new(0, 10, 0, 110)
applyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
applyBtn.Text = "ПРИМЕНИТЬ"
applyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
applyBtn.Font = Enum.Font.GothamBold
applyBtn.TextSize = 16
applyBtn.Parent = frame

local presetsFrame = Instance.new("Frame")
presetsFrame.Size = UDim2.new(1, -20, 0, 30)
presetsFrame.Position = UDim2.new(0, 10, 0, 155)
presetsFrame.BackgroundTransparency = 1
presetsFrame.Parent = frame

local currentSpeed = 16
local enabled = false

local function updateSliderVisual()
    local percent = (currentSpeed - 1) / 4999
    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    sliderBtn.Position = UDim2.new(percent, -10, 0, 0)
    valueLabel.Text = "Скорость: " .. currentSpeed
end

local function createPreset(text, x, speed)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 1, 0)
    btn.Position = UDim2.new(x, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = presetsFrame
    btn.MouseButton1Click:Connect(function()
        currentSpeed = speed
        updateSliderVisual()
    end)
end

createPreset("50", 0, 50)
createPreset("100", 0.18, 100)
createPreset("200", 0.36, 200)
createPreset("500", 0.54, 500)
createPreset("1000", 0.72, 1000)
createPreset("5000", 0.9, 5000)

-- ===== ЛОГИКА ПОЛЗУНКА =====
local dragging = false

local function updateSlider(input)
    local sliderPos = sliderBg.AbsolutePosition.X
    local sliderWidth = sliderBg.AbsoluteSize.X
    local mousePos = input.Position.X
    local percent = math.clamp((mousePos - sliderPos) / sliderWidth, 0, 1)
    currentSpeed = math.floor(1 + percent * 4999)
    updateSliderVisual()
end

sliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)
sliderBtn.InputChanged:Connect(function(input)
    if dragging then updateSlider(input) end
end)
sliderBtn.InputEnded:Connect(function()
    dragging = false
end)

sliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        updateSlider(input)
    end
end)
sliderBg.InputChanged:Connect(function(input)
    if dragging then updateSlider(input) end
end)
sliderBg.InputEnded:Connect(function()
    dragging = false
end)

-- ===== АНТИ-СБРОС: ПЕРЕХВАТ ИЗМЕНЕНИЙ WalkSpeed =====
local speedConnection = nil

local function activateSpeed()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    
    -- Отключаем старый перехват если был
    if speedConnection then speedConnection:Disconnect() end
    
    -- Применяем сразу
    hum.WalkSpeed = currentSpeed
    hum.JumpPower = 50
    
    -- Перехватываем любые попытки игры сбросить WalkSpeed
    speedConnection = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if hum.WalkSpeed ~= currentSpeed then
            hum.WalkSpeed = currentSpeed
        end
    end)
    
    -- Дополнительно — цикл на каждый кадр
    speedConnection = rs.RenderStepped:Connect(function()
        if hum and hum.Parent and hum.WalkSpeed ~= currentSpeed then
            hum.WalkSpeed = currentSpeed
        end
    end)
    
    enabled = true
    print("💨 Скорость активирована: " .. currentSpeed)
end

applyBtn.MouseButton1Click:Connect(function()
    print("🔘 Кнопка ПРИМЕНИТЬ нажата! Скорость = " .. currentSpeed)
    activateSpeed()
end)

-- ===== ПЕРЕПОДКЛЮЧЕНИЕ ПРИ СМЕРТИ =====
player.CharacterAdded:Connect(function(newChar)
    task.wait(1)
    if enabled then
        activateSpeed()
    end
end)

print("💨 SPEED SCRIPT загружен!")
print("💨 Двигай ползунок, жми ПРИМЕНИТЬ")
