local vRPclient = Tunnel.getInterface("vRP", "dispatch")
local vRPdispatchS = Tunnel.getInterface("dispatch", "dispatch")
local vRPdispatch = {}
Tunnel.bindInterface("dispatch", vRPdispatch)
Proxy.addInterface("dispatch", vRPdispatch)

local hasKeys = true

RegisterCommand(
    "gsrtest",
    function(source, args, rawCommand)
        if isCop then
            local closestPlayer, distance = GetClosestPlayer()
            if closestPlayer ~= nil and DoesEntityExist(GetPlayerPed(closestPlayer)) then
                if distance - 1 and distance < 3 then
                    local closestID = GetPlayerServerId(closestPlayer)
                    TriggerServerEvent("gsrServer", closestID)
                end
            end
        end
    end
)

RegisterCommand(
    "311",
    function(source, args, rawCommand)
        local str = ""
        for k, v in pairs(args) do
            str = str .. " " .. v
        end
        local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
        local streethash, crossingHash = GetStreetNameAtCoord(x, y, z)
        local street = GetStreetNameFromHashKey(streethash)
        local crossing = GetStreetNameFromHashKey(crossingHash)
        vRPdispatchS._ping(x, y, z, 120)
        vRPdispatchS.callHelp(str, street .. "/" .. crossing)
    end
)

RegisterCommand(
    "911",
    function(source, args, rawCommand)
        local str = ""
        for k, v in pairs(args) do
            str = str .. " " .. v
        end
        local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
        local streethash, crossingHash = GetStreetNameAtCoord(x, y, z)
        local street = GetStreetNameFromHashKey(streethash)
        local crossing = GetStreetNameFromHashKey(crossingHash)
        vRPdispatchS._ping(x, y, z, 120)
        vRPdispatchS.callEmergency(str, street .. "/" .. crossing)
    end
)

RegisterCommand(
    "r",
    function(source, args, rawCommand)
        if (isCop) or (isEMS) then
            local i = 0
            local str = ""
            for k, v in pairs(args) do
                if not (i == 0) then
                    str = str .. " " .. v
                end
                i = i + 1
            end
            vRPdispatchS.emergencyRespond(args[1], str)
        end
    end
)

RegisterNetEvent("311client")
AddEventHandler(
    "311client",
    function(num, msg, loc)
        if (isCop) or (isEMS) then
            TriggerEvent(
                "chat:addMessage",
                {
                    color = {155, 155, 55},
                    multiline = true,
                    args = {"311", "#" .. num .. ": " .. msg .. " | Pinged Location: " .. loc}
                }
            )
        end
    end
)

RegisterNetEvent("911client")
AddEventHandler(
    "911client",
    function(num, msg, loc)
        if (isCop) or (isEMS) then
            TriggerEvent(
                "chat:addMessage",
                {
                    color = {255, 55, 55},
                    multiline = true,
                    args = {"911", "#" .. num .. ": " .. msg .. " | Pinged Location: " .. loc}
                }
            )
        end
    end
)

RegisterNetEvent("callResponse")
AddEventHandler(
    "callResponse",
    function(msg)
        TriggerEvent(
            "chat:addMessage",
            {
                color = {51, 153, 255},
                multiline = true,
                args = {"[Dispatcher]", msg}
            }
        )
    end
)

RegisterNetEvent("gsrClient")
AddEventHandler(
    "gsrClient",
    function(copID)
        if (#gsr > 0) then
            TriggerServerEvent("gsrResults", copID, true)
            return
        end
        TriggerServerEvent("gsrResults", copID, false)
    end
)

RegisterCommand(
    "fix",
    function(source, args, rawCommand)
        if isCop then
            fix(false)
        end
    end
)

RegisterCommand(
    "adminfix",
    function(source, args, rawCommand)
        if isCop then
            TriggerEvent("iens:repairFull")
        end
    end
)

function fix(value)
    TriggerEvent("iens:repairNoCheck", value)
end

RegisterCommand(
    "dopen",
    function(source, args, rawCommand)
        if (vRP.EXT.Garage:isInVehicle()) and hasKeys and isDriver() then
            local ped = GetPlayerPed(-1)
            local veh = GetVehiclePedIsIn(ped, false)
            SetVehicleDoorOpen(veh, tonumber(args[1]), 0, false)
        end
    end
)

RegisterCommand(
    "dclose",
    function(source, args, rawCommand)
        if (vRP.EXT.Garage:isInVehicle()) and hasKeys and isDriver() then
            local ped = GetPlayerPed(-1)
            local veh = GetVehiclePedIsIn(ped, false)
            SetVehicleDoorShut(veh, tonumber(args[1]), 0, false)
        end
    end
)

local isRunning = true
RegisterCommand(
    "eng",
    function(source, args, rawCommand)
        if (vRP.EXT.Garage:isInVehicle()) and hasKeys and isDriver() then
            local ped = GetPlayerPed(-1)
            local veh = GetVehiclePedIsIn(ped, false)
            SetVehicleUndriveable(veh, isRunning)
            isRunning = not isRunning
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(20)
            if (vRP.EXT.Garage:isInVehicle()) and hasKeys and isDriver() then
                if not isRunning then
                    local ped = GetPlayerPed(-1)
                    local veh = GetVehiclePedIsIn(ped, false)
                    SetVehicleUndriveable(veh, isRunning)
                    SetVehicleEngineOn(veh, false, true, false)
                end
            end
        end
    end
)

local locked = false
RegisterCommand(
    "lock",
    function(source, args, rawCommand)
        if (vRP.EXT.Garage:isInVehicle()) and hasKeys and isDriver() then
            local ped = GetPlayerPed(-1)
            local veh = GetVehiclePedIsIn(ped, false)
            if not (locked) then
                locked = true
                SetVehicleDoorsLocked(veh, 2)
                SetVehicleDoorsLockedForAllPlayers(veh, true)
                TriggerEvent(
                    "chat:addMessage",
                    {
                        color = {55, 55, 200},
                        multiline = true,
                        args = {"Car", "You locked the car"}
                    }
                )
            else
                locked = false
                SetVehicleDoorsLockedForAllPlayers(veh, false)
                SetVehicleDoorsLocked(veh, 1)
                SetVehicleDoorsLockedForPlayer(veh, PlayerId(), false)
                TriggerEvent(
                    "chat:addMessage",
                    {
                        color = {55, 55, 200},
                        multiline = true,
                        args = {"Car", "You unlocked the car"}
                    }
                )
            end
        end
    end
)

function vRPdispatchS.repairSuccess()
    TriggerEvent(
        "chat:addMessage",
        {
            color = {55, 55, 200},
            multiline = true,
            args = {"Car", "Repairing"}
        }
    )
    fix(true)
end

function isPlayerOwned()
    if (vRP.EXT.Garage:getInOwnedVehicleModel()) then
        return true
    end
    return false
end

function isDriver()
    return true
end

function GetPlayers()
    local players = {}
    for i = 0, 31 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end
    return players
end

function GetClosestPlayer()
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(ply, 0)

    for index, value in ipairs(players) do
        local target = GetPlayerPed(value)
        if (target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance =
                GetDistanceBetweenCoords(
                targetCoords["x"],
                targetCoords["y"],
                targetCoords["z"],
                plyCoords["x"],
                plyCoords["y"],
                plyCoords["z"],
                true
            )
            if (closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end
