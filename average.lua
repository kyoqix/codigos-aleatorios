local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
if not player then
    return
end

local function getEnvironment()
    if typeof(getgenv) == "function" then
        local success, result = pcall(getgenv)

        if success and type(result) == "table" then
            return result
        end
    end

    return _G
end

local environment = getEnvironment()

local function lookup(name)
    local value = environment[name]

    if value ~= nil then
        return value
    end

    return rawget(_G, name)
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

local SESSION_KEY = "__AVERAGE_FFLAG_EDITOR_BW_SESSION"
local LAST_URL_KEY = "__AVERAGE_FFLAG_EDITOR_LAST_URL"
local LEGACY_SESSION_KEYS = {
    "__AVERAGE_FFLAG_EDITOR_SESSION",
    "__AVERAGE_FFLAG_EDITOR_V2_SESSION",
    SESSION_KEY,
}

for _, key in ipairs(LEGACY_SESSION_KEYS) do
    local oldSession = environment[key]

    if type(oldSession) == "table" and typeof(oldSession.destroy) == "function" then
        pcall(oldSession.destroy)
    end
end

local setFlagFunction = firstFunction(lookup("setfflag"))
local getFlagFunction = firstFunction(lookup("getfflag"))
local synEnvironment = lookup("syn")
local fluxusEnvironment = lookup("fluxus")

local requestFunction = firstFunction(
    lookup("request"),
    lookup("http_request"),
    lookup("httprequest"),
    type(synEnvironment) == "table" and synEnvironment.request or nil,
    type(fluxusEnvironment) == "table" and fluxusEnvironment.request or nil
)

local guiParent = player:WaitForChild("PlayerGui")
local getHiddenUi = lookup("gethui")

if typeof(getHiddenUi) == "function" then
    local success, result = pcall(getHiddenUi)

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

for _, name in ipairs({
    "AverageFFlagEditor",
    "AverageFFlagEditorV2",
    "AverageFFlagEditorBW",
}) do
    local oldGui = guiParent:FindFirstChild(name)

    if oldGui then
        oldGui:Destroy()
    end
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
    if radius <= 0 then
        return nil
    end

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

local function addPadding(instance, left, right, top, bottom)
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
    background = Color3.fromRGB(7, 7, 7),
    header = Color3.fromRGB(11, 11, 11),
    panel = Color3.fromRGB(14, 14, 14),
    field = Color3.fromRGB(19, 19, 19),
    hover = Color3.fromRGB(26, 26, 26),
    line = Color3.fromRGB(48, 48, 48),
    lineBright = Color3.fromRGB(86, 86, 86),
    text = Color3.fromRGB(242, 242, 242),
    muted = Color3.fromRGB(154, 154, 154),
    faint = Color3.fromRGB(92, 92, 92),
    white = Color3.fromRGB(244, 244, 244),
    black = Color3.fromRGB(5, 5, 5),
}

local function makeLabel(parent, text, position, size, options)
    options = options or {}

    return create("TextLabel", {
        Position = position,
        Size = size,
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = options.color or colors.text,
        TextSize = options.textSize or 11,
        Font = options.font or Enum.Font.Gotham,
        TextXAlignment = options.xAlignment or Enum.TextXAlignment.Left,
        TextYAlignment = options.yAlignment or Enum.TextYAlignment.Center,
        TextTruncate = options.truncate or Enum.TextTruncate.None,
        Parent = parent,
    })
end

local function makeButton(parent, text, position, size, primary)
    local button = create("TextButton", {
        Position = position,
        Size = size,
        BackgroundColor3 = primary and colors.white or colors.panel,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = primary and colors.black or colors.text,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Parent = parent,
    })

    addCorner(button, 2)
    addStroke(button, primary and colors.white or colors.line, primary and 0 or 0.15)

    return button
end

local function makeInput(parent, placeholder, position, size, codeFont)
    local input = create("TextBox", {
        Position = position,
        Size = size,
        BackgroundColor3 = colors.field,
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = placeholder,
        PlaceholderColor3 = colors.faint,
        TextColor3 = colors.text,
        TextSize = 11,
        Font = codeFont and Enum.Font.Code or Enum.Font.Gotham,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = parent,
    })

    addCorner(input, 2)
    addStroke(input, colors.line, 0.15)
    addPadding(input, 8, 8)

    return input
end

screenGui = create("ScreenGui", {
    Name = "AverageFFlagEditorBW",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = guiParent,
})

local openButton = makeButton(
    screenGui,
    "FF",
    UDim2.new(1, -50, 0, 12),
    UDim2.fromOffset(38, 26),
    true
)
openButton.Visible = false

local mainFrame = create("Frame", {
    Name = "Window",
    Size = UDim2.fromOffset(560, 402),
    Position = UDim2.new(0.5, -280, 0.5, -201),
    BackgroundColor3 = colors.background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Active = true,
    Parent = screenGui,
})

addStroke(mainFrame, colors.lineBright, 0.2)

local header = create("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 34),
    BackgroundColor3 = colors.header,
    BorderSizePixel = 0,
    Active = true,
    Parent = mainFrame,
})

makeLabel(
    header,
    "FFLAG EDITOR",
    UDim2.fromOffset(12, 0),
    UDim2.new(1, -180, 1, 0),
    {
        textSize = 12,
        font = Enum.Font.GothamBold,
    }
)

local engineLabel = makeLabel(
    header,
    typeof(setFlagFunction) == "function" and "SETFFLAG READY" or "NO SETFFLAG",
    UDim2.new(1, -170, 0, 0),
    UDim2.fromOffset(126, 34),
    {
        color = typeof(setFlagFunction) == "function" and colors.muted or colors.faint,
        textSize = 9,
        font = Enum.Font.GothamBold,
        xAlignment = Enum.TextXAlignment.Right,
    }
)

local closeButton = create("TextButton", {
    Size = UDim2.fromOffset(34, 34),
    Position = UDim2.new(1, -34, 0, 0),
    BackgroundColor3 = colors.header,
    BorderSizePixel = 0,
    Text = "×",
    TextColor3 = colors.muted,
    TextSize = 18,
    Font = Enum.Font.Gotham,
    AutoButtonColor = false,
    Parent = header,
})

local urlInput = makeInput(
    mainFrame,
    "GitHub RAW or github.com/.../blob/...",
    UDim2.fromOffset(12, 44),
    UDim2.fromOffset(430, 28),
    true
)
urlInput.Text = type(environment[LAST_URL_KEY]) == "string" and environment[LAST_URL_KEY] or ""

local loadButton = makeButton(
    mainFrame,
    "LOAD RAW",
    UDim2.fromOffset(450, 44),
    UDim2.fromOffset(98, 28),
    true
)

local searchInput = makeInput(
    mainFrame,
    "Search flags  Ctrl+F",
    UDim2.fromOffset(12, 80),
    UDim2.fromOffset(264, 26),
    false
)

local countLabel = makeLabel(
    mainFrame,
    "0 FLAGS",
    UDim2.fromOffset(286, 80),
    UDim2.fromOffset(110, 26),
    {
        color = colors.muted,
        textSize = 9,
        font = Enum.Font.GothamBold,
    }
)

local selectButton = makeButton(
    mainFrame,
    "ALL",
    UDim2.fromOffset(396, 80),
    UDim2.fromOffset(54, 26),
    false
)

local addButton = makeButton(
    mainFrame,
    "+",
    UDim2.fromOffset(456, 80),
    UDim2.fromOffset(32, 26),
    false
)
addButton.TextSize = 16

local clearButton = makeButton(
    mainFrame,
    "CLR",
    UDim2.fromOffset(494, 80),
    UDim2.fromOffset(54, 26),
    false
)
clearButton.TextColor3 = colors.muted

makeLabel(mainFrame, "ON", UDim2.fromOffset(16, 108), UDim2.fromOffset(24, 16), {
    color = colors.faint,
    textSize = 8,
    font = Enum.Font.GothamBold,
    xAlignment = Enum.TextXAlignment.Center,
})

makeLabel(mainFrame, "FLAG", UDim2.fromOffset(46, 108), UDim2.fromOffset(300, 16), {
    color = colors.faint,
    textSize = 8,
    font = Enum.Font.GothamBold,
})

makeLabel(mainFrame, "VALUE", UDim2.fromOffset(350, 108), UDim2.fromOffset(158, 16), {
    color = colors.faint,
    textSize = 8,
    font = Enum.Font.GothamBold,
})

local rowsPanel = create("Frame", {
    Size = UDim2.fromOffset(536, 198),
    Position = UDim2.fromOffset(12, 126),
    BackgroundColor3 = colors.panel,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = mainFrame,
})

addStroke(rowsPanel, colors.line, 0.15)

local previousButton = makeButton(
    mainFrame,
    "<",
    UDim2.fromOffset(12, 332),
    UDim2.fromOffset(26, 22),
    false
)

local pageLabel = makeLabel(
    mainFrame,
    "1 / 1",
    UDim2.fromOffset(42, 332),
    UDim2.fromOffset(62, 22),
    {
        color = colors.muted,
        textSize = 9,
        font = Enum.Font.GothamMedium,
        xAlignment = Enum.TextXAlignment.Center,
    }
)

local nextButton = makeButton(
    mainFrame,
    ">",
    UDim2.fromOffset(108, 332),
    UDim2.fromOffset(26, 22),
    false
)

local statusLabel = makeLabel(
    mainFrame,
    "",
    UDim2.fromOffset(144, 332),
    UDim2.fromOffset(404, 22),
    {
        color = colors.muted,
        textSize = 9,
        xAlignment = Enum.TextXAlignment.Right,
        truncate = Enum.TextTruncate.AtEnd,
    }
)

local applyButton = makeButton(
    mainFrame,
    "APPLY ENABLED",
    UDim2.fromOffset(12, 362),
    UDim2.fromOffset(264, 28),
    true
)

local restoreButton = makeButton(
    mainFrame,
    "RESTORE ORIGINALS",
    UDim2.fromOffset(284, 362),
    UDim2.fromOffset(264, 28),
    false
)
restoreButton.TextColor3 = colors.muted

local function bindHover(button, normalColor, hoverColor, normalText, hoverText)
    connect(button.MouseEnter, function()
        if destroyed then
            return
        end

        button.BackgroundColor3 = hoverColor

        if hoverText then
            button.TextColor3 = hoverText
        end
    end)

    connect(button.MouseLeave, function()
        if destroyed then
            return
        end

        button.BackgroundColor3 = normalColor

        if normalText then
            button.TextColor3 = normalText
        end
    end)
end

bindHover(openButton, colors.white, colors.text, colors.black, colors.black)
bindHover(loadButton, colors.white, colors.text, colors.black, colors.black)
bindHover(applyButton, colors.white, colors.text, colors.black, colors.black)
bindHover(closeButton, colors.header, colors.hover, colors.muted, colors.text)
bindHover(selectButton, colors.panel, colors.hover, colors.text, colors.text)
bindHover(addButton, colors.panel, colors.hover, colors.text, colors.text)
bindHover(clearButton, colors.panel, colors.hover, colors.muted, colors.text)
bindHover(previousButton, colors.panel, colors.hover, colors.text, colors.text)
bindHover(nextButton, colors.panel, colors.hover, colors.text, colors.text)
bindHover(restoreButton, colors.panel, colors.hover, colors.muted, colors.text)

local statusToken = 0

local function setStatus(text, statusType, duration)
    statusToken = statusToken + 1
    local token = statusToken
    local prefix = ""

    if statusType == "success" then
        prefix = "OK  "
        statusLabel.TextColor3 = colors.text
    elseif statusType == "warning" then
        prefix = "NOTE  "
        statusLabel.TextColor3 = colors.muted
    elseif statusType == "error" then
        prefix = "ERR  "
        statusLabel.TextColor3 = colors.text
    else
        statusLabel.TextColor3 = colors.muted
    end

    statusLabel.Text = prefix .. tostring(text or "")

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
        item.applied = appliedFlags[item.name] ~= nil
    end
end

local function getEnabledCount()
    local count = 0

    for _, item in ipairs(flags) do
        if item.enabled then
            count = count + 1
        end
    end

    return count
end

local function updateCount()
    local enabled = getEnabledCount()
    countLabel.Text = tostring(#flags) .. " FLAGS  " .. tostring(enabled) .. " ON"
    selectButton.Text = #flags > 0 and enabled == #flags and "NONE" or "ALL"
end

local function rebuildFilter()
    table.clear(filteredIndices)

    local query = trim(searchInput.Text):lower()

    for index, item in ipairs(flags) do
        local match = query == ""
            or item.name:lower():find(query, 1, true) ~= nil
            or tostring(item.value):lower():find(query, 1, true) ~= nil

        if match then
            table.insert(filteredIndices, index)
        end
    end

    local pageCount = math.max(1, math.ceil(#filteredIndices / PAGE_SIZE))
    currentPage = math.clamp(currentPage, 1, pageCount)
end

local function updateRow(row, item)
    if not item then
        row.frame.Visible = false
        row.itemIndex = nil
        return
    end

    row.frame.Visible = true
    row.nameInput.Text = item.name
    row.valueInput.Text = tostring(item.value)
    row.enabledButton.Text = item.enabled and "X" or ""
    row.enabledButton.BackgroundColor3 = item.enabled and colors.white or colors.field
    row.enabledButton.TextColor3 = item.enabled and colors.black or colors.text

    if item.state == "failed" then
        row.nameInput.TextColor3 = colors.muted
        row.stateLabel.Text = "!"
    elseif item.state == "verified" then
        row.nameInput.TextColor3 = colors.text
        row.stateLabel.Text = "V"
    elseif item.state == "sent" or item.state == "unconfirmed" then
        row.nameInput.TextColor3 = colors.text
        row.stateLabel.Text = "S"
    else
        row.nameInput.TextColor3 = item.enabled and colors.text or colors.muted
        row.stateLabel.Text = ""
    end

    row.stateLabel.TextColor3 = item.state == "failed" and colors.muted or colors.faint
end

local function renderRows()
    rebuildFilter()
    updateCount()

    local pageCount = math.max(1, math.ceil(#filteredIndices / PAGE_SIZE))
    pageLabel.Text = tostring(currentPage) .. " / " .. tostring(pageCount)

    local startIndex = ((currentPage - 1) * PAGE_SIZE) + 1

    for rowNumber, row in ipairs(rowPool) do
        local filteredPosition = startIndex + rowNumber - 1
        local itemIndex = filteredIndices[filteredPosition]
        row.itemIndex = itemIndex
        updateRow(row, itemIndex and flags[itemIndex] or nil)
    end
end

local function removeFlagAt(index)
    local item = flags[index]

    if not item then
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
        BackgroundColor3 = colors.field,
        BorderSizePixel = 0,
        Parent = rowsPanel,
    })

    addStroke(row, colors.line, 0.45)

    local enabledButton = create("TextButton", {
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.fromOffset(3, 3),
        BackgroundColor3 = colors.field,
        BorderSizePixel = 0,
        Text = "",
        TextColor3 = colors.text,
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Parent = row,
    })

    addStroke(enabledButton, colors.lineBright, 0.1)

    local nameInput = create("TextBox", {
        Size = UDim2.fromOffset(292, 26),
        Position = UDim2.fromOffset(28, 0),
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

    addPadding(nameInput, 4, 4)

    local valueInput = create("TextBox", {
        Size = UDim2.fromOffset(154, 20),
        Position = UDim2.fromOffset(324, 3),
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

    addStroke(valueInput, colors.line, 0.45)
    addPadding(valueInput, 6, 6)

    local stateLabel = makeLabel(
        row,
        "",
        UDim2.fromOffset(481, 0),
        UDim2.fromOffset(18, 26),
        {
            color = colors.faint,
            textSize = 8,
            font = Enum.Font.GothamBold,
            xAlignment = Enum.TextXAlignment.Center,
        }
    )

    local removeButton = create("TextButton", {
        Size = UDim2.fromOffset(28, 20),
        Position = UDim2.fromOffset(500, 3),
        BackgroundColor3 = colors.panel,
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = colors.faint,
        TextSize = 15,
        Font = Enum.Font.Gotham,
        AutoButtonColor = false,
        Parent = row,
    })

    addStroke(removeButton, colors.line, 0.45)

    local rowData = {
        frame = row,
        enabledButton = enabledButton,
        nameInput = nameInput,
        valueInput = valueInput,
        stateLabel = stateLabel,
        removeButton = removeButton,
        itemIndex = nil,
    }

    table.insert(rowPool, rowData)
    bindHover(removeButton, colors.panel, colors.hover, colors.faint, colors.text)

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
            setStatus("Restore the flag before renaming it", "warning", 4)
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
            setStatus("Flag already exists", "warning", 4)
            return
        end

        item.name = newName
        item.state = nil
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
        item.state = nil
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

    if result == "" or lower == "nil" or lower == "null" then
        return nil
    end

    if lower == "true" or lower == "false" then
        return lower
    end

    if #result > 1000 then
        result = result:sub(1, 1000)
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
            applied = appliedFlags[name] ~= nil,
            state = nil,
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
    url = url:gsub("%?.*$", "")

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

    return nil, "Only GitHub RAW or GitHub blob links are accepted"
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
    setStatus("Downloading RAW", "normal")

    task.spawn(function()
        local success, bodyOrError = fetchText(normalizedUrl)

        if destroyed then
            return
        end

        if not success then
            loading = false
            loadButton.Text = "LOAD RAW"
            setStatus("Download failed  " .. tostring(bodyOrError), "error")
            return
        end

        if #bodyOrError > MAX_BODY_SIZE then
            loading = false
            loadButton.Text = "LOAD RAW"
            setStatus("RAW is larger than 6 MB", "error")
            return
        end

        setStatus("Parsing flags", "normal")

        local parsedFlags, formatName = parseFlags(bodyOrError)

        loading = false
        loadButton.Text = "LOAD RAW"

        if #parsedFlags == 0 then
            setStatus("No supported flags found", "warning")
            return
        end

        flags = parsedFlags
        currentPage = 1
        searchInput.Text = ""
        urlInput.Text = normalizedUrl
        environment[LAST_URL_KEY] = normalizedUrl

        rebuildNameIndex()
        renderRows()

        local suffix = #parsedFlags >= MAX_FLAGS and "  LIMIT" or ""
        setStatus(tostring(#parsedFlags) .. " flags loaded  " .. formatName .. suffix, "success")
    end)
end

local function canonicalValue(value)
    local text = trim(value)
    local lower = text:lower()

    if lower == "true" or lower == "false" then
        return "boolean", lower
    end

    local number = tonumber(text)

    if number ~= nil then
        return "number", number
    end

    return "string", text
end

local function valuesEquivalent(left, right)
    local leftType, leftValue = canonicalValue(left)
    local rightType, rightValue = canonicalValue(right)

    if leftType == rightType then
        return leftValue == rightValue
    end

    return tostring(leftValue) == tostring(rightValue)
end

local function readFlagValue(flagName)
    if typeof(getFlagFunction) == "function" then
        local success, value = pcall(getFlagFunction, flagName)

        if success and value ~= nil then
            return true, value, "executor"
        end
    end

    if flagName:find("Flag", 1, true) ~= nil then
        local success, value = pcall(function()
            return settings():GetFFlag(flagName)
        end)

        if success and value ~= nil then
            return true, value, "settings"
        end
    end

    local success, value = pcall(function()
        return settings():GetFVariable(flagName)
    end)

    if success and value ~= nil then
        return true, value, "settings"
    end

    return false, nil, nil
end

local function writeFlag(flagName, value)
    if typeof(setFlagFunction) ~= "function" then
        return false, "failed", "setfflag is unavailable"
    end

    local success, result = pcall(setFlagFunction, flagName, tostring(value))

    if not success then
        return false, "failed", tostring(result)
    end

    local readable, currentValue = readFlagValue(flagName)

    if readable then
        if valuesEquivalent(currentValue, value) then
            return true, "verified", nil
        end

        return true, "unconfirmed", "readback did not match"
    end

    return true, "sent", nil
end

local function captureOriginalValue(flagName)
    if originalValues[flagName] ~= nil then
        return
    end

    local readable, value = readFlagValue(flagName)

    originalValues[flagName] = {
        readable = readable,
        value = value,
    }
end

local function applyEnabledFlags()
    if busy or loading then
        return
    end

    if typeof(setFlagFunction) ~= "function" then
        setStatus("Executor does not provide setfflag", "error")
        return
    end

    local totalEnabled = getEnabledCount()

    if totalEnabled == 0 then
        setStatus("No flags enabled", "warning", 4)
        return
    end

    busy = true
    applyButton.Text = "APPLYING 0/" .. tostring(totalEnabled)
    setStatus("Applying enabled flags", "normal")

    task.spawn(function()
        local sentCount = 0
        local verifiedCount = 0
        local unconfirmedCount = 0
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

                captureOriginalValue(item.name)

                local success, state, errorMessage = writeFlag(item.name, item.value)
                item.state = state
                item.error = errorMessage

                if success then
                    appliedFlags[item.name] = {
                        value = item.value,
                        state = state,
                    }
                    item.applied = true
                    sentCount = sentCount + 1

                    if state == "verified" then
                        verifiedCount = verifiedCount + 1
                    else
                        unconfirmedCount = unconfirmedCount + 1
                    end
                else
                    failedCount = failedCount + 1

                    if not firstError then
                        firstError = item.name .. "  " .. tostring(errorMessage)
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

        local message = tostring(sentCount) .. " sent"

        if verifiedCount > 0 then
            message = message .. "  " .. tostring(verifiedCount) .. " verified"
        end

        if unconfirmedCount > 0 then
            message = message .. "  " .. tostring(unconfirmedCount) .. " unconfirmed"
        end

        if failedCount > 0 then
            message = message .. "  " .. tostring(failedCount) .. " failed"

            if firstError then
                message = message .. "  " .. firstError
            end
        end

        if failedCount > 0 then
            setStatus(message, "warning")
        else
            setStatus(message, "success")
        end
    end)
end

local function restoreOriginalFlags()
    if busy or loading then
        return
    end

    if typeof(setFlagFunction) ~= "function" then
        setStatus("Executor does not provide setfflag", "error")
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
    setStatus("Restoring captured values", "normal")

    task.spawn(function()
        local restoredCount = 0
        local unconfirmedCount = 0
        local unavailableCount = 0
        local failedCount = 0
        local firstError

        for index, name in ipairs(names) do
            restoreButton.Text = "RESTORING " .. tostring(index) .. "/" .. tostring(#names)

            local original = originalValues[name]

            if original and original.readable then
                local success, state, errorMessage = writeFlag(name, original.value)

                if success then
                    if state == "unconfirmed" then
                        unconfirmedCount = unconfirmedCount + 1
                    else
                        appliedFlags[name] = nil
                        originalValues[name] = nil
                        restoredCount = restoredCount + 1
                    end
                else
                    failedCount = failedCount + 1

                    if not firstError then
                        firstError = name .. "  " .. tostring(errorMessage)
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

        if unconfirmedCount > 0 then
            message = message .. "  " .. tostring(unconfirmedCount) .. " unconfirmed"
        end

        if unavailableCount > 0 then
            message = message .. "  " .. tostring(unavailableCount) .. " no original"
        end

        if failedCount > 0 then
            message = message .. "  " .. tostring(failedCount) .. " failed"

            if firstError then
                message = message .. "  " .. firstError
            end
        end

        if unconfirmedCount > 0 or unavailableCount > 0 or failedCount > 0 then
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
        state = nil,
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

    local shouldEnable = getEnabledCount() ~= #flags

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

    if controlDown and input.KeyCode == Enum.KeyCode.R then
        restoreOriginalFlags()
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

connect(header.InputBegan, function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end

    dragging = true
    dragStart = input.Position
    startPosition = mainFrame.Position
end)

connect(UserInputService.InputChanged, function(input)
    if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then
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
    if typeof(getFlagFunction) == "function" then
        setStatus("Ready  write and readback detected", "success")
    else
        setStatus("Ready  writes can be sent but may be unconfirmed", "warning")
    end
else
    setStatus("RAW loader ready  setfflag unavailable", "warning")
end
