-- Mobile UI: Sequential Player Teleport with Live Speed Scaler
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local isLooping = false
local tpDelay = 1.0 -- Default starting delay in seconds
local minDelay = 0.1 -- Super fast (almost instant)
local maxDelay = 5.0 -- Slower (5 seconds per player)

-- 1. Create Core Screen GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileLoopUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Panel Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 120)
MainFrame.Position = UDim2.new(0.5, -130, 0.3, 0) -- Centered slightly lower
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Drag panel anywhere on mobile
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Interval Display Label
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, 0, 0, 30)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Font = Enum.Font.SourceSansBold
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 15
SpeedLabel.Text = "Teleport Delay: " .. string.format("%.1f", tpDelay) .. "s"
SpeedLabel.Parent = MainFrame

-- 2. Slider Track (The line)
local SliderTrack = Instance.new("Frame")
SliderTrack.Name = "SliderTrack"
SliderTrack.Size = UDim2.new(0, 200, 0, 6)
SliderTrack.Position = UDim2.new(0.5, -100, 0.40, 0)
SliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SliderTrack.BorderSizePixel = 0
SliderTrack.Parent = MainFrame

-- Slider Fill Line
local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.2, 0, 1, 0) -- Starting visual position
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderTrack

-- Slider Handle (The draggable button)
local SliderHandle = Instance.new("TextButton")
SliderHandle.Name = "SliderHandle"
SliderHandle.Size = UDim2.new(0, 16, 0, 16)
SliderHandle.Position = UDim2.new(0.2, -8, 0.5, -8)
SliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderHandle.BorderSizePixel = 0
SliderHandle.Text = ""
SliderHandle.Parent = SliderTrack

local HandleCorner = Instance.new("UICorner")
HandleCorner.CornerRadius = UDim.new(1, 0)
HandleCorner.Parent = SliderHandle

-- 3. Loop Activation Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 220, 0, 35)
ToggleButton.Position = UDim2.new(0.5, -110, 0.65, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50) -- Red initially
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16
ToggleButton.Text = "START TP LOOP"
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 5)
ButtonCorner.Parent = ToggleButton

-- 4. Sequential Teleport Loop Logic
local function runTeleportLoop()
    while isLooping do
        local allPlayers = Players:GetPlayers()
        local tpExecuted = false

        for _, targetPlayer in ipairs(allPlayers) do
            if not isLooping then break end
            
            if targetPlayer ~= LocalPlayer then
                local myChar = LocalPlayer.Character
                local targetChar = targetPlayer.Character
                
                if myChar and targetChar then
                    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
                    
                    if myRoot and targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                        -- Snap directly onto the target player's position
                        myRoot.CFrame = targetRoot.CFrame
                        tpExecuted = true
                        
                        -- Uses the live value from your slider layout
                        task.wait(tpDelay)
                    end
                end
            end
        end
        
        -- If alone or nobody is alive, cycle down briefly before retrying
        if not tpExecuted then
            task.wait(0.5)
        end
    end
end

-- Toggle click event
ToggleButton.MouseButton1Click:Connect(function()
    isLooping = not isLooping
    if isLooping then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 220, 100) -- Green
        ToggleButton.Text = "STOP TP LOOP"
        task.spawn(runTeleportLoop)
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50) -- Red
        ToggleButton.Text = "START TP LOOP"
    end
end)

-- 5. Drag Calculation for Speed Bar
local dragging = false

SliderHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mousePos = input.Position.X
        local trackLeft = SliderTrack.AbsolutePosition.X
        local trackWidth = SliderTrack.AbsoluteSize.X
        
        local percentage = math.clamp((mousePos - trackLeft) / trackWidth, 0, 1)
        
        SliderHandle.Position = UDim2.new(percentage, -8, 0.5, -8)
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        
        -- Calculates speed inverted: left side is fast (0.1s), right side is slow (5s)
        tpDelay = minDelay + (percentage * (maxDelay - minDelay))
        SpeedLabel.Text = "Teleport Delay: " .. string.format("%.1f", tpDelay) .. "s"
    end
end)
