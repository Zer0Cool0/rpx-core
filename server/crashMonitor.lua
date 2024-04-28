local API_KEY = GlobalState.RPXConfig.CrashMonitorAPIKey

if GlobalState.RPXConfig.CrashMonitor then
    if not API_KEY or API_KEY == "" or API_KEY == "YOUR_API_KEY" then
        print("[RPX] CrashMonitor is enabled but no API key is set. Please set the API key in config.lua")
        return
    end
    AddEventHandler("playerDropped", function(reason)
        local _source = source

        local _, _, errorMessage = reason:find("RAGE error:%s(.+)")
        if not errorMessage then
            _, _, errorMessage = reason:find("Game crashed:%s(.+)")
        end

        if errorMessage then
            local ped = GetPlayerPed(_source)
            local pcoords = GetEntityCoords(ped)
            local coords = {
                x = math.floor(pcoords.x),
                y = math.floor(pcoords.y)
            }
            local crash_id = string.lower(errorMessage:gsub("%b()", ""))
            PerformHttpRequest("http://api.gtp-dev.com:8080/api/crashes", function(code, data, headers)
            end, "POST", json.encode({
                apiKey = API_KEY,
                crash_id = crash_id,
                server = GetConvar("sv_projectName", "Unknown"),
                coords = json.encode(coords)
            }), {
                ["Content-Type"] = "application/json"
            })
        end
    end)
end
