 vRPdispatchS = Tunnel.getInterface("dispatch", "dispatch")
 vRPdispatch = {}
Tunnel.bindInterface("dispatch", vRPdispatch)
Proxy.addInterface("dispatch", vRPdispatch)

isCop = false
isEMS = false
deadAlert = true
gsr = {}

AddEventHandler(
    "cop:revivePlayer",
    function()
        deadAlert = true
    end
)

-- Downed Player Thread
Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(333)
            local ped = GetPlayerPed(-1)
            if IsEntityDead(ped) and (deadAlert) then
                local x, y, z = table.unpack(GetEntityCoords(ped, true))
                local streethash = GetStreetNameAtCoord(x, y, z)
                local street = GetStreetNameFromHashKey(streethash)

                vRPdispatchS.ping(x, y, z, 180)

                if (isCop) then
                    dispatch(ped, "10-108 Officer down, all patrols respond", "None", street)
                else
                    local closestPed = GetClosestPed(x, y, z, 16, 1, 0, closestPed, 0, 0, -1)
                    dispatch(ped, "901n	Ambulance requested", "None", street)
                end
                deadAlert = false
            end
        end
    end
)

-- Gun Shot Thread
Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(20)
            local ped = GetPlayerPed(-1)
            if (IsPedShooting(ped)) and not isCop then
                local x, y, z = table.unpack(GetEntityCoords(ped, true))
                local streethash = GetStreetNameAtCoord(x, y, z)
                local street = GetStreetNameFromHashKey(streethash)
                dispatch(ped, "10-72 Shots fired", "None", street)
                vRPdispatchS.ping(x, y, z, 120)
                table.insert(gsr, true)
                Citizen.SetTimeout(
                    60000 * 25,
                    function()
                        if (gsr[1] ~= nil) then
                            table.remove(gsr, 1)
                        end
                    end
                )
                Citizen.Wait(6000)
            end
        end
    end
)

-- Vehicle Thread
Citizen.CreateThread(
    function()
        while true do
            if isCop or isEMS then
                break
            end

            Citizen.Wait(1000)

            local ped = GetPlayerPed(-1)
            if IsPedInAnyVehicle(ped) then
                local veh = GetVehiclePedIsIn(ped, false)
                local driver = GetPedInVehicleSeat(veh, -1)
                if (driver == ped) then
                    local cid, model = vRP.EXT.Garage:getVehicleInfo(veh)

                    local x, y, z = table.unpack(GetEntityCoords(ped, true))
                    local streethash = GetStreetNameAtCoord(x, y, z)
                    local street = GetStreetNameFromHashKey(streethash)

                    if ((GetEntitySpeed(veh) * 2.236936) > 85) then
                        dispatch(ped, "22350 Speeding vehicle", "None", street)
                        Citizen.Wait(50000)
                    elseif IsVehicleStolen(veh) then
                        if (cid == nil) then
                            dispatch(ped, "10851 Stolen vehicle", "None", street)
                        elseif not (vRP.EXT.Base.cid == cid) then
                            dispatch(ped, "10851 Stolen vehicle", "None", street)
                        end
                        SetVehicleIsStolen(veh, false)
                        Citizen.Wait(20000)
                    end
                end
            end
        end
    end
)

function vRPdispatch.ping(x, y, z, time)
    if isCop or isEMS then
        local blip = AddBlipForCoord(x, y, z)
        SetBlipSprite(blip, 398)
        SetBlipColour(blip, 24)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Emergency Ping")
        EndTextCommandSetBlipName(blip)
        Citizen.SetTimeout(
            time * 1000,
            function()
                RemoveBlip(blip)
            end
        )
    end
end

function dispatch(playerid, msg, description, location)
    local desc = "Description: female"
    if IsPedMale(playerid) then
        desc = "Description: male"
    end
    vRPdispatchS._dispatchS(playerid, msg, desc, location)
end

function vRPdispatch.dispatchC(playerid, msg, description, location)
    if (isCop) then
        if location == nil then
            location = "Pinged location"
        end
        local str = msg .. ", " .. description .. ", Location: " .. location
        TriggerEvent(
            "chat:addMessage",
            {
                color = {255, 55, 55},
                multiline = true,
                args = {"[Dispatch]", str}
            }
        )
    end
end

RegisterNetEvent("DispatchRobbery")
AddEventHandler(
    "DispatchRobbery",
    function(playerid, msg, description, location)
        local desc = "Description: female"
        if IsPedMale(playerid) then
            desc = "Description: male"
        end
        vRPdispatchS._dispatchS(playerid, msg, desc, location)
    end
)

RegisterNetEvent("DispatchPing")
AddEventHandler(
    "DispatchPing",
    function(x, y, z, time)
        vRPdispatchS._ping(x, y, z, 120)
    end
)

AddEventHandler(
    "isService",
    function(cop, ems)
        isCop = cop
        isEMS = ems
    end
)
