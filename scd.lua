local URL = "https://api.jnkie.com/api/v1/luascripts/public/aafd7be044561f1597eeb77f7758971bd33d3c68bf1555b8b08e581125c4dc22/download"
local OUTPUT_FILE = "AchaoticSecondStage.lua"

local ok, source = pcall(function()
    if request then
        local response = request({
            Url = URL,
            Method = "GET"
        })

        if response.StatusCode and response.StatusCode ~= 200 then
            error("HTTP " .. tostring(response.StatusCode))
        end

        return response.Body
    end

    return game:HttpGet(URL)
end)

if not ok then
    error("Falha ao baixar o segundo estágio: " .. tostring(source))
end

assert(type(source) == "string" and #source > 0, "Resposta vazia")
writefile(OUTPUT_FILE, source)

print("Segundo estágio salvo em:", OUTPUT_FILE)
print("Tamanho:", #source, "bytes")
print("Início:", source:sub(1, 200))
