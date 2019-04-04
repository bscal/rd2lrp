vRPclient = Tunnel.getInterface("vRP","dispatch")
vRPdispatchS = Tunnel.getInterface("dispatch","dispatch")
vRPdispatch = {}
Tunnel.bindInterface("dispatch", vRPdispatch)
Proxy.addInterface("dispatch", vRPdispatch)

isCop = false
isEMS = false
deadAlert = false
gsr = {};

AddEventHandler('playerSpawned', function()
    deadAlert = true
end)

blips = {}
-- Cop blip update thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(20)
        if isCop or isEMS then
            for k, v in pairs(blips) do
                local id = GetPlayerServerId(v.source)
                if not DoesEntityExist(id) then
                    RemoveBlip(v.mblip)
                else
                    SetBlipCoords(v.mblip, v.mx, v.my, v.mz)
                end
            end
            local ped = GetPlayerPed(-1)
            local x,y,z = table.unpack(GetEntityCoords(ped, true))
            vRPdispatchS.updatePosition(x, y, z)
        end
    end
end)

function vRPdispatch.setBlip(officerid, x, y, z)
    if isCop or isEMS then
        for k, v in pairs(blips) do
            if (v.source == officerid) then
                v.mx = x
                v.my = y
                v.mz = z
            else
                local blip = AddBlipForCoord(x, y, z)
                SetBlipSprite(blip, 143)
                SetBlipColour(blip, 63)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Officer")
                EndTextCommandSetBlipName(blip)
                table.insert(blips, {mblip = blip, source = officerid, mx = x, my = y, mz = z})
            end
        end
    end
end

-- Downed Player Thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(333)
        local ped = GetPlayerPed(-1)
        if IsEntityDead(ped) and (deadAlert) then
            local x,y,z = table.unpack(GetEntityCoords(ped, true))
            local streethash = GetStreetNameAtCoord(x, y, z)
            local street = GetStreetNameFromHashKey(streethash)

            vRPdispatchS.ping(x, y, z, 180)

            if (isCop) then
                dispatch(ped, "10-108 Officer down, all patrols respond", "None", street) 
            else
                local closestPed = GetClosestPed(x, y, z, 16, 1, 0, closestPed, 0, 0, -1);
                dispatch(ped, "901n	Ambulance requested", "None", street)
            end
            deadAlert = false
        end
    end
end)

-- seconds
local canAlert = true

-- Gun Shot Thread 
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(16)
        local ped = GetPlayerPed(-1)
        if (IsPedShooting(ped)) and not isCop then
            local x,y,z = table.unpack(GetEntityCoords(ped, true))
            local streethash = GetStreetNameAtCoord(x, y, z)
            local street = GetStreetNameFromHashKey(streethash)
            dispatch(ped, "10-72 Shots fired", "None", street)
            vRPdispatchS.ping(x, y, z, 120)
            table.insert(gsr, true)
            Citizen.SetTimeout(60000 * 25, function() 
                if (gsr[1] ~= nil) then
                    table.remove(gsr, 1)
                end
            end)
            Citizen.Wait(7500)
        end
    end
end)

-- Vehicle Thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local ped = GetPlayerPed(-1)
        if (vRP.EXT.Garage:isInVehicle()) and not isCop then
            local veh = GetVehiclePedIsIn(ped, false)
            local driver = GetPedInVehicleSeat(veh, -1)
            if (driver == ped) then
                local cid, model = vRP.EXT.Garage:getVehicleInfo(veh)
                
                local x,y,z = table.unpack(GetEntityCoords(ped, true))
                local streethash = GetStreetNameAtCoord(x, y, z)
                local street = GetStreetNameFromHashKey(streethash)

                if ((GetEntitySpeed(veh) * 2.236936) > 85) then
                    dispatch(ped, "22350 Speeding vehicle", "None", street)
                    Citizen.Wait(32000)
                elseif IsVehicleStolen(veh) then
                    if (cid == nil) then
                        dispatch(ped, "10851 Stolen vehicle", "None", street)
                    elseif not (vRP.EXT.Base.cid == cid) then
                        dispatch(ped, "10851 Stolen vehicle", "None", street)
                    end
                    SetVehicleIsStolen(veh, false)
                    Citizen.Wait(16000)
                end
            end
        end
    end
end)

function hotwire(veh)
    SetVehicleNeedsToBeHotWired(veh, true);
    Citizen.CreateThread(function()
        local hotwire = 60
        while true do
            Citizen.Wait(1000)
            SetVehicleEngineOn(veh, false, true, false)
            if (hotwire < 1) then
                SetVehicleEngineOn(veh, true, true, false)
                break
            end
            hotwire = hotwire - 1
            TriggerEvent('chat:addMessage', {
                color = {255, 255, 255},
                multiline = true,
                args = {"How wiring 60/"..hotwire}
            })
        end
    end)
end

function vRPdispatch.ping(x, y, z, time)
    if isCop or isEMS then
        local blip = AddBlipForCoord(x, y, z)
        SetBlipSprite(blip, 398)
        SetBlipColour(blip, 24)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Emergency Ping")
        EndTextCommandSetBlipName(blip)
        Citizen.SetTimeout(time * 1000, function()
            RemoveBlip(blip)
        end)
    end
end

function dispatch(playerid, msg, description, location)
    vRPdispatchS._dispatchS(playerid, msg, description, location)
end

function vRPdispatch.dispatchC(playerid, msg, description, location)
    if (isCop) then
        local str = msg..", Location: "..location
        TriggerEvent('chat:addMessage', {
            color = {255, 55, 55},
            multiline = true,
            args = {"[Dispatch]", str}
        })
    end
end

RegisterNetEvent("DispatchRobbery")
AddEventHandler("DispatchRobbery", function(playerid, msg, description, location)
    vRPdispatchS._dispatchS(playerid, msg, description, location)
end)

RegisterNetEvent("DispatchPing")
AddEventHandler("DispatchPing", function(x, y, z, time)
    vRPdispatchS.ping(x, y, z, 120)
end)


AddEventHandler('isService', function(cop, ems)
    isCop = cop;
    isEMS = ems;
end)
