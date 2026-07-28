-- LuraphTraceDumper.lua
-- Execute este arquivo ANTES do loader da hub, no mesmo executor e na mesma sessão.

local CONFIG = {
    Folder = "AchaoticTrace",
    SafeMode = true,
    ScanDelays = {10, 25, 45},
    MaxFunctionsPerScan = 3000,
    MaxConstantsPerFunction = 600,
    MaxStringLength = 20000,
    SaveHttpBodies = true,
    SaveLoadstringSources = true,
}

local env = (getgenv and getgenv()) or _G
local unpackValues = table.unpack or unpack
local packValues = table.pack or function(...)
    return {n = select("#", ...), ...}
end

local function executorName()
    if identifyexecutor then
        local ok, name, version = pcall(identifyexecutor)
        if ok then
            return tostring(name), tostring(version or "")
        end
    end
    return "Unknown", ""
end

local function sanitizeName(value)
    return tostring(value)
        :gsub("[^%w%._%-]", "_")
        :sub(1, 100)
end

local function ensureFolder(path)
    if isfolder and makefolder then
        if not isfolder(path) then
            makefolder(path)
        end
        return true
    end
    return false
end

assert(writefile, "O executor precisa ter writefile.")
ensureFolder(CONFIG.Folder)

local sessionId = tostring(os.time and os.time() or math.floor(os.clock() * 1000))
local sessionFolder = CONFIG.Folder .. "/session_" .. sanitizeName(sessionId)
ensureFolder(sessionFolder)

local logFile = sessionFolder .. "/trace.log"
local logBuffer = {}

local function flushLog()
    pcall(writefile, logFile, table.concat(logBuffer, "\n"))
end

local function log(...)
    local parts = {}
    for index = 1, select("#", ...) do
        parts[index] = tostring(select(index, ...))
    end

    local line = string.format("[%.3f] %s", os.clock(), table.concat(parts, " "))
    logBuffer[#logBuffer + 1] = line
    flushLog()
    print("[AchaoticTrace]", table.concat(parts, " "))
end

local fileCounters = {}

local function nextFile(prefix, extension)
    fileCounters[prefix] = (fileCounters[prefix] or 0) + 1
    return string.format(
        "%s/%s_%04d.%s",
        sessionFolder,
        sanitizeName(prefix),
        fileCounters[prefix],
        extension or "txt"
    )
end

local function saveText(prefix, extension, contents)
    contents = tostring(contents or "")
    local path = nextFile(prefix, extension)

    local ok, err = pcall(writefile, path, contents)
    if ok then
        log("saved", path, "bytes=" .. #contents)
        return path
    end

    log("write failed", path, err)
    return nil
end

local function valueToText(value, depth, seen)
    depth = depth or 0
    seen = seen or {}

    local valueType = typeof and typeof(value) or type(value)

    if valueType == "string" then
        local text = value
        if #text > CONFIG.MaxStringLength then
            text = text:sub(1, CONFIG.MaxStringLength) .. "\n--[[ TRUNCATED ]]"
        end
        return string.format("%q", text)
    end

    if valueType == "number" or valueType == "boolean" or valueType == "nil" then
        return tostring(value)
    end

    if valueType == "function" then
        return "<function:" .. tostring(value) .. ">"
    end

    if valueType == "Instance" then
        local ok, fullName = pcall(function()
            return value:GetFullName()
        end)
        return "<Instance:" .. (ok and fullName or tostring(value)) .. ">"
    end

    if valueType ~= "table" then
        return "<" .. valueType .. ":" .. tostring(value) .. ">"
    end

    if seen[value] then
        return "<recursive-table>"
    end

    if depth >= 2 then
        return "<table:" .. tostring(value) .. ">"
    end

    seen[value] = true
    local parts = {"{"}
    local count = 0

    for key, item in next, value do
        count = count + 1
        if count > 80 then
            parts[#parts + 1] = "  --[[ TABLE TRUNCATED ]]"
            break
        end

        parts[#parts + 1] = string.format(
            "  [%s] = %s,",
            valueToText(key, depth + 1, seen),
            valueToText(item, depth + 1, seen)
        )
    end

    parts[#parts + 1] = "}"
    seen[value] = nil
    return table.concat(parts, "\n")
end

local function saveBody(kind, url, body)
    if not CONFIG.SaveHttpBodies or type(body) ~= "string" or #body == 0 then
        return
    end

    local extension = "txt"
    local lower = body:sub(1, 400):lower()

    if lower:find("local ", 1, true)
        or lower:find("return", 1, true)
        or lower:find("loadstring", 1, true)
        or lower:find("luraph", 1, true)
    then
        extension = "lua"
    end

    local header = string.format(
        "-- Captured by LuraphTraceDumper\n-- Kind: %s\n-- URL: %s\n-- Bytes: %d\n\n",
        tostring(kind),
        tostring(url),
        #body
    )

    saveText("http_" .. sanitizeName(kind), extension, header .. body)
end

local function describeRequest(options)
    if type(options) ~= "table" then
        return tostring(options), "GET"
    end

    return tostring(options.Url or options.URL or options.url or "?"),
        tostring(options.Method or options.method or "GET")
end

local wrappedRequests = {}

local function wrapRequestFunction(label, owner, key)
    if not owner or type(owner[key]) ~= "function" then
        return
    end

    local original = owner[key]
    if wrappedRequests[original] then
        return
    end

    local wrapper = function(options)
        local url, method = describeRequest(options)
        log("request", label, method, url)

        local results = packValues(original(options))
        local response = results[1]

        if type(response) == "table" then
            local status = response.StatusCode or response.Status or response.status_code
            local body = response.Body or response.body

            log("response", label, "status=" .. tostring(status), "bytes=" .. tostring(type(body) == "string" and #body or 0))
            saveBody(label, url, body)
        elseif type(response) == "string" then
            log("response", label, "bytes=" .. #response)
            saveBody(label, url, response)
        end

        return unpackValues(results, 1, results.n)
    end

    wrappedRequests[original] = true

    local replaced = false
    if hookfunction then
        local ok, old = pcall(hookfunction, original, newcclosure and newcclosure(wrapper) or wrapper)
        if ok then
            wrappedRequests[old or original] = true
            replaced = true
        end
    end

    if not replaced then
        pcall(function()
            owner[key] = wrapper
        end)
    end

    log("hooked request", label)
end

wrapRequestFunction("request", env, "request")
wrapRequestFunction("http_request", env, "http_request")

if type(env.syn) == "table" then
    wrapRequestFunction("syn.request", env.syn, "request")
end

if type(env.fluxus) == "table" then
    wrapRequestFunction("fluxus.request", env.fluxus, "request")
end

if type(env.http) == "table" then
    wrapRequestFunction("http.request", env.http, "request")
end

local originalLoadstring = env.loadstring or loadstring
if type(originalLoadstring) == "function" then
    local loadstringCounter = 0

    local function tracedLoadstring(source, chunkName)
        loadstringCounter = loadstringCounter + 1

        if type(source) == "string" then
            log(
                "loadstring",
                "index=" .. loadstringCounter,
                "bytes=" .. #source,
                "chunk=" .. tostring(chunkName)
            )

            if CONFIG.SaveLoadstringSources then
                local header = string.format(
                    "-- Captured loadstring source\n-- Index: %d\n-- Chunk: %s\n-- Bytes: %d\n\n",
                    loadstringCounter,
                    tostring(chunkName),
                    #source
                )

                saveText("loadstring", "lua", header .. source)
            end
        else
            log("loadstring called with", type(source))
        end

        return originalLoadstring(source, chunkName)
    end

    local hooked = false

    if hookfunction then
        local ok, old = pcall(
            hookfunction,
            originalLoadstring,
            newcclosure and newcclosure(tracedLoadstring) or tracedLoadstring
        )

        if ok then
            originalLoadstring = old or originalLoadstring
            hooked = true
        end
    end

    if not hooked then
        env.loadstring = tracedLoadstring
    end

    log("hooked loadstring")
end

local oldNamecall
if hookmetamethod and getnamecallmethod and newcclosure then
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = packValues(...)

        local isHttp =
            method == "HttpGet"
            or method == "HttpGetAsync"
            or method == "HttpPost"
            or method == "HttpPostAsync"
            or method == "RequestAsync"
            or method == "GetAsync"
            or method == "PostAsync"

        if isHttp then
            local url = args[1]
            if method == "RequestAsync" and type(args[1]) == "table" then
                url = args[1].Url or args[1].URL or args[1].url
            end

            log("namecall http", method, tostring(url))

            local results = packValues(oldNamecall(self, unpackValues(args, 1, args.n)))
            local response = results[1]

            if type(response) == "table" then
                local body = response.Body or response.body
                local status = response.StatusCode or response.Status
                log("namecall response", method, "status=" .. tostring(status), "bytes=" .. tostring(type(body) == "string" and #body or 0))
                saveBody(method, url, body)
            elseif type(response) == "string" then
                log("namecall response", method, "bytes=" .. #response)
                saveBody(method, url, response)
            end

            return unpackValues(results, 1, results.n)
        end

        if CONFIG.SafeMode then
            if method == "FireServer" or method == "InvokeServer" then
                log("SAFE_MODE blocked", method, tostring(self))
                if method == "InvokeServer" then
                    return nil
                end
                return
            end

            if method == "Kick"
                or method == "Teleport"
                or method == "TeleportToPlaceInstance"
                or method == "TeleportAsync"
            then
                log("SAFE_MODE blocked", method, tostring(self))
                return
            end
        end

        return oldNamecall(self, ...)
    end))

    log("hooked __namecall", "SafeMode=" .. tostring(CONFIG.SafeMode))
else
    log("__namecall hook unavailable")
end

local baselineFunctions = {}

local function captureBaseline()
    if not getgc then
        log("getgc unavailable")
        return
    end

    local ok, objects = pcall(getgc, true)
    if not ok or type(objects) ~= "table" then
        log("baseline getgc failed", objects)
        return
    end

    local functionCount = 0
    for _, object in ipairs(objects) do
        if type(object) == "function" then
            baselineFunctions[object] = true
            functionCount = functionCount + 1
        end
    end

    log("baseline captured", "functions=" .. functionCount, "objects=" .. #objects)
end

captureBaseline()

local function getFunctionInfo(func)
    if debug and debug.getinfo then
        local ok, info = pcall(debug.getinfo, func)
        if ok and type(info) == "table" then
            return info
        end
    end
    return {}
end

local function getConstants(func)
    local getter = debug and debug.getconstants or getconstants
    if not getter then
        return nil
    end

    local ok, constants = pcall(getter, func)
    if ok and type(constants) == "table" then
        return constants
    end

    return nil
end

local function getUpvalues(func)
    local getter = debug and debug.getupvalues or getupvalues
    if not getter then
        return nil
    end

    local ok, upvalues = pcall(getter, func)
    if ok and type(upvalues) == "table" then
        return upvalues
    end

    return nil
end

local function getProtos(func)
    local getter = debug and debug.getprotos or getprotos
    if not getter then
        return nil
    end

    local ok, protos = pcall(getter, func)
    if ok and type(protos) == "table" then
        return protos
    end

    return nil
end

local function functionLooksRelevant(constants)
    if type(constants) ~= "table" then
        return false
    end

    local keywords = {
        "luraph",
        "achaotic",
        "bladeball",
        "blade ball",
        "autoparry",
        "auto parry",
        "parry",
        "requestasync",
        "httpget",
        "loadstring",
        "fireserver",
        "invokeserver",
        "runservice",
        "replicatedstorage",
    }

    for _, constant in ipairs(constants) do
        if type(constant) == "string" then
            local lower = constant:lower()
            for _, keyword in ipairs(keywords) do
                if lower:find(keyword, 1, true) then
                    return true
                end
            end
        end
    end

    return false
end

local function dumpFunction(func, index, scanNumber)
    local info = getFunctionInfo(func)
    local constants = getConstants(func) or {}
    local upvalues = getUpvalues(func) or {}
    local protos = getProtos(func) or {}

    local lines = {
        "-- New closure captured by LuraphTraceDumper",
        "-- Scan: " .. tostring(scanNumber),
        "-- Index: " .. tostring(index),
        "-- Function: " .. tostring(func),
        "-- Source: " .. tostring(info.source or info.short_src),
        "-- Name: " .. tostring(info.name),
        "-- What: " .. tostring(info.what),
        "-- Current line: " .. tostring(info.currentline),
        "-- Num params: " .. tostring(info.numparams),
        "-- Is vararg: " .. tostring(info.isvararg),
        "",
        "CONSTANTS = {",
    }

    local constantsLimit = math.min(#constants, CONFIG.MaxConstantsPerFunction)
    for constantIndex = 1, constantsLimit do
        lines[#lines + 1] = string.format(
            "    [%d] = %s,",
            constantIndex,
            valueToText(constants[constantIndex])
        )
    end

    if #constants > constantsLimit then
        lines[#lines + 1] = "    --[[ CONSTANTS TRUNCATED ]]"
    end

    lines[#lines + 1] = "}"
    lines[#lines + 1] = ""
    lines[#lines + 1] = "UPVALUES = " .. valueToText(upvalues)
    lines[#lines + 1] = ""
    lines[#lines + 1] = "PROTOS = {"

    for protoIndex, proto in ipairs(protos) do
        lines[#lines + 1] = string.format(
            "    [%d] = %q,",
            protoIndex,
            tostring(proto)
        )
    end

    lines[#lines + 1] = "}"

    local relevant = functionLooksRelevant(constants)
    local prefix = relevant and "closure_relevant" or "closure"
    saveText(prefix, "lua", table.concat(lines, "\n"))

    return relevant
end

local seenAfterBaseline = {}

local function scanNewClosures(scanNumber)
    if not getgc then
        return
    end

    log("scan started", scanNumber)

    local ok, objects = pcall(getgc, true)
    if not ok or type(objects) ~= "table" then
        log("scan getgc failed", scanNumber, objects)
        return
    end

    local newFunctions = 0
    local relevantFunctions = 0
    local scanned = 0

    for _, object in ipairs(objects) do
        if type(object) == "function"
            and not baselineFunctions[object]
            and not seenAfterBaseline[object]
        then
            seenAfterBaseline[object] = true
            newFunctions = newFunctions + 1

            local isLuaClosure = true
            if islclosure then
                local closureOk, closureResult = pcall(islclosure, object)
                isLuaClosure = closureOk and closureResult
            end

            if isLuaClosure then
                scanned = scanned + 1

                local okDump, relevant = pcall(
                    dumpFunction,
                    object,
                    scanned,
                    scanNumber
                )

                if okDump and relevant then
                    relevantFunctions = relevantFunctions + 1
                elseif not okDump then
                    log("closure dump failed", tostring(object), relevant)
                end

                if scanned >= CONFIG.MaxFunctionsPerScan then
                    log("scan function limit reached", CONFIG.MaxFunctionsPerScan)
                    break
                end
            end
        end
    end

    log(
        "scan finished",
        scanNumber,
        "new=" .. newFunctions,
        "dumped=" .. scanned,
        "relevant=" .. relevantFunctions
    )
end

local name, version = executorName()

local manifest = {
    "LuraphTraceDumper",
    "Session: " .. sessionId,
    "Executor: " .. name .. " " .. version,
    "SafeMode: " .. tostring(CONFIG.SafeMode),
    "Started: " .. tostring(os.date and os.date() or os.clock()),
    "",
    "ORDEM:",
    "1. Execute este dumper.",
    "2. Execute o loader original da hub na mesma sessão.",
    "3. Espere pelo menos 50 segundos.",
    "4. Feche a hub.",
    "5. Envie a pasta inteira: " .. sessionFolder,
}

pcall(writefile, sessionFolder .. "/README.txt", table.concat(manifest, "\n"))

log("ready")
log("executor", name, version)
log("session folder", sessionFolder)
log("execute the original hub loader now")

for scanNumber, delaySeconds in ipairs(CONFIG.ScanDelays) do
    task.delay(delaySeconds, function()
        scanNewClosures(scanNumber)
    end)
end

task.delay((CONFIG.ScanDelays[#CONFIG.ScanDelays] or 45) + 5, function()
    log("all automatic scans completed")
    log("send the entire folder", sessionFolder)
end)
