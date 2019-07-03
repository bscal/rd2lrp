local deadAlert = false
local gsr = {}

AddEventHandler(
    "playerSpawned",
    function()
        deadAlert = true
    end
)

local onlineCops = {}
local onlineBlipSet = {}

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(300)
            local ped = GetPlayerPed(-1)
            local x, y, z = table.unpack(GetEntityCoords(ped, true))
            local streethash = GetStreetNameAtCoord(x, y, z)
            local street = GetStreetNameFromHashKey(streethash)
            if (isCop) then
                if IsEntityDead(ped) and not (deadAlert) then
                    dispatch(ped, "10-108 Officer down, all patrols respond", "None", street)
                end
            else
                local closestPed = nil
                if (GetClosestPed(x, y, z, 6, 1, 0, closestPed, 0, 0, -1)) then
                    dispatch(ped, "901n	Ambulance requested", "None", street)
                end
            end
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1)
            local ped = GetPlayerPed(-1)
            if isCop or isEMS then
                HandleCopGPS()
            else
                ownedVehicle(ped)
                isShoot(ped)
            end
        end
    end
)

function vRPCops.sendOnlineCopsToClients(serverCopsSet)
    onlineCops = serverCopsSet
end

function HandleCopGPS()
    -- * Draws other cops for current cop

    for k, v in pairs(onlineCops) do
        if onlineBlipSet[k] == nil then
            local blip = AddBlipForCoord(v[1], v[2], v[3])
            SetBlipSprite(blip, 1)
            SetBlipAsShortRange(blip, true)
            SetBlipScale(blip, 1.0)
            SetBlipDisplay(blip, 2)
            SetBlipFlashes(blip, false)
            SetBlipFlashesAlternate(blip, false)
            SetBlipNameToPlayerName(blip, GetPlayerFromServerId(k))
            if v[4] == 1 then
                -- BeginTextCommandSetBlipName("STRING")
                -- AddTextComponentString("Officer")
                SetBlipColour(blip, 3)
            else
                -- BeginTextCommandSetBlipName("STRING")
                -- AddTextComponentString("EMS")
                SetBlipColour(blip, 1)
            end
            -- EndTextCommandSetBlipName(blip)
            onlineBlipSet[k] = blip
        else
            SetBlipCoords(onlineBlipSet[k], v[1], v[2], v[3])
        end
    end

    for k, v in pairs(onlineBlipSet) do
        if (onlineCops[k] == nil) then
            print("removing blib...")
            RemoveBlip(onlineBlipSet[k])
            onlineBlipSet[k] = nil
        end
    end

    -- * Sends cop location to server
    local jobID = 1
    if isEMS then
        jobID = 2
    end

    local ped = GetPlayerPed(-1)
    local x, y, z = table.unpack(GetEntityCoords(ped, true))
    vRPCopsS._addOnlineCop(jobID, x, y, z)
end

function isShoot(ped)
    if (IsPedShooting(ped)) then
        dispatch(ped, "10-72 Shots fired", "None", street)
        table.insert(gsr, true)
        Citizen.CreateThread(
            function()
                Citizen.Wait(60000 * 25)
                if (gsr[1] ~= nil) then
                    table.remove(gsr, 1)
                end
            end
        )
    end
end

function ownedVehicle(ped)
    local isInVeh = vRP.EXT.Garage:isInVehicle()
    if (isInVeh) then
        local veh = GetVehiclePedIsIn(ped, false)
        --local cid, model = vRPgarage.getVehicleInfo({veh})
        --if (cid == nil) then
        --    dispatch(ped, "10851 Stolen vehicle", "None", street)
        --elseif not (cid == vRP.cid) then
        --    dispatch(ped, "10851 Stolen vehicle", "None", street)
        --end
        if ((GetEntitySpeed(veh) * 3.6) > 90) then
            dispatch(ped, "22350 Speeding vehicle", "None", street)
        end
    end
end

function dispatch(playerid, msg, description, location)
    vRPCopsS.dispatch({playerid, msg, description, location})
end

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
