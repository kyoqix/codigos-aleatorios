local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
if not player then
    return
end

local environment = _G

if typeof(getgenv) == "function" then
    local success, result = pcall(getgenv)

    if success and type(result) == "table" then
        environment = result
    end
end

local SESSION_KEY = "__AVERAGE_FFLAG_EDITOR_V2_SESSION"
local LAST_URL_KEY = "__AVERAGE_FFLAG_EDITOR_V2_LAST_URL"
local previousSession = environment[SESSION_KEY]

if type(previousSession) == "table" and typeof(previousSession.destroy) == "function" then
    pcall(previousSession.destroy)
end

local function firstFunction(...)
    for index = 1, select("#", ...) do
        local value = select(index, ...)

        if typeof(value) == "function" then
            return value
        end
    end

    return nil
end

local setFlagFunction = firstFunction(environment.setfflag, setfflag)
local getFlagFunction = firstFunction(environment.getfflag, getfflag)

local synEnvironment = environment.syn
local fluxusEnvironment = environment.fluxus

local requestFunction = firstFunction(
    environment.request,
    environment.http_request,
    environment.httprequest,
    request,
    http_request,
    type(synEnvironment) == "table" and synEnvironment.request or nil,
    type(fluxusEnvironment) == "table" and fluxusEnvironment.request or nil
)

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

    if environment[SESSION_KEY] == session then
        environment[SESSION_KEY] = nil
    end
end

session = {
    destroy = destroy,
}

environment[SESSION_KEY] = session

local oldGui = guiParent:FindFirstChild("AverageFFlagEditorV2")

if oldGui then
    oldGui:Destroy()
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

local function corner(instance, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius),
        Parent = instance,
    })
end

local function stroke(instance, color, transparency)
    return create("UIStroke", {
        Color = color,
        Transparency = transparency or 0,
        Thickness = 1,
        Parent = instance,
    })
end

local function padding(instance, left, right, top, bottom)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        Parent = instance,
    })
end

local function trim(value)
    return (tostring(value or ""):gsub("^%s*(.-)%s*$", "%1"))
end

local colors = {
    background = Color3.fromRGB(18, 19, 23),
    header = Color3.fromRGB(23, 24, 29),
    panel = Color3.fromRGB(27, 29, 35),
    input = Color3.fromRGB(32, 34, 41),
    inputHover = Color3.fromRGB(37, 39, 47),
    border = Color3.fromRGB(55, 58, 69),
    borderBright = Color3.fromRGB(73, 77, 91),
    text = Color3.fromRGB(232, 234, 240),
    muted = Color3.fromRGB(143, 147, 160),
    faint = Color3.fromRGB(102, 106, 119),
    accent = Color3.fromRGB(74, 122, 255),
    accentHover = Color3.fromRGB(91, 136, 255),
    success = Color3.fromRGB(72, 190, 123),
    warning = Color3.fromRGB(226, 167, 72),
    error = Color3.fromRGB(218, 78, 92),
    errorHover = Color3.fromRGB(232, 91, 104),
}

screenGui = create("ScreenGui", {
    Name = "AverageFFlagEditorV2",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = guiParent,
})

local openButton = create("TextButton", {
    Name = "OpenButton",
    Size = UDim2.fromOffset(42, 28),
    Position = UDim2.new(1, -54, 0, 12),
    BackgroundColor3 = colors.accent,
    BorderSizePixel = 0,
    Text = "FF",
    TextColor3 = colors.text,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    Visible = false,
    Parent = screenGui,
})

corner(openButton, 6)

local mainFrame = create("Frame", {
    Name = "Window",
    Size = UDim2.fromOffset(540, 414),
    Position = UDim2.new(0.5, -270, 0.5, -207),
    BackgroundColor3 = colors.background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Active = true,
    Parent = screenGui,
})

corner(mainFrame, 8)
stroke(mainFrame, colors.borderBright, 0.35)

local header = create("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 36),
    BackgroundColor3 = colors.header,
    BorderSizePixel = 0,
    Active = true,
    Parent = mainFrame,
})

local titleLabel = create("TextLabel", {
    Size = UDim2.new(1, -90, 1, 0),
    Position = UDim2.fromOffset(12, 0),
    BackgroundTransparency = 1,
    Text = "FFLAG EDITOR",
    TextColor3 = colors.text,
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = header,
})

local shortcutLabel = create("TextLabel", {
    Size = UDim2.fromOffset(76, 36),
    Position = UDim2.new(1, -112, 0, 0),
    BackgroundTransparency = 1,
    Text = "INSERT",
    TextColor3 = colors.faint,
    TextSize = 10,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Right,
    Parent = header,
})

local closeButton = create("TextButton", {
    Size = UDim2.fromOffset(28, 28),
    Position = UDim2.new(1, -32, 0, 4),
    BackgroundColor3 = colors.header,
    BorderSizePixel = 0,
    Text = "×",
    TextColor3 = colors.muted,
    TextSize = 19,
    Font = Enum.Font.Gotham,
    AutoButtonColor = false,
    Parent = header,
})

local urlInput = create("TextBox", {
    Name = "UrlInput",
    Size = UDim2.fromOffset(418, 30),
    Position = UDim2.fromOffset(12, 46),
    BackgroundColor3 = colors.input,
    BorderSizePixel = 0,
    Text = type(environment[LAST_URL_KEY]) == "string" and environment[LAST_URL_KEY] or "",
    PlaceholderText = "GitHub RAW ou link github.com/.../blob/...",
    PlaceholderColor3 = colors.faint,
    TextColor3 = colors.text,
    TextSize = 12,
    Font = Enum.Font.Code,
    ClearTextOnFocus = false,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = mainFrame,
})

corner(urlInput, 5)
stroke(urlInput, colors.border, 0.3)
padding(urlInput, 9, 9)

local loadButton = create("TextButton", {
    Name = "LoadButton",
    Size = UDim2.fromOffset(90, 30),
    Position = UDim2.new(1, -102, 0, 46),
    BackgroundColor3 = colors.accent,
    BorderSizePixel = 0,
    Text = "LOAD RAW",
    TextColor3 = colors.text,
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    Parent = mainFrame,
})

corner(loadButton, 5)

local searchInput = create("TextBox", {
    Name = "SearchInput",
    Size = UDim2.fromOffset(254, 28),
    Position = UDim2.fromOffset(12, 84),
    BackgroundColor3 = colors.input,
    BorderSizePixel = 0,
    Text = "",
    PlaceholderText = "Search flags  (Ctrl+F)",
    PlaceholderColor3 = colors.faint,
    TextColor3 = colors.text,
    TextSize = 12,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = mainFrame,
})

corner(searchInput, 5)
stroke(searchInput, colors.border, 0.45)
padding(searchInput, 9, 9)

local countLabel = create("TextLabel", {
    Size = UDim2.fromOffset(116, 28),
    Position = UDim2.fromOffset(274, 84),
    BackgroundTransparency = 1,
    Text = "0 FLAGS",
    TextColor3 = colors.muted,
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = mainFrame,
})

local selectButton = create("TextButton", {
    Size = UDim2.fromOffset(58, 28),
    Position = UDim2.fromOffset(390, 84),
    BackgroundColor3 = colors.panel,
    BorderSizePixel = 0,
    Text = "ALL",
    TextColor3 = colors.muted,
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    Parent = mainFrame,
})

corner(selectButton, 5)
stroke(selectButton, colors.border, 0.45)

local addButton = create("TextButton", {
    Size = UDim2.fromOffset(34, 28),
    Position = UDim2.fromOffset(454, 84),
    BackgroundColor3 = colors.panel,
    BorderSizePixel = 0,
    Text = "+",
    TextColor3 = colors.text,
    TextSize = 17,
    Font = Enum.Font.GothamMedium,
    AutoButtonColor = false,
    Parent = mainFrame,
})

corner(addButton, 5)
stroke(addButton, colors.border, 0.45)

local clearButton = create("TextButton", {
    Size = UDim2.fromOffset(40, 28),
    Position = UDim2.fromOffset(488, 84),
    BackgroundColor3 = colors.panel,
    BorderSizePixel = 0,
    Text = "CLR",
    TextColor3 = colors.muted,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    Parent = mainFrame,
})

corner(clearButton, 5)
stroke(clearButton, colors.border, 0.45)

local columnHeader = create("Frame", {
    Size = UDim2.fromOffset(516, 18),
    Position = UDim2.fromOffset(12, 118),
    BackgroundTransparency = 1,
    Parent = mainFrame,
})

create("TextLabel", {
    Size = UDim2.fromOffset(28, 18),
    BackgroundTransparency = 1,
    Text = "ON",
    TextColor3 = colors.faint,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    Parent = columnHeader,
})

create("TextLabel", {
    Size = UDim2.fromOffset(288, 18),
    Position = UDim2.fromOffset(32, 0),
    BackgroundTransparency = 1,
    Text = "FLAG",
    TextColor3 = colors.faint,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = columnHeader,
})

create("TextLabel", {
    Size = UDim2.fromOffset(146, 18),
    Position = UDim2.fromOffset(326, 0),
    BackgroundTransparency = 1,
    Text = "VALUE",
    TextColor3 = colors.faint,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = columnHeader,
})

local rowsPanel = create("Frame", {
    Size = UDim2.fromOffset(516, 204),
    Position = UDim2.fromOffset(12, 136),
    BackgroundColor3 = colors.panel,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = mainFrame,
})

corner(rowsPanel, 6)
stroke(rowsPanel, colors.border, 0.35)

local previousButton = create("TextButton", {
    Size = UDim2.fromOffset(28, 24),
    Position = UDim2.fromOffset(12, 346),
    BackgroundColor3 = colors.panel,
    BorderSizePixel = 0,
    Text = "‹",
    TextColor3 = colors.muted,
    TextSize = 18,
    Font = Enum.Font.Gotham,
    AutoButtonColor = false,
    Parent = mainFrame,
})

corner(previousButton, 5)
stroke(previousButton, colors.border, 0.45)

local pageLabel = create("TextLabel", {
    Size = UDim2.fromOffset(58, 24),
    Position = UDim2.fromOffset(44, 346),
    BackgroundTransparency = 1,
    Text = "1 / 1",
    TextColor3 = colors.muted,
    TextSize = 10,
    Font = Enum.Font.GothamMedium,
    Parent = mainFrame,
})

local nextButton = create("TextButton", {
    Size = UDim2.fromOffset(28, 24),
    Position = UDim2.fromOffset(104, 346),
    BackgroundColor3 = colors.panel,
    BorderSizePixel = 0,
    Text = "›",
    TextColor3 = colors.muted,
    TextSize = 18,
    Font = Enum.Font.Gotham,
    AutoButtonColor = false,
    Parent = mainFrame,
})

corner(nextButton, 5)
stroke(nextButton, colors.border, 0.45)

local statusLabel = create("TextLabel", {
    Size = UDim2.fromOffset(386, 24),
    Position = UDim2.fromOffset(142, 346),
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = colors.muted,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Right,
    TextTruncate = Enum.TextTruncate.AtEnd,
    Parent = mainFrame,
})

local applyButton = create("TextButton", {
    Size = UDim2.fromOffset(254, 30),
    Position = UDim2.fromOffset(12, 376),
    BackgroundColor3 = colors.accent,
    BorderSizePixel = 0,
    Text = "APPLY ENABLED",
    TextColor3 = colors.text,
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    Parent = mainFrame,
})

corner(applyButton, 5)

local restoreButton = create("TextButton", {
    Size = UDim2.fromOffset(254, 30),
    Position = UDim2.fromOffset(274, 376),
    BackgroundColor3 = colors.panel,
    BorderSizePixel = 0,
    Text = "RESTORE ORIGINALS",
    TextColor3 = colors.muted,
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    Parent = mainFrame,
})

corner(restoreButton, 5)
stroke(restoreButton, colors.border, 0.35)

local function bindHover(button, normalColor, hoverColor)
    connect(button.MouseEnter, function()
        if not destroyed then
            button.BackgroundColor3 = hoverColor
        end
    end)

    connect(button.MouseLeave, function()
        if not destroyed then
            button.BackgroundColor3 = normalColor
        end
    end)
end

bindHover(openButton, colors.accent, colors.accentHover)
bindHover(loadButton, colors.accent, colors.accentHover)
bindHover(applyButton, colors.accent, colors.accentHover)
bindHover(closeButton, colors.header, colors.inputHover)
bindHover(selectButton, colors.panel, colors.inputHover)
bindHover(addButton, colors.panel, colors.inputHover)
bindHover(clearButton, colors.panel, colors.inputHover)
bindHover(previousButton, colors.panel, colors.inputHover)
bindHover(nextButton, colors.panel, colors.inputHover)
bindHover(restoreButton, colors.panel, colors.inputHover)

local statusToken = 0

local function setStatus(text, statusType, duration)
    statusToken = statusToken + 1
    local token = statusToken

    statusLabel.Text = text

    if statusType == "success" then
        statusLabel.TextColor3 = colors.success
    elseif statusType == "warning" then
        statusLabel.TextColor3 = colors.warning
    elseif statusType == "error" then
        statusLabel.TextColor3 = colors.error
    else
        statusLabel.TextColor3 = colors.muted
    end

    if duration then
        task.delay(duration, function()
            if destroyed or token ~= statusToken then
                return
            end

            statusLabel.Text = ""
            statusLabel.TextColor3 = colors.muted
        end)
    end
end

local flags = {}
local flagIndexByName = {}
local filteredIndices = {}
local originalValues = {}
local appliedFlags = {}
local currentPage = 1
local PAGE_SIZE = 7
local MAX_FLAGS = 5000
local MAX_BODY_SIZE = 6 * 1024 * 1024
local loading = false
local busy = false
local rowPool = {}

local recognizedPrefixes = {
    "DFFlag",
    "FFlag",
    "DFInt",
    "FInt",
    "DFString",
    "FString",
    "DFLog",
    "FLog",
    "SFFlag",
    "SFInt",
    "SFString",
}

local function isIdentifier(name)
    return type(name) == "string"
        and #name > 0
        and #name <= 220
        and name:match("^[%a_][%w_]*$") ~= nil
end

local function isRecognizedFlagName(name)
    if not isIdentifier(name) then
        return false
    end

    for _, prefix in ipairs(recognizedPrefixes) do
        if name:sub(1, #prefix) == prefix then
            return true
        end
    end

    return false
end

local function rebuildNameIndex()
    table.clear(flagIndexByName)

    for index, item in ipairs(flags) do
        flagIndexByName[item.name] = index
        item.applied = appliedFlags[item.name] == true
    end
end

local function enabledCount()
    local count = 0

    for _, item in ipairs(flags) do
        if item.enabled then
            count = count + 1
        end
    end

    return count
end

local function updateCountLabel()
    local total = #flags
    local enabled = enabledCount()

    countLabel.Text = tostring(total) .. " FLAGS · " .. tostring(enabled) .. " ON"

    if total > 0 and enabled == total then
        selectButton.Text = "NONE"
    else
        selectButton.Text = "ALL"
    end
end

local function rebuildFilter()
    table.clear(filteredIndices)

    local query = trim(searchInput.Text):lower()

    for index, item in ipairs(flags) do
        local matches = query == ""
            or item.name:lower():find(query, 1, true) ~= nil
            or tostring(item.value):lower():find(query, 1, true) ~= nil

        if matches then
            table.insert(filteredIndices, index)
        end
    end

    local pageCount = math.max(1, math.ceil(#filteredIndices / PAGE_SIZE))
    currentPage = math.clamp(currentPage, 1, pageCount)
end

local function updateRowVisual(row, item)
    if not item then
        row.frame.Visible = false
        row.itemIndex = nil
        return
    end

    row.frame.Visible = true
    row.nameInput.Text = item.name
    row.valueInput.Text = tostring(item.value)
    row.enabledButton.Text = item.enabled and "✓" or ""
    row.enabledButton.BackgroundColor3 = item.enabled and colors.accent or colors.input
    row.enabledButton.TextColor3 = item.enabled and colors.text or colors.faint

    if item.error then
        row.nameInput.TextColor3 = colors.error
    elseif item.applied then
        row.nameInput.TextColor3 = colors.success
    else
        row.nameInput.TextColor3 = colors.text
    end
end

local function renderRows()
    rebuildFilter()
    updateCountLabel()

    local pageCount = math.max(1, math.ceil(#filteredIndices / PAGE_SIZE))
    pageLabel.Text = tostring(currentPage) .. " / " .. tostring(pageCount)

    local startIndex = ((currentPage - 1) * PAGE_SIZE) + 1

    for rowNumber, row in ipairs(rowPool) do
        local filteredPosition = startIndex + rowNumber - 1
        local itemIndex = filteredIndices[filteredPosition]
        row.itemIndex = itemIndex
        updateRowVisual(row, itemIndex and flags[itemIndex] or nil)
    end
end

local function removeFlagAt(index)
    if not flags[index] then
        return
    end

    table.remove(flags, index)
    rebuildNameIndex()
    renderRows()
end

for rowNumber = 1, PAGE_SIZE do
    local row = create("Frame", {
        Size = UDim2.new(1, -8, 0, 26),
        Position = UDim2.fromOffset(4, 4 + ((rowNumber - 1) * 28)),
        BackgroundColor3 = colors.input,
        BorderSizePixel = 0,
        Parent = rowsPanel,
    })

    corner(row, 4)

    local enabledButton = create("TextButton", {
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.fromOffset(3, 2),
        BackgroundColor3 = colors.input,
        BorderSizePixel = 0,
        Text = "",
        TextColor3 = colors.text,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Parent = row,
    })

    corner(enabledButton, 4)
    stroke(enabledButton, colors.border, 0.2)

    local nameInput = create("TextBox", {
        Size = UDim2.fromOffset(288, 26),
        Position = UDim2.fromOffset(30, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Flag name",
        PlaceholderColor3 = colors.faint,
        TextColor3 = colors.text,
        TextSize = 11,
        Font = Enum.Font.Code,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    padding(nameInput, 4, 5)

    local valueInput = create("TextBox", {
        Size = UDim2.fromOffset(148, 22),
        Position = UDim2.fromOffset(322, 2),
        BackgroundColor3 = colors.panel,
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = "Value",
        PlaceholderColor3 = colors.faint,
        TextColor3 = colors.text,
        TextSize = 11,
        Font = Enum.Font.Code,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    corner(valueInput, 4)
    padding(valueInput, 7, 7)

    local removeButton = create("TextButton", {
        Size = UDim2.fromOffset(30, 22),
        Position = UDim2.fromOffset(474, 2),
        BackgroundColor3 = colors.panel,
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = colors.faint,
        TextSize = 16,
        Font = Enum.Font.Gotham,
        AutoButtonColor = false,
        Parent = row,
    })

    corner(removeButton, 4)

    local rowData = {
        frame = row,
        enabledButton = enabledButton,
        nameInput = nameInput,
        valueInput = valueInput,
        removeButton = removeButton,
        itemIndex = nil,
    }

    table.insert(rowPool, rowData)

    bindHover(removeButton, colors.panel, colors.error)

    connect(enabledButton.MouseButton1Click, function()
        local index = rowData.itemIndex
        local item = index and flags[index]

        if not item or busy then
            return
        end

        item.enabled = not item.enabled
        renderRows()
    end)

    connect(removeButton.MouseButton1Click, function()
        local index = rowData.itemIndex

        if index and not busy then
            removeFlagAt(index)
        end
    end)

    connect(nameInput.FocusLost, function()
        local index = rowData.itemIndex
        local item = index and flags[index]

        if not item then
            return
        end

        local newName = trim(nameInput.Text)

        if item.applied and newName ~= item.name then
            nameInput.Text = item.name
            setStatus("Restore this flag before renaming it", "warning", 4)
            return
        end

        if not isIdentifier(newName) then
            nameInput.Text = item.name
            setStatus("Invalid flag name", "error", 4)
            return
        end

        local duplicateIndex = flagIndexByName[newName]

        if duplicateIndex and duplicateIndex ~= index then
            nameInput.Text = item.name
            setStatus("This flag already exists", "warning", 4)
            return
        end

        item.name = newName
        item.error = nil
        rebuildNameIndex()
        renderRows()
    end)

    connect(valueInput.FocusLost, function()
        local index = rowData.itemIndex
        local item = index and flags[index]

        if not item then
            return
        end

        local newValue = trim(valueInput.Text)

        if newValue == "" then
            valueInput.Text = tostring(item.value)
            setStatus("Value cannot be empty", "error", 4)
            return
        end

        item.value = newValue
        item.error = nil
        renderRows()
    end)
end

local function normalizeParsedValue(value)
    local valueType = type(value)

    if valueType == "boolean" then
        return value and "true" or "false"
    end

    if valueType == "number" then
        return tostring(value)
    end

    if valueType ~= "string" then
        return nil
    end

    local result = trim(value)

    result = result:gsub("%s+%-%-.*$", "")
    result = result:gsub("%s+//.*$", "")
    result = trim(result)
    result = result:gsub("[,;]+$", "")
    result = trim(result)

    local wrapped = result:match("^tostring%s*%((.*)%)$")

    if wrapped then
        result = trim(wrapped)
    end

    if #result >= 2 then
        local firstCharacter = result:sub(1, 1)
        local lastCharacter = result:sub(-1)

        if firstCharacter == "\"" and lastCharacter == "\"" then
            local success, decoded = pcall(function()
                return HttpService:JSONDecode(result)
            end)

            if success and type(decoded) == "string" then
                result = decoded
            else
                result = result:sub(2, -2)
            end
        elseif firstCharacter == "'" and lastCharacter == "'" then
            result = result:sub(2, -2)
            result = result:gsub("\\'", "'")
            result = result:gsub("\\\\", "\\")
        end
    end

    local lower = result:lower()

    if lower == "nil" or lower == "null" or result == "" then
        return nil
    end

    if lower == "true" or lower == "false" then
        return lower
    end

    if #result > 1000 then
        return result:sub(1, 1000)
    end

    return result
end

local function parseFlags(text)
    local parsed = {}
    local parsedIndex = {}
    local jsonMatches = 0
    local textMatches = 0

    local function addFlag(name, value, source)
        name = trim(name)

        if #parsed >= MAX_FLAGS or not isRecognizedFlagName(name) then
            return false
        end

        local normalizedValue = normalizeParsedValue(value)

        if normalizedValue == nil then
            return false
        end

        local existingIndex = parsedIndex[name]

        if existingIndex then
            parsed[existingIndex].value = normalizedValue
            return false
        end

        table.insert(parsed, {
            name = name,
            value = normalizedValue,
            enabled = true,
            applied = appliedFlags[name] == true,
            error = nil,
        })

        parsedIndex[name] = #parsed

        if source == "json" then
            jsonMatches = jsonMatches + 1
        else
            textMatches = textMatches + 1
        end

        return true
    end

    local cleanedText = text:gsub("^\239\187\191", "")
    local jsonSuccess, decoded = pcall(function()
        return HttpService:JSONDecode(cleanedText)
    end)

    if jsonSuccess and type(decoded) == "table" then
        local function walk(value, depth)
            if depth > 12 or #parsed >= MAX_FLAGS or type(value) ~= "table" then
                return
            end

            local possibleName = rawget(value, "name")
                or rawget(value, "flag")
                or rawget(value, "key")

            local possibleValue = rawget(value, "value")

            if type(possibleName) == "string" and possibleValue ~= nil then
                addFlag(possibleName, possibleValue, "json")
            end

            for key, child in pairs(value) do
                if type(key) == "string"
                    and isRecognizedFlagName(key)
                    and type(child) ~= "table" then

                    addFlag(key, child, "json")
                elseif type(child) == "table" then
                    walk(child, depth + 1)
                end
            end
        end

        walk(decoded, 0)
    end

    for line in cleanedText:gmatch("[^\r\n]+") do
        local cleanLine = trim(line)
        local name
        local value

        name, value = cleanLine:match("setfflag%s*%(%s*[\"']([%w_]+)[\"']%s*,%s*(.-)%s*%)")

        if not name then
            name, value = cleanLine:match("%[%s*[\"']([%w_]+)[\"']%s*%]%s*=%s*(.-)%s*[,;]?%s*$")
        end

        if not name then
            name, value = cleanLine:match("^%s*[\"']([%w_]+)[\"']%s*:%s*(.-)%s*[,}]?%s*$")
        end

        if not name then
            name, value = cleanLine:match("^%s*([%w_]+)%s*[=:]%s*(.-)%s*[,;]?%s*$")
        end

        if not name then
            local possibleName, possibleValue = cleanLine:match("^%s*([%w_]+)%s+(.+)%s*$")

            if possibleName and isRecognizedFlagName(possibleName) then
                name = possibleName
                value = possibleValue
            end
        end

        if name and value then
            addFlag(name, value, "text")
        end

        if #parsed >= MAX_FLAGS then
            break
        end
    end

    if #parsed == 0 then
        for name, value in cleanedText:gmatch("%[%s*[\"']([%w_]+)[\"']%s*%]%s*=%s*([^,%r%n}]+)") do
            addFlag(name, value, "text")

            if #parsed >= MAX_FLAGS then
                break
            end
        end
    end

    table.sort(parsed, function(left, right)
        return left.name:lower() < right.name:lower()
    end)

    local formatName = "TEXT"

    if jsonMatches > 0 and textMatches > 0 then
        formatName = "JSON/TEXT"
    elseif jsonMatches > 0 then
        formatName = "JSON"
    end

    return parsed, formatName
end

local function normalizeGithubUrl(value)
    local url = trim(value)

    if url == "" then
        return nil, "Paste a GitHub URL"
    end

    url = url:gsub("#.*$", "")
    url = url:gsub("%?raw=1$", "")

    local owner, repository, path = url:match("^https://github%.com/([^/]+)/([^/]+)/blob/(.+)$")

    if owner and repository and path then
        return "https://raw.githubusercontent.com/"
            .. owner
            .. "/"
            .. repository
            .. "/"
            .. path
    end

    owner, repository, path = url:match("^https://github%.com/([^/]+)/([^/]+)/raw/(.+)$")

    if owner and repository and path then
        return "https://raw.githubusercontent.com/"
            .. owner
            .. "/"
            .. repository
            .. "/"
            .. path
    end

    if url:match("^https://raw%.githubusercontent%.com/") then
        return url
    end

    if url:match("^https://gist%.githubusercontent%.com/") then
        return url
    end

    return nil, "Only GitHub RAW or GitHub /blob/ links are accepted"
end

local function fetchText(url)
    local requestError

    if typeof(requestFunction) == "function" then
        local success, response = pcall(requestFunction, {
            Url = url,
            Method = "GET",
            Headers = {
                ["Accept"] = "text/plain, application/json, */*",
                ["User-Agent"] = "Average-FFlag-Editor",
                ["Cache-Control"] = "no-cache",
            },
        })

        if success then
            if type(response) == "string" and response ~= "" then
                return true, response
            end

            if type(response) == "table" then
                local statusCode = tonumber(response.StatusCode or response.Status or response.status_code)
                local body = response.Body or response.body or response.ResponseBody

                if type(body) == "string"
                    and body ~= ""
                    and (not statusCode or (statusCode >= 200 and statusCode < 300)) then

                    return true, body
                end

                requestError = "HTTP " .. tostring(statusCode or "error")
            end
        else
            requestError = tostring(response)
        end
    end

    local success, body = pcall(function()
        return game:HttpGet(url, true)
    end)

    if success and type(body) == "string" and body ~= "" then
        return true, body
    end

    return false, requestError or tostring(body)
end

local function loadRaw()
    if loading or busy then
        return
    end

    local normalizedUrl, urlError = normalizeGithubUrl(urlInput.Text)

    if not normalizedUrl then
        setStatus(urlError, "error", 5)
        return
    end

    loading = true
    loadButton.Text = "LOADING"
    setStatus("Downloading RAW...", "normal")

    task.spawn(function()
        local success, bodyOrError = fetchText(normalizedUrl)

        if destroyed then
            return
        end

        if not success then
            loading = false
            loadButton.Text = "LOAD RAW"
            setStatus("Download failed: " .. tostring(bodyOrError), "error")
            return
        end

        if #bodyOrError > MAX_BODY_SIZE then
            loading = false
            loadButton.Text = "LOAD RAW"
            setStatus("RAW is larger than 6 MB", "error")
            return
        end

        setStatus("Parsing flags...", "normal")

        local parsedFlags, formatName = parseFlags(bodyOrError)

        loading = false
        loadButton.Text = "LOAD RAW"

        if #parsedFlags == 0 then
            setStatus("No supported FFlags were found", "warning")
            return
        end

        flags = parsedFlags
        currentPage = 1
        searchInput.Text = ""
        urlInput.Text = normalizedUrl
        environment[LAST_URL_KEY] = normalizedUrl

        rebuildNameIndex()
        renderRows()

        local suffix = #parsedFlags >= MAX_FLAGS and " · LIMIT REACHED" or ""
        setStatus(
            tostring(#parsedFlags) .. " flags loaded · " .. formatName .. suffix,
            "success"
        )
    end)
end

local function readOriginalValue(flagName)
    if typeof(getFlagFunction) == "function" then
        local success, value = pcall(getFlagFunction, flagName)

        if success then
            return true, value
        end
    end

    local isBooleanFlag = flagName:find("Flag", 1, true) ~= nil

    if isBooleanFlag then
        local success, value = pcall(function()
            return settings():GetFFlag(flagName)
        end)

        if success then
            return true, value
        end
    end

    local success, value = pcall(function()
        return settings():GetFVariable(flagName)
    end)

    if success then
        return true, value
    end

    return false, nil
end

local function writeFlag(flagName, value)
    if typeof(setFlagFunction) ~= "function" then
        return false, "setfflag is unavailable"
    end

    local success, result = pcall(setFlagFunction, flagName, tostring(value))

    if not success then
        return false, tostring(result)
    end

    if result == false then
        return false, "setfflag returned false"
    end

    return true
end

local function applyEnabledFlags()
    if busy or loading then
        return
    end

    if typeof(setFlagFunction) ~= "function" then
        setStatus("This executor does not provide setfflag", "error")
        return
    end

    local totalEnabled = enabledCount()

    if totalEnabled == 0 then
        setStatus("No flags are enabled", "warning", 4)
        return
    end

    busy = true
    applyButton.Text = "APPLYING 0/" .. tostring(totalEnabled)
    setStatus("Applying enabled flags...", "normal")

    task.spawn(function()
        local appliedCount = 0
        local failedCount = 0
        local processedCount = 0
        local firstError

        for _, item in ipairs(flags) do
            if item.enabled then
                processedCount = processedCount + 1
                applyButton.Text = "APPLYING "
                    .. tostring(processedCount)
                    .. "/"
                    .. tostring(totalEnabled)

                if originalValues[item.name] == nil then
                    local readable, originalValue = readOriginalValue(item.name)

                    originalValues[item.name] = {
                        readable = readable,
                        value = originalValue,
                    }
                end

                local success, errorMessage = writeFlag(item.name, item.value)

                if success then
                    appliedFlags[item.name] = true
                    item.applied = true
                    item.error = nil
                    appliedCount = appliedCount + 1
                else
                    item.error = tostring(errorMessage)
                    failedCount = failedCount + 1

                    if not firstError then
                        firstError = item.name .. ": " .. tostring(errorMessage)
                    end
                end

                if processedCount % 40 == 0 then
                    task.wait()
                end
            end
        end

        busy = false
        applyButton.Text = "APPLY ENABLED"
        rebuildNameIndex()
        renderRows()

        if failedCount == 0 then
            setStatus(tostring(appliedCount) .. " flags applied", "success")
        else
            local message = tostring(appliedCount)
                .. " applied · "
                .. tostring(failedCount)
                .. " failed"

            if firstError then
                message = message .. " · " .. firstError
            end

            setStatus(message, "warning")
        end
    end)
end

local function restoreOriginalFlags()
    if busy or loading then
        return
    end

    if typeof(setFlagFunction) ~= "function" then
        setStatus("This executor does not provide setfflag", "error")
        return
    end

    local names = {}

    for name in pairs(appliedFlags) do
        table.insert(names, name)
    end

    if #names == 0 then
        setStatus("Nothing from this session is applied", "warning", 4)
        return
    end

    table.sort(names)
    busy = true
    restoreButton.Text = "RESTORING 0/" .. tostring(#names)
    setStatus("Restoring captured values...", "normal")

    task.spawn(function()
        local restoredCount = 0
        local unavailableCount = 0
        local failedCount = 0
        local firstError

        for index, name in ipairs(names) do
            restoreButton.Text = "RESTORING "
                .. tostring(index)
                .. "/"
                .. tostring(#names)

            local original = originalValues[name]

            if original and original.readable then
                local success, errorMessage = writeFlag(name, original.value)

                if success then
                    appliedFlags[name] = nil
                    originalValues[name] = nil
                    restoredCount = restoredCount + 1
                else
                    failedCount = failedCount + 1

                    if not firstError then
                        firstError = name .. ": " .. tostring(errorMessage)
                    end
                end
            else
                unavailableCount = unavailableCount + 1
            end

            if index % 40 == 0 then
                task.wait()
            end
        end

        busy = false
        restoreButton.Text = "RESTORE ORIGINALS"
        rebuildNameIndex()
        renderRows()

        local message = tostring(restoredCount) .. " restored"

        if unavailableCount > 0 then
            message = message .. " · " .. tostring(unavailableCount) .. " unknown originals"
        end

        if failedCount > 0 then
            message = message .. " · " .. tostring(failedCount) .. " failed"

            if firstError then
                message = message .. " · " .. firstError
            end
        end

        if unavailableCount > 0 or failedCount > 0 then
            setStatus(message, "warning")
        else
            setStatus(message, "success")
        end
    end)
end

local function addManualFlag()
    if busy then
        return
    end

    local baseName = "FFlagNewFlag"
    local name = baseName
    local number = 1

    while flagIndexByName[name] do
        number = number + 1
        name = baseName .. tostring(number)
    end

    table.insert(flags, {
        name = name,
        value = "true",
        enabled = true,
        applied = false,
        error = nil,
    })

    rebuildNameIndex()
    searchInput.Text = ""
    rebuildFilter()
    currentPage = math.max(1, math.ceil(#filteredIndices / PAGE_SIZE))
    renderRows()

    task.defer(function()
        for _, row in ipairs(rowPool) do
            if row.itemIndex and flags[row.itemIndex] and flags[row.itemIndex].name == name then
                row.nameInput:CaptureFocus()
                row.nameInput.CursorPosition = #row.nameInput.Text + 1
                break
            end
        end
    end)
end

local function clearList()
    if busy then
        return
    end

    table.clear(flags)
    table.clear(flagIndexByName)
    table.clear(filteredIndices)
    currentPage = 1
    searchInput.Text = ""
    renderRows()
    setStatus("Editor list cleared", "normal", 3)
end

connect(loadButton.MouseButton1Click, loadRaw)

connect(urlInput.FocusLost, function(enterPressed)
    if enterPressed then
        loadRaw()
    end
end)

connect(searchInput:GetPropertyChangedSignal("Text"), function()
    currentPage = 1
    renderRows()
end)

connect(previousButton.MouseButton1Click, function()
    if currentPage > 1 then
        currentPage = currentPage - 1
        renderRows()
    end
end)

connect(nextButton.MouseButton1Click, function()
    local pageCount = math.max(1, math.ceil(#filteredIndices / PAGE_SIZE))

    if currentPage < pageCount then
        currentPage = currentPage + 1
        renderRows()
    end
end)

connect(selectButton.MouseButton1Click, function()
    if busy or #flags == 0 then
        return
    end

    local shouldEnable = enabledCount() ~= #flags

    for _, item in ipairs(flags) do
        item.enabled = shouldEnable
    end

    renderRows()
    setStatus(shouldEnable and "All flags enabled" or "All flags disabled", "normal", 3)
end)

connect(addButton.MouseButton1Click, addManualFlag)
connect(clearButton.MouseButton1Click, clearList)
connect(applyButton.MouseButton1Click, applyEnabledFlags)
connect(restoreButton.MouseButton1Click, restoreOriginalFlags)

local guiVisible = true

local function setVisible(visible)
    guiVisible = visible
    mainFrame.Visible = visible
    openButton.Visible = not visible
end

connect(closeButton.MouseButton1Click, function()
    setVisible(false)
end)

connect(openButton.MouseButton1Click, function()
    setVisible(true)
end)

connect(UserInputService.InputBegan, function(input, gameProcessed)
    local focusedTextBox = UserInputService:GetFocusedTextBox()
    local controlDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
        or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)

    if input.KeyCode == Enum.KeyCode.Insert then
        setVisible(not guiVisible)
        return
    end

    if input.KeyCode == Enum.KeyCode.Escape and not focusedTextBox and guiVisible then
        setVisible(false)
        return
    end

    if controlDown and input.KeyCode == Enum.KeyCode.F then
        setVisible(true)
        searchInput:CaptureFocus()
        return
    end

    if controlDown and input.KeyCode == Enum.KeyCode.L then
        setVisible(true)
        urlInput:CaptureFocus()
        return
    end

    if controlDown and input.KeyCode == Enum.KeyCode.Return then
        applyEnabledFlags()
        return
    end

    if gameProcessed or focusedTextBox then
        return
    end

    if input.KeyCode == Enum.KeyCode.PageUp and currentPage > 1 then
        currentPage = currentPage - 1
        renderRows()
    elseif input.KeyCode == Enum.KeyCode.PageDown then
        local pageCount = math.max(1, math.ceil(#filteredIndices / PAGE_SIZE))

        if currentPage < pageCount then
            currentPage = currentPage + 1
            renderRows()
        end
    end
end)

local dragging = false
local dragStart
local startPosition
local dragInput

connect(header.InputBegan, function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end

    dragging = true
    dragStart = input.Position
    startPosition = mainFrame.Position
end)

connect(header.InputChanged, function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

connect(UserInputService.InputChanged, function(input)
    if not dragging or input ~= dragInput then
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
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

renderRows()

if typeof(setFlagFunction) == "function" then
    setStatus("Ready · setfflag detected", "success")
else
    setStatus("RAW loader ready · setfflag unavailable", "warning")
end
