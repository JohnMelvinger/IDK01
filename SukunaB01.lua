local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Function to create the GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CharacterSelectorGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 200, 0, 280)
    mainFrame.Position = UDim2.new(0.5, -100, 0.5, -140)
    mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 30)
    topBar.Position = UDim2.new(0, 0, 0, 0)
    topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Text = "Character Selector"
    titleLabel.TextSize = 18
    titleLabel.Parent = topBar

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Text = "X"
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 20
    closeButton.Parent = topBar

    -- Search bar (replacing the dropdown button)
    local searchBar = Instance.new("TextBox")
    searchBar.Size = UDim2.new(1, -20, 0, 30)
    searchBar.Position = UDim2.new(0, 10, 0, 40)
    searchBar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    searchBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBar.PlaceholderText = "Search and select character..."
    searchBar.Text = ""
    searchBar.Font = Enum.Font.SourceSans
    searchBar.TextSize = 14
    searchBar.Parent = mainFrame

    local dropdownFrame = Instance.new("ScrollingFrame")
    dropdownFrame.Size = UDim2.new(1, -20, 0, 200)
    dropdownFrame.Position = UDim2.new(0, 10, 0, 80)
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.ScrollBarThickness = 5
    dropdownFrame.Parent = mainFrame

    local names = {
        "Limitless", "Young Gojo", "Shinjuku Gojo", "Itadori", "Meguna", "Hakari", "Yura", "Choso",
        "Toji", "Geto", "Rengoku", "Luffy", "Saitama", "Serious Saitama", "Rampage Garou",
        "Atomic Samurai", "Nanami", "Todo", "Goku", "Ichigo", "KJ", "Megumi", "Jogo", "Kashimo",
        "Dagon", "Judgeman", "Mahito"
    }

    local function createCharacterButton(name, index)
        local item = Instance.new("TextButton")
        item.Size = UDim2.new(1, -10, 0, 30)
        item.Position = UDim2.new(0, 5, 0, (index-1) * 35)
        item.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        item.TextColor3 = Color3.fromRGB(255, 255, 255)
        item.Text = name
        item.Parent = dropdownFrame
        
        item.MouseButton1Click:Connect(function()
            searchBar.Text = name
            
            local args = {
                [1] = "Character",
                [2] = name,
                [3] = "Select"
            }
            ReplicatedStorage:WaitForChild("Attribute"):FireServer(unpack(args))
        end)
        return item
    end

    local characterButtons = {}
    for i, name in ipairs(names) do
        characterButtons[i] = createCharacterButton(name, i)
    end

    local function updateDropdown(searchText)
        local visibleCount = 0
        for i, button in ipairs(characterButtons) do
            if string.find(string.lower(button.Text), string.lower(searchText)) then
                button.Visible = true
                button.Position = UDim2.new(0, 5, 0, visibleCount * 35)
                visibleCount = visibleCount + 1
            else
                button.Visible = false
            end
        end
        dropdownFrame.CanvasSize = UDim2.new(0, 0, 0, visibleCount * 35)
    end

    searchBar.Changed:Connect(function(prop)
        if prop == "Text" then
            updateDropdown(searchBar.Text)
        end
    end)

    -- Dragging functionality
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    return screenGui
end

-- Function to check if the GUI exists and create it if it doesn't
local function ensureGUIExists()
    local existingGUI = player.PlayerGui:FindFirstChild("CharacterSelectorGUI")
    if not existingGUI then
        createGUI()
    end
end

-- Create the GUI when the script runs
ensureGUIExists()

-- Recreate the GUI when the character respawns
player.CharacterAdded:Connect(ensureGUIExists)
