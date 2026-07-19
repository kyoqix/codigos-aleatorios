local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
if not player then
    return
end

local fflagsToModify = {
    ["FFlagDebugGraphicsPreferD3D11"] = true,
    ["FFlagDebugGraphicsPreferOpenGL"] = false,
    ["FFlagHandleAltEnterFullscreenManually"] = true,
    ["FFlagDebugDisableTelemetryEpic"] = true,
    ["FFlagDebugDisableTelemetryV2"] = true,
}

local runtimeEnvironment = _G

if typeof(getgenv) == "function" then
    local success, environment = pcall(getgenv)

    if success and type(environment) == "table" then
        runtimeEnvironment = environment
    end
end

local sessionKey = "__AVERAGE_FFLAG_EDITOR_SESSION"
local previousSession = runtimeEnvironment[sessionKey]

if type(previousSession) == "table" and typeof(previousSession.destroy) == "function" then
    pcall(previousSession.destroy)
end

local setFlag = runtimeEnvironment.setfflag
local getFlag = runtimeEnvironment.getfflag

if typeof(setFlag) ~= "function" and typeof(setfflag) == "function" then
    setFlag = setfflag
end

if typeof(getFlag) ~= "function" and typeof(getfflag) == "function" then
    getFlag = getfflag
end

local guiParent = player:WaitForChild("PlayerGui")

if typeof(gethui) == "function" then
    local success, result = pcall(gethui)

    if success and result then
        guiParent = result
    end
end

local connections = {}
local destroyed = false
local screenGui
local session

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end

local function destroy()
    if destroyed then
        return
    end

    destroyed = true

    for _, connection in ipairs(connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(connections)

    if screenGui then
        pcall(function()
            screenGui:Destroy()
        end)
    end

    if runtimeEnvironment[sessionKey] == session then
        runtimeEnvironment[sessionKey] = nil
    end
end

session = {
    destroy = destroy,
}

runtimeEnvironment[sessionKey] = session

local existingGui = guiParent:FindFirstChild("AverageFFlagEditor")

if existingGui then
    existingGui:Destroy()
end

local function create(className, properties)
    local instance = Instance.new(className)
    local parent = properties.Parent

    for property, value in pairs(properties) do
        if property ~= "Parent" then
            instance[property] = value
        end
    end

    instance.Parent = parent
    return instance
end

local function addCorner(instance, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius),
        Parent = instance,
    })
end

local function addStroke(instance, color, transparency)
    return create("UIStroke", {
        Color = color,
        Transparency = transparency or 0,
        Thickness = 1,
        Parent = instance,
    })
end

local function trim(value)
    return (tostring(value):gsub("^%s*(.-)%s*$", "%1"))
end

local colors = {
    background = Color3.fromRGB(20, 21, 28),
    header = Color3.fromRGB(27, 29, 38),
    panel = Color3.fromRGB(31, 33, 43),
    input = Color3.fromRGB(38, 41, 53),
    border = Color3.fromRGB(74, 78, 99),
    text = Color3.fromRGB(238, 239, 245),
    secondaryText = Color3.fromRGB(163, 167, 184),
    accent = Color3.fromRGB(83, 116, 255),
    accentHover = Color3.fromRGB(102, 132, 255),
    success = Color3.fromRGB(65, 190, 112),
    warning = Color3.fromRGB(235, 175, 70),
    error = Color3.fromRGB(225, 75, 88),
    remove = Color3.fromRGB(183, 64, 75),
}

screenGui = create("ScreenGui", {
    Name = "AverageFFlagEditor",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = guiParent,
})

local openButton = create("TextButton", {
    Name = "OpenButton",
    Size = UDim2.fromOffset(48, 48),
    Position = UDim2.new(1, -62, 0, 16),
    AnchorPoint = Vector2.new(0, 0),
    BackgroundColor3 = colors.accent,
    BorderSizePixel = 0,
    Text = "FF",
    TextColor3 = colors.text,
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    Visible = false,
    Parent = screenGui,
})

addCorner(openButton, 14)
addStroke(openButton, Color3.fromRGB(130, 150, 255), 0.35)

local mainFrame = create("Frame", {
    Name = "MainFrame",
    Size = UDim2.fromOffset(620, 460),
    Position = UDim2.new(0.5, -310, 0.5, -230),
    BackgroundColor3 = colors.background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Active = true,
    Parent = screenGui,
})

addCorner(mainFrame, 12)
addStroke(mainFrame, colors.border, 0.35)

local uiScale = create("UIScale", {
    Scale = 1,
    Parent = mainFrame,
})

local header = create("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 46),
    BackgroundColor3 = colors.header,
    BorderSizePixel = 0,
    Active = true,
    Parent = mainFrame,
})

local titleLabel = create("TextLabel", {
    Size = UDim2.new(1, -100, 1, 0),
    Position = UDim2.fromOffset(18, 0),
    BackgroundTransparency = 1,
    Text = "AVERAGE FFLAG EDITOR",
    TextColor3 = colors.text,
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = header,
})

local closeButton = create("TextButton", {
    Size = UDim2.fromOffset(34, 34),
    Position = UDim2.new(1, -41, 0, 6),
    BackgroundColor3 = colors.panel,
    BorderSizePixel = 0,
    Text = "×",
    TextColor3 = colors.secondaryText,
    TextSize = 24,
    Font = Enum.Font.Gotham,
    AutoButtonColor = false,
    Parent = header,
})

addCorner(closeButton, 8)

local statusLabel = create("TextLabel", {
    Size = UDim2.new(1, -36, 0, 24),
    Position = UDim2.fromOffset(18, 51),
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = colors.secondaryText,
    TextSize = 13,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    Parent = mainFrame,
})

local function setStatus(text, statusType)
    statusLabel.Text = text

    if statusType == "success" then
        statusLabel.TextColor3 = colors.success
    elseif statusType == "warning" then
        statusLabel.TextColor3 = colors.warning
    elseif statusType == "error" then
        statusLabel.TextColor3 = colors.error
    else
        statusLabel.TextColor3 = colors.secondaryText
    end
end

local addPanel = create("Frame", {
    Size = UDim2.new(1, -36, 0, 48),
    Position = UDim2.fromOffset(18, 80),
    BackgroundColor3 = colors.panel,
    BorderSizePixel = 0,
    Parent = mainFrame,
})

addCorner(addPanel, 8)
addStroke(addPanel, colors.border, 0.6)

local nameInput = create("TextBox", {
    Size = UDim2.new(1, -238, 0, 34),
    Position = UDim2.fromOffset(7, 7),
    BackgroundColor3 = colors.input,
    BorderSizePixel = 0,
    Text = "",
    PlaceholderText = "Nome da FFlag",
    PlaceholderColor3 = colors.secondaryText,
    TextColor3 = colors.text,
    TextSize = 13,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = addPanel,
})

addCorner(nameInput, 6)

create("UIPadding", {
    PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10),
    Parent = nameInput,
})

local valueInput = create("TextBox", {
    Size = UDim2.fromOffset(116, 34),
    Position = UDim2.new(1, -224, 0, 7),
    BackgroundColor3 = colors.input,
    BorderSizePixel = 0,
    Text = "true",
    PlaceholderText = "Valor",
    PlaceholderColor3 = colors.secondaryText,
    TextColor3 = colors.text,
    TextSize = 13,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = addPanel,
})

addCorner(valueInput, 6)

create("UIPadding", {
    PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10),
    Parent = valueInput,
})

local addButton = create("TextButton", {
    Size = UDim2.fromOffset(94, 34),
    Position = UDim2.new(1, -101, 0, 7),
    BackgroundColor3 = colors.accent,
    BorderSizePixel = 0,
    Text = "ADICIONAR",
    TextColor3 = colors.text,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    Parent = addPanel,
})

addCorner(addButton, 6)

local columnsLabel = create("TextLabel", {
    Size = UDim2.new(1, -36, 0, 22),
    Position = UDim2.fromOffset(18, 133),
    BackgroundTransparency = 1,
    Text = "FLAG                                                                              VALOR",
    TextColor3 = colors.secondaryText,
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = mainFrame,
})

local scrollFrame = create("ScrollingFrame", {
    Size = UDim2.new(1, -36, 0, 238),
    Position = UDim2.fromOffset(18, 158),
    BackgroundColor3 = colors.panel,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = colors.border,
    CanvasSize = UDim2.fromOffset(0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    Parent = mainFrame,
})

addCorner(scrollFrame, 8)
addStroke(scrollFrame, colors.border, 0.6)

create("UIPadding", {
    PaddingTop = UDim.new(0, 7),
    PaddingBottom = UDim.new(0, 7),
    PaddingLeft = UDim.new(0, 7),
    PaddingRight = UDim.new(0, 7),
    Parent = scrollFrame,
})

local listLayout = create("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = scrollFrame,
})

local rows = {}
local originalValues = {}
local appliedFlags = {}
local busy = false

local function updateRowOrder()
    for index, rowData in ipairs(rows) do
        rowData.frame.LayoutOrder = index
    end
end

local function addRow(flagName, flagValue)
    local rowFrame = create("Frame", {
        Name = "FlagRow",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = colors.input,
        BorderSizePixel = 0,
        Parent = scrollFrame,
    })

    addCorner(rowFrame, 6)

    local flagBox = create("TextBox", {
        Size = UDim2.new(1, -194, 1, 0),
        Position = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1,
        Text = tostring(flagName or ""),
        PlaceholderText = "Nome da flag",
        PlaceholderColor3 = colors.secondaryText,
        TextColor3 = colors.text,
        TextSize = 13,
        Font = Enum.Font.Code,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = rowFrame,
    })

    create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 8),
        Parent = flagBox,
    })

    local flagValueBox = create("TextBox", {
        Size = UDim2.fromOffset(138, 28),
        Position = UDim2.new(1, -184, 0, 4),
        BackgroundColor3 = colors.panel,
        BorderSizePixel = 0,
        Text = tostring(flagValue),
        PlaceholderText = "Valor",
        PlaceholderColor3 = colors.secondaryText,
        TextColor3 = colors.text,
        TextSize = 13,
        Font = Enum.Font.Code,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = rowFrame,
    })

    addCorner(flagValueBox, 5)

    create("UIPadding", {
        PaddingLeft = UDim.new(0, 9),
        PaddingRight = UDim.new(0, 9),
        Parent = flagValueBox,
    })

    local removeButton = create("TextButton", {
        Size = UDim2.fromOffset(32, 28),
        Position = UDim2.new(1, -38, 0, 4),
        BackgroundColor3 = colors.remove,
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = colors.text,
        TextSize = 20,
        Font = Enum.Font.Gotham,
        AutoButtonColor = false,
        Parent = rowFrame,
    })

    addCorner(removeButton, 5)

    local rowData = {
        frame = rowFrame,
        flagBox = flagBox,
        valueBox = flagValueBox,
    }

    table.insert(rows, rowData)
    updateRowOrder()

    connect(removeButton.MouseButton1Click, function()
        local index = table.find(rows, rowData)

        if index then
            table.remove(rows, index)
        end

        rowFrame:Destroy()
        updateRowOrder()
    end)

    return rowData
end

local initialFlagNames = {}

for flagName in pairs(fflagsToModify) do
    table.insert(initialFlagNames, flagName)
end

table.sort(initialFlagNames)

for _, flagName in ipairs(initialFlagNames) do
    addRow(flagName, fflagsToModify[flagName])
end

local function flagExistsInEditor(flagName)
    for _, rowData in ipairs(rows) do
        if trim(rowData.flagBox.Text) == flagName then
            return true
        end
    end

    return false
end

local function addInputFlag()
    local flagName = trim(nameInput.Text)
    local flagValue = trim(valueInput.Text)

    if flagName == "" then
        setStatus("Digite o nome da FFlag.", "error")
        return
    end

    if flagExistsInEditor(flagName) then
        setStatus("Essa FFlag já está na lista.", "warning")
        return
    end

    addRow(flagName, flagValue)
    nameInput.Text = ""
    valueInput.Text = "true"
    setStatus("FFlag adicionada ao editor.", "success")
end

connect(addButton.MouseButton1Click, addInputFlag)

connect(nameInput.FocusLost, function(enterPressed)
    if enterPressed then
        addInputFlag()
    end
end)

connect(valueInput.FocusLost, function(enterPressed)
    if enterPressed then
        addInputFlag()
    end
end)

local footer = create("Frame", {
    Size = UDim2.new(1, -36, 0, 42),
    Position = UDim2.fromOffset(18, 406),
    BackgroundTransparency = 1,
    Parent = mainFrame,
})

local applyButton = create("TextButton", {
    Size = UDim2.new(0.5, -5, 1, 0),
    Position = UDim2.fromOffset(0, 0),
    BackgroundColor3 = colors.accent,
    BorderSizePixel = 0,
    Text = "APLICAR FFLAGS",
    TextColor3 = colors.text,
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    Parent = footer,
})

addCorner(applyButton, 7)

local restoreButton = create("TextButton", {
    Size = UDim2.new(0.5, -5, 1, 0),
    Position = UDim2.new(0.5, 5, 0, 0),
    BackgroundColor3 = colors.remove,
    BorderSizePixel = 0,
    Text = "RESTAURAR ORIGINAIS",
    TextColor3 = colors.text,
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    Parent = footer,
})

addCorner(restoreButton, 7)

local function readFlagValue(flagName)
    if typeof(getFlag) == "function" then
        local success, value = pcall(getFlag, flagName)

        if success then
            return true, value
        end
    end

    local success, value = pcall(function()
        return settings():GetFFlag(flagName)
    end)

    if success then
        return true, value
    end

    return false, nil
end

local function writeFlagValue(flagName, flagValue)
    if typeof(setFlag) ~= "function" then
        return false, "setfflag não está disponível"
    end

    local success, result = pcall(setFlag, flagName, tostring(flagValue))

    if not success then
        return false, tostring(result)
    end

    if result == false then
        return false, "setfflag retornou false"
    end

    return true
end

local function collectEditorFlags()
    local collectedFlags = {}
    local usedNames = {}

    for _, rowData in ipairs(rows) do
        local flagName = trim(rowData.flagBox.Text)
        local flagValue = trim(rowData.valueBox.Text)

        if flagName == "" then
            return nil, "Existe uma linha sem nome."
        end

        if usedNames[flagName] then
            return nil, "A FFlag " .. flagName .. " está duplicada."
        end

        usedNames[flagName] = true

        table.insert(collectedFlags, {
            name = flagName,
            value = flagValue,
        })
    end

    if #collectedFlags == 0 then
        return nil, "Nenhuma FFlag foi adicionada."
    end

    return collectedFlags
end

local function applyAllFlags()
    if busy then
        return
    end

    if typeof(setFlag) ~= "function" then
        setStatus("Este executor não disponibiliza setfflag.", "error")
        return
    end

    local flags, collectionError = collectEditorFlags()

    if not flags then
        setStatus(collectionError, "error")
        return
    end

    busy = true
    applyButton.Text = "APLICANDO..."

    local appliedCount = 0
    local failedCount = 0
    local firstError

    for _, flagData in ipairs(flags) do
        local flagName = flagData.name
        local wasAlreadyApplied = appliedFlags[flagName] == true

        if not originalValues[flagName] then
            local readable, originalValue = readFlagValue(flagName)

            originalValues[flagName] = {
                readable = readable,
                value = originalValue,
            }
        end

        local success, errorMessage = writeFlagValue(flagName, flagData.value)

        if success then
            appliedFlags[flagName] = true
            appliedCount += 1
        else
            failedCount += 1
            firstError = firstError or flagName .. ": " .. tostring(errorMessage)

            if not wasAlreadyApplied then
                originalValues[flagName] = nil
            end
        end
    end

    applyButton.Text = "APLICAR FFLAGS"
    busy = false

    if failedCount == 0 then
        setStatus(tostring(appliedCount) .. " FFlags aplicadas com sucesso.", "success")
    else
        if #firstError > 90 then
            firstError = firstError:sub(1, 87) .. "..."
        end

        setStatus(
            tostring(appliedCount)
                .. " aplicadas, "
                .. tostring(failedCount)
                .. " falharam. "
                .. firstError,
            "warning"
        )
    end
end

local function restoreAllFlags()
    if busy then
        return
    end

    if typeof(setFlag) ~= "function" then
        setStatus("Este executor não disponibiliza setfflag.", "error")
        return
    end

    local namesToRestore = {}

    for flagName in pairs(appliedFlags) do
        table.insert(namesToRestore, flagName)
    end

    if #namesToRestore == 0 then
        setStatus("Nenhuma FFlag aplicada por esta sessão.", "warning")
        return
    end

    busy = true
    restoreButton.Text = "RESTAURANDO..."

    local restoredCount = 0
    local unavailableCount = 0
    local failedCount = 0
    local firstError

    for _, flagName in ipairs(namesToRestore) do
        local originalData = originalValues[flagName]

        if originalData and originalData.readable then
            local success, errorMessage = writeFlagValue(flagName, originalData.value)

            if success then
                appliedFlags[flagName] = nil
                originalValues[flagName] = nil
                restoredCount += 1
            else
                failedCount += 1
                firstError = firstError or flagName .. ": " .. tostring(errorMessage)
            end
        else
            unavailableCount += 1
        end
    end

    restoreButton.Text = "RESTAURAR ORIGINAIS"
    busy = false

    local resultText = tostring(restoredCount) .. " restauradas"

    if unavailableCount > 0 then
        resultText ..= ", " .. tostring(unavailableCount) .. " sem valor original"
    end

    if failedCount > 0 then
        resultText ..= ", " .. tostring(failedCount) .. " falharam"

        if firstError then
            if #firstError > 70 then
                firstError = firstError:sub(1, 67) .. "..."
            end

            resultText ..= ". " .. firstError
        end
    end

    if unavailableCount > 0 or failedCount > 0 then
        setStatus(resultText, "warning")
    else
        setStatus(resultText .. ".", "success")
    end
end

connect(applyButton.MouseButton1Click, applyAllFlags)
connect(restoreButton.MouseButton1Click, restoreAllFlags)

local guiVisible = true

local function setGuiVisible(visible)
    guiVisible = visible
    mainFrame.Visible = visible
    openButton.Visible = not visible
end

connect(closeButton.MouseButton1Click, function()
    setGuiVisible(false)
end)

connect(openButton.MouseButton1Click, function()
    setGuiVisible(true)
end)

connect(UserInputService.InputBegan, function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.Insert then
        setGuiVisible(not guiVisible)
    end
end)

local dragging = false
local dragStart
local startPosition

connect(header.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = mainFrame.Position
    end
end)

connect(UserInputService.InputChanged, function(input)
    if not dragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - dragStart

    mainFrame.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end)

connect(UserInputService.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false
    end
end)

local function updateScale()
    local camera = workspace.CurrentCamera

    if not camera then
        return
    end

    local viewportSize = camera.ViewportSize

    uiScale.Scale = math.clamp(
        math.min(
            (viewportSize.X - 20) / 620,
            (viewportSize.Y - 20) / 460
        ),
        0.55,
        1
    )
end

updateScale()

if workspace.CurrentCamera then
    connect(
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"),
        updateScale
    )
end

connect(workspace:GetPropertyChangedSignal("CurrentCamera"), updateScale)

if typeof(setFlag) == "function" then
    if typeof(getFlag) == "function" then
        setStatus("Editor pronto. Aplicação e restauração disponíveis.", "success")
    else
        setStatus("Editor pronto. Algumas flags podem não ter restauração disponível.", "warning")
    end
else
    setStatus("GUI carregada, mas este executor não possui setfflag.", "error")
end
