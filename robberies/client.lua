vRPclient = Tunnel.getInterface("vRP","robberies")
vRProbS = Tunnel.getInterface("robberies","robberies")

vRPRob = {}
Tunnel.bindInterface("robberiesC", vRPRob)
Proxy.addInterface("robberiesC", vRPRob)

Citizen.CreateThread(function()
    local robCD = false
    while true do
        Citizen.Wait(0)
        local ped = GetPlayerPed(-1)
        ifEntity, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
        if ifEntity and IsEntityAPed(entity) and not IsPedAPlayer(ped) and not robCD then
            TaskCower(entity, 5000)
            robCD = true
            Citizen.SetTimeout(5000, function()
                if not IsEntityDead(entity) then
                    TaskReactAndFleePed(entity, ped)
                    vRProbS.robPed()
                    local x,y,z = table.unpack(GetEntityCoords(ped, true))
                    local streethash = GetStreetNameAtCoord(x, y, z)
                    local street = GetStreetNameFromHashKey(streethash)
                    vRPdispatchS._ping(x, y, z, 120)
                    TriggerEvent("DispatchRobbery", ped, "Pedestrian robbery", "None", street)
                end
            end)
            Citizen.SetTimeout(15000, function()
                robCD = false
            end)
        end
    end
end)

RegisterCommand('rob', function()
    local closestPlayer, distance = GetClosestPlayer()
    if closestPlayer ~= nil and DoesEntityExist(GetPlayerPed(closestPlayer)) then
        if distance -1 and distance < 2 then
            local closestID = GetPlayerServerId(closestPlayer)
            vRProbS.robMoney(closestID)
        end
    end
end)

local guiEnabled = false
local openedPlayerID = -1

RegisterCommand('search', function(source, args, rawCommand)
    local closestPlayer, distance = GetClosestPlayer()
    if closestPlayer ~= nil and DoesEntityExist(GetPlayerPed(closestPlayer)) then
        if distance -1 and distance < 3 then
            local closestID = GetPlayerServerId(closestPlayer)
            vRProbS.robInventory(closestID)
        end
    end
end)

RegisterCommand('inv', function(source, args, rawCommand)
    vRProbS._showInventory()
end)

RegisterNetEvent('inv:display')
AddEventHandler('inv:display', function(enable)
    SendNUIMessage({
        type = "display",
        enable = enable
    })
end)

function vRPRob.EnableGui(enable, victimID, victimName , inv, invv)
    openedPlayerID = victimID
    guiEnabled = not guiEnabled
    SetNuiFocus(guiEnabled)
    SendNUIMessage({
        type = "display",
        enable = guiEnabled,
        name = victimName,
        inv = inv,
        invv = invv
    })
end

function vRPRob.EnableInvGui(inv, uWeight, uMaxWeight)
    openedPlayerID = victimID
    guiEnabled = not guiEnabled
    SetNuiFocus(guiEnabled)
    SendNUIMessage({
        type = "display",
        enable = guiEnabled,
        inv = inv,
        uWeight = round(uWeight, 0).."/"..uMaxWeight
    })
end

function vRPRob.updateWeightUI(uWeight, uMaxWeight, vWeight, vMaxWeight)
    SendNUIMessage({
        type = "updateWeight",
        uWeight = round(uWeight, 0).."/"..uMaxWeight,
        vWeight = round(vWeight, 0).."/"..vMaxWeight
    })
end

function vRPRob.updateInventoryUI(inv, invo)
    SendNUIMessage({
        type = "updateInventory",
        inv = inv,
        invv = invo
    })
end

Citizen.CreateThread(function()
    while true do
        if guiEnabled then
            --DisableControlAction(0, 1, guiEnabled) -- LookLeftRight
            --DisableControlAction(0, 2, guiEnabled) -- LookUpDown
            DisableControlAction(0, 15, guiEnabled) -- ScrollUp
            DisableControlAction(0, 14, guiEnabled) -- ScrollDown
            DisableControlAction(0, 16, guiEnabled) -- ScrollUp
            DisableControlAction(0, 17, guiEnabled) -- ScrollDown
            DisableControlAction(0, 142, guiEnabled) -- MeleeAttackAlternate
            DisableControlAction(0, 106, guiEnabled) -- VehicleMouseControlOverride

            if IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
                SendNUIMessage({
                    type = "click"
                })
            end
        else
            openedPlayerID = -1
        end
        Citizen.Wait(0)
    end
end)

RegisterNUICallback('escape', function(data, cb)
    vRPRob.EnableGui(false, {})
    SetNuiFocus(false)
    --EnableControlAction(0, 1, true) -- LookLeftRight
    --EnableControlAction(0, 2, true) -- LookUpDown
    EnableControlAction(0, 15, true) -- ScrollUp
    EnableControlAction(0, 14, true) -- ScrollDown
    EnableControlAction(0, 16, true) -- ScrollUp
    EnableControlAction(0, 17, true) -- ScrollDown
    EnableControlAction(0, 142, true) -- MeleeAttackAlternate
    EnableControlAction(0, 106, true) -- VehicleMouseControlOverride
end)

RegisterNUICallback('clicked', function(data)
    print(data['id'])
    if data['id'] == "yours" then
        return
    end
    if data["item"] ~= nil then
        local str = splitString(data["item"], " ")
        vRProbS._takeItem(openedPlayerID, str)
        return;
    end
end)



-- Functions 

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

    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = GetDistanceBetweenCoords(targetCoords['x'], targetCoords['y'], targetCoords['z'], plyCoords['x'], plyCoords['y'], plyCoords['z'], true)
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
    
    return closestPlayer, closestDistance
end

function round(val, decimal)
    local exp = decimal and 10^decimal or 1
    return math.ceil(val * exp - 0.5) / exp
end