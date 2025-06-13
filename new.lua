-- Garden Stealer Controller
-- Uses Rayfield UI (https://github.com/jensonhirst/Rayfield)
-- Safe to execute in Roblox

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInput = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Load Rayfield safely
local Rayfield
local success, err = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Rayfield/main/source'))()
end)

if not success then
    warn("Failed to load Rayfield: "..tostring(err))
    return
end

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "🌿 Garden Stealer",
    LoadingTitle = "Initializing Controller...",
    LoadingSubtitle = "by github.com/jensonhirst",
    ConfigurationSaving = {
        Enabled = false,
    },
    KeySystem = false,
})

-- Variables
local targetPlayer = nil
local isStealing = false
local isCollecting = false
local localCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Update character reference
LocalPlayer.CharacterAdded:Connect(function(char)
    localCharacter = char
end)

-- Functions
local function getPlayerByName(name)
    for _, player in ipairs(Players:GetPlayers()) do
        if string.find(player.Name:lower(), name:lower()) then
            return player
        end
    end
    return nil
end

local function teleportToPlayer(player)
    if not player or not player.Character then return end
    local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
    local myHRP = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    if targetHRP and myHRP then
        local offset = targetHRP.CFrame.LookVector * 3
        myHRP.CFrame = CFrame.new(targetHRP.Position + offset, targetHRP.Position)
    end
end

local function faceTarget(target)
    local hrp = localCharacter:FindFirstChild("HumanoidRootPart")
    if hrp and target then
        hrp.CFrame = CFrame.new(hrp.Position, target.Position)
    end
end

local function holdE()
    VirtualInput:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(1)
    VirtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local function stealFromPlayer()
    while isStealing and targetPlayer and targetPlayer.Character do
        teleportToPlayer(targetPlayer)
        faceTarget(targetPlayer.Character:FindFirstChild("HumanoidRootPart"))
        
        -- Get tools from backpack and character
        local tools = {}
        local function collectTools(from)
            for _, item in ipairs(from:GetChildren()) do
                if item:IsA("Tool") then
                    table.insert(tools, item)
                end
            end
        end
        
        if LocalPlayer.Backpack then collectTools(LocalPlayer.Backpack) end
        if localCharacter then collectTools(localCharacter) end
        
        -- Use each tool
        for _, tool in ipairs(tools) do
            if not isStealing then break end
            
            local humanoid = localCharacter:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:EquipTool(tool)
                task.wait(0.1)
                holdE()
                task.wait(0.1)
            end
        end
        
        if localCharacter then
            local humanoid = localCharacter:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:UnequipTools()
            end
        end
        task.wait(0.5)
    end
end

local function collectCrops()
    while isCollecting do
        if not localCharacter then
            task.wait(1)
            continue
        end
        
        local humanoid = localCharacter:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            task.wait(1)
            continue
        end
        
        -- Reset position
        humanoid.Health = 0
        repeat task.wait() until localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
        
        -- Move backward and right
        local hrp = localCharacter:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -50) -- Backward
            task.wait(0.5)
            hrp.CFrame = hrp.CFrame * CFrame.new(25, 0, 0) -- Right
            
            -- Find and activate proximity prompts
            for _, prompt in ipairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and isCollecting then
                    faceTarget(prompt.Parent:FindFirstChildWhichIsA("BasePart"))
                    
                    while prompt.Parent and isCollecting do
                        VirtualInput:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(0.1)
                        VirtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        task.wait(0.1)
                    end
                end
            end
        end
    end
end

-- Main Tab
local MainTab = Window:CreateTab("Main Controls", 4483362458)

-- Player Dropdown
local playerDropdown = MainTab:CreateDropdown({
    Name = "Select Target Player",
    Options = {},
    CurrentOption = "",
    Flag = "PlayerDropdown",
    Callback = function(option)
        targetPlayer = getPlayerByName(option)
    end,
})

-- Update player list
local function updatePlayerList()
    local options = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(options, player.Name)
        end
    end
    playerDropdown:UpdateOptions(options)
end

-- Initial update
updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- Steal Toggle
MainTab:CreateToggle({
    Name = "Steal Items",
    CurrentValue = false,
    Flag = "StealToggle",
    Callback = function(value)
        isStealing = value
        if value then
            Rayfield:Notify({
                Title = "Stealing Activated",
                Content = "Now stealing from "..(targetPlayer and targetPlayer.Name or "no target"),
                Duration = 3,
                Image = 4483362458,
            })
            stealFromPlayer()
        else
            Rayfield:Notify({
                Title = "Stealing Stopped",
                Content = "No longer stealing items",
                Duration = 3,
                Image = 4483362458,
            })
        end
    end,
})

-- Collect Toggle
MainTab:CreateToggle({
    Name = "Collect Crops",
    CurrentValue = false,
    Flag = "CollectToggle",
    Callback = function(value)
        isCollecting = value
        if value then
            Rayfield:Notify({
                Title = "Collecting Activated",
                Content = "Automatically collecting crops",
                Duration = 3,
                Image = 4483362458,
            })
            collectCrops()
        else
            Rayfield:Notify({
                Title = "Collecting Stopped",
                Content = "No longer collecting crops",
                Duration = 3,
                Image = 4483362458,
            })
        end
    end,
})

-- Keybind to toggle UI
local uiToggle = MainTab:CreateKeybind({
    Name = "Toggle UI",
    CurrentKeybind = "RightControl",
    HoldToInteract = false,
    Flag = "UIToggle",
    Callback = function(key)
        Rayfield:ToggleUI()
    end,
})

-- Watermark
Rayfield:Notify({
    Title = "Garden Stealer Loaded",
    Content = "Press RightControl to toggle UI",
    Duration = 5,
    Image = 4483362458,
})
wwwww
-- Initialize
Rayfield:LoadConfiguration()
