-- [[ 2026 DELTA-ONLY 4H+ SERVER FINDER ]] --
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local lp = game:GetService("Players").LocalPlayer

local function findOldServer()
    print("Delta: Searching for established servers...")
    
    -- We use 'Desc' (Descending) because older servers are usually at the end of the list
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
    end)

    if success and result and result.data then
        for _, server in pairs(result.data) do
            -- LOGIC: Servers with 6 to 9 players are statistically the oldest.
            -- Full servers (12) are usually new 'overflow' servers.
            -- Empty servers (1-3) are brand new.
            if server.playing >= 6 and server.playing <= 9 and server.id ~= game.JobId then
                print("Old Server Found! Players: " .. server.playing)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, lp)
                return
            end
        end
    end
    
    warn("No ideal server found in this batch. Try running again.")
end

-- Run immediately
findOldServer()
