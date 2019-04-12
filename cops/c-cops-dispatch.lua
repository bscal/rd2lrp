local vRPserver = Tunnel.getInterface("vRP","cops")
local vRPCopsS = Tunnel.getInterface("cops","cops")

local deadAlert = false
local gsr = {};

AddEventHandler('playerSpawned', function()
    deadAlert = true
end)

local ped = GetPlayerPed(-1)
local x,y,z = table.unpack(GetEntityCoords(ped, true))
local streethash = GetStreetNameAtCoord(x, y, z)
local street = GetStreetNameFromHashKey(streethash)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300)
        ownedVehicle(ped)
        x,y,z = table.unpack(GetEntityCoords(ped, true))
        streethash = GetStreetNameAtCoord(x, y, z)
        street = GetStreetNameFromHashKey(streethash)
        if (isCop) then
            if IsEntityDead(ped) and not (deadAlert) then
                dispatch(ped, "10-108 Officer down, all patrols respond", "None", street)
            end
        else
            local closestPed = nil;
            if (GetClosestPed(x, y, z, 6, 1, 0, closestPed, 0, 0, -1)) then
                dispatch(ped, "901n	Ambulance requested", "None", street)
            end
        end
    end
end)

Citizen.CreateThread(function()
    ped = GetPlayerPed(-1)
    x,y,z = table.unpack(GetEntityCoords(ped, true))
    streethash = GetStreetNameAtCoord(x, y, z)
    street = GetStreetNameFromHashKey(streethash)
    while true do
        Citizen.Wait(0)
        if not isCop or not isEMS then
            ownedVehicle(ped)
            isShoot(ped)
        end
    end
end)

function isShoot(ped)
    if (IsPedShooting(ped)) then
        dispatch(ped, "10-72 Shots fired", "None", street)
        table.insert(gsr, true)
        Citizen.CreateThread(function()
            Citizen.Wait(60000 * 25)
            if (gsr[1] ~= nil) then
                table.remove(gsr, 1)
            end
        end)
    end
end

function ownedVehicle(ped)
    isInVeh = vRP.EXT.Garage:isInVehicle()
    print(isInVeh)
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

RegisterNetEvent('dispatch')
AddEventHandler('dispatch', function(playerid, msg, description, location)
    if (isCop) or (isEMS) then
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 255},
            multiline = true,
            args = {"[Dispatch]", msg .. ", Location: "..location}
        })
    end
end)