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
        if ifEntity and IsEntityAPed(entity) and not IsEntityPlayer(ped) and not robCD then
            TaskCower(entity, 5000)
            robCD = true
            Citizen.SetTimeout(5000, function()
                if not IsEntityDead(entity) then
                    TaskReactAndFleePed(entity, ped)
                    vRProbS.robPed()
                    local x,y,z = table.unpack(GetEntityCoords(ped, true))
                    local streethash = GetStreetNameAtCoord(x, y, z)
                    local street = GetStreetNameFromHashKey(streethash)
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
    print("started robbing")
    local closestPlayer, distance = GetClosestPlayer()
    if closestPlayer ~= nil and DoesEntityExist(GetPlayerPed(closestPlayer)) then
        if distance -1 and distance < 2 then
            local closestID = GetPlayerServerId(closestPlayer)
            vRProbS.robMoney(closestID)
        end
    end
end)

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
