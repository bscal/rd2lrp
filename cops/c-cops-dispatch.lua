local copBlops = {}

RegisterNetEvent("vrp:playerLoaded")
AddEventHandler("vrp:playerLoaded", function(user, data)
    local job = data.job
    if job == "Police"or job == "EMS" then
        local player = GetPlayerFromServerId(user.source)
        local blip = AddBlipForEntity(player)
        SetBlipSprite(blip, 1)
        SetBlipAsShortRange(blip, true)
        SetBlipScale(blip, 1.0)
        SetBlipDisplay(blip, 2)
        SetBlipFlashes(blip, false)
        SetBlipFlashesAlternate(blip, false)
        SetBlipNameToPlayerName(blip, GetPlayerFromServerId(k))
        if job == "Police" then
            SetBlipColour(blip, 3)
        else
            SetBlipColour(blip, 1)
        end
        copBlops[user.source] = blip
    end
end)

RegisterNetEvent("vrp:playerUnloaded")
AddEventHandler("vrp:playerUnloaded", function(user)
    RemoveBlip(copBlops[user.source])
    copBlops[user.source] = nil
end)

-- local onlineCops = {}
-- local onlineBlipSet = {}

-- Citizen.CreateThread(
--     function()
--         while true do
--             Citizen.Wait(1)
--             if isCop or isEMS then
--                 HandleCopGPS()
--             end
--         end
--     end
-- )

-- function vRPCops.sendOnlineCopsToClients(serverCopsSet)
--     onlineCops = serverCopsSet
-- end

-- function HandleCopGPS()
--     -- * Draws other cops for current cop

--     for k, v in pairs(onlineCops) do
--         if onlineBlipSet[k] == nil then
--             local blip = AddBlipForCoord(v[1], v[2], v[3])
--             SetBlipSprite(blip, 1)
--             SetBlipAsShortRange(blip, true)
--             SetBlipScale(blip, 1.0)
--             SetBlipDisplay(blip, 2)
--             SetBlipFlashes(blip, false)
--             SetBlipFlashesAlternate(blip, false)
--             SetBlipNameToPlayerName(blip, GetPlayerFromServerId(k))
--             if v[4] == 1 then
--                 SetBlipColour(blip, 3)
--             else
--                 SetBlipColour(blip, 1)
--             end
--             onlineBlipSet[k] = blip
--         else
--             SetBlipCoords(onlineBlipSet[k], v[1], v[2], v[3])
--         end
--     end

--     for k, v in pairs(onlineBlipSet) do
--         if (onlineCops[k] == nil) then
--             print("removing blib...")
--             RemoveBlip(onlineBlipSet[k])
--             onlineBlipSet[k] = nil
--         end
--     end

--     -- * Sends cop location to server
--     local jobID = 1
--     if isEMS then
--         jobID = 2
--     end

--     local ped = GetPlayerPed(-1)
--     local x, y, z = table.unpack(GetEntityCoords(ped, true))
--     vRPCopsS._addOnlineCop(jobID, x, y, z)
-- end

RegisterNetEvent("dispatch")
AddEventHandler(
    "dispatch",
    function(playerid, msg, description, location)
        if (isCop) or (isEMS) then
            TriggerEvent(
                "chat:addMessage",
                {
                    color = {255, 255, 255},
                    multiline = true,
                    args = {"[Dispatch]", msg .. ", Location: " .. location}
                }
            )
        end
    end
)
