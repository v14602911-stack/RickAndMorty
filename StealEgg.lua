-- =====================================================================
-- SIMPLE SPEED SCRIPT (1 - 5000)
-- =====================================================================
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

-- ===== GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

-- Главная панель
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 170)
frame.Position = UDim2.new(0.5, -140, 0.5, -85)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 200, 255)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
title.Text = "💨 SPEED HACK"
title.TextColor3 = Color3.fromRGB(0, 0, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

-- Отображение текущего значения
local valueLabel = Instance.new("TextLabel")
valueLabel.Size = UDim2.new(1, -20, 0, 30)
valueLabel.Position = UDim2.new(0, 10, 0, 40)
valueLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
valueLabel.Text = "Скорость: 16"
valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
valueLabel.Font = Enum.Font.GothamBold
valueLabel.TextSize = 16
valueLabel.Parent = frame

-- Ползунок (Slider)
local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, -20, 0, 20)
sliderBg.Position = UDim2.new(0, 10, 0, 80)
sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
sliderBg.BorderSizePixel = 0
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

-- Кнопка применить
local applyBtn = Instance.new("TextButton")
applyBtn.Size = UDim2.new(1, -20, 0, 35)
applyBtn.Position = UDim2.new(0, 10, 0, 115)
applyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
applyBtn.Text = "ПРИМЕНИТЬ"
applyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
applyBtn.Font = Enum.Font.GothamBold
applyBtn.TextSize = 16
applyBtn.Parent = frame

-- ===== ЛОГИКА ПОЛЗУНКА =====
local currentSpeed = 16
local dragging = false

local function updateSlider(input)
    local sliderPos = sliderBg.AbsolutePosition.X
    local sliderWidth = sliderBg.AbsoluteSize.X
    local mousePos = input.Position.X
    
    local percent = math.clamp((mousePos - sliderPos) / sliderWidth, 0, 1)
    local value = math.floor(1 + percent * (5000 - 1))
    
    currentSpeed = value
    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    sliderBtn.Position = UDim2.new(percent, -10, 0, 0)
    valueLabel.Text = "Скорость: " .. value
end

sliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

sliderBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

sliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        updateSlider(input)
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ===== ПРИМЕНЕНИЕ СКОРОСТИ =====
applyBtn.MouseButton1Click:Connect(function()
    local currentChar = player.Character
    if currentChar then
        local currentHum = currentChar:FindFirstChild("Humanoid")
        if currentHum then
            currentHum.WalkSpeed = currentSpeed
            print("💨 Скорость установлена: " .. currentSpeed)
        end
    end
end)

-- ===== ПЕРЕПОДКЛЮЧЕНИЕ ПРИ РЕСПАВНЕ =====
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = newChar:WaitForChild("Humanoid")
    task.wait(0.5)
    if hum then
        hum.WalkSpeed = currentSpeed
    end
end)

print("💨 SPEED SCRIPT загружен!")
print("💨 Двигай ползунок от 1 до 5000")
print("💨 Нажми ПРИМЕНИТЬ")
