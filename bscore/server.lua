vRPCoreC = Tunnel.getInterface("bscore", "bscore")
vRPJobsS = Proxy.getInterface("jobs")

vRPCoreS = {}
Tunnel.bindInterface("bscore", vRPCoreS)
Proxy.addInterface("bscore", vRPCoreS)

local Core = class("bscore", vRP.Extension)
Core.User = class("User")
Core.tunnel = {}
Core.event = {}

function Core:__construct()
    vRP.Extension.__construct(self)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(2500)
            for k, v in pairs(vRP.users_by_source) do
                TriggerClientEvent("vrp:playerUpdate", k, v, Core:loadData(user))
            end
        end
    end)
end

function Core.event:playerSpawn(user, first_spawn)
    TriggerEvent("vrp:playerSpawn", user, first_spawn)
end

function Core.event:characterLoad(user)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)

            if user:isReady() and vRP.users_by_source[user.source] then
                print(user.name .. " ("..user.source..")" .. " has loaded!", user.spawns)

                local data = Core:loadData(user)

                TriggerEvent("vrp:playerReady", user, data)
                TriggerClientEvent("vrp:playerReady", user.source, user, data)
                return
            end

        end
    end)
end

function Core.event:characterUnload(user)
    TriggerEvent("vrp:playerUnloaded", user)
    TriggerClientEvent("vrp:playerUnloaded", user.source, user)
end

function Core.event:playerLeave(user)
    TriggerEvent("vrp:playerLeave", user)
    TriggerClientEvent("vrp:playerLeave", user.source, user)
end

function Core.event:playerDeath(user)
    TriggerEvent("vrp:playerDeath", user)
    TriggerClientEvent("vrp:playerDeath", user.source, user)
end

function Core.event:playerMoneyUpdate(user)
    TriggerClientEvent("vrp:core:moneyUpdated", user, user:getWallet(), user:getBank())
end

function Core:loadData(user)
    local data = {
        wallet = user:getWallet(),
        bank = user:getBank(),
        job = vRPJobsS.getCurrentJobByUser(user)
    }
    return data
end

function getUserByIdentifier(identifier)
    for source, user in pair(users_by_source) do
        if vRP.getSourceIdKey(source) == identifier then
            return user
        end
        return nil
    end
end

vRP:registerExtension(Core)

--- returns user
function vRPCoreS.getUserBySource(source)
    return vRP.users_by_source[source]
end

function vRPCoreS.hasLoaded()
    return (vRP.users_by_source[source]) and true or false
end

function vRPCoreS.getVehicles()
    local user = vRP.users_by_source[source]
    return user:getVehicles();
end

function vRPCoreS.getVehicles(amount, dry)
    local user = vRP.users_by_source[source]
    return user:tryFullPayment(amount, dry);
end



RegisterNetEvent('vrp_getPlayers')
AddEventHandler('vrp_getPlayers', function(callback)
    callback(vRP.users)
end)

exports('CoreGetUserBySource', function(source)
    return vRP.users_by_source[source]
end)

exports('getUsers', function(source)
    return vRP.users
end)

exports('CoreNotifyClient', function(source, msg)
    vRP.EXT.Base.remote._notify(source, msg)
end)

exports('CoreSendServiceAlert', function(sender, number, x, y, z, msg)
    vRP.EXT.Phone:sendServiceAlert(sender,number,x,y,z,msg)
end)

exports('getPlayerID', function(source)
    return vRP.users_by_source[source].id
end)

exports('getCharacterID', function(source)
    local retries = 0
    while not vRP.users_by_source[source] or retries > 15 do
        retries = retries + 1
        Citizen.Wait(1500)
    end
    return vRP.users_by_source[source].cid
end)

exports('getUserByIdentifier', function(identifier)
   return getUserByIdentifier(identifier)
end)

exports('tryPayment', function(source, amount, dry)
    local user = vRP.users_by_source[source]
    return user:tryPayment(amount, dry)
end)

exports('giveWallet', function(source, amount)
    local user = vRP.users_by_source[source]
    user:giveWallet(amount)
end)

exports('getWallet', function(source)
    local user = vRP.users_by_source[source]
    user:getWallet(amount)
end)

exports('getClosestOwnedVehicle', function(radius)
    return vRPCoreC.getNearestOwnedVehicle(radius)
end)

exports('getFullName', function(source)
    local user = vRP.users_by_source[source]
    return "" .. user.identity.firstname .. " " .. user.identity.name
end)

RegisterNetEvent('vrp_spawnVehicle')
AddEventHandler('vrp_spawnVehicle', function(model, position)
    local user = vRP.users_by_source[source]
    local vehicles = user:getVehicles()

    if vehicles[model] == 1 then -- in
        local vstate = user:getVehicleState(model)
        local state = {
            customization = vstate.customization,
            condition = vstate.condition,
            locked = vstate.locked
        }

        vehicles[model] = 0 -- mark as out
        vRP.EXT.Garage.remote._spawnVehicle(user.source, model, state, position)
        vRP.EXT.Garage.remote._setOutVehicles(user.source, {[model] = {}})

    elseif vehicles[model] == 0 then -- out
        vRP.EXT.Base.remote._notify(user.source, vRP.lang.garage.owned.already_out())

      -- force out request
        if user:request(vRP.lang.garage.owned.force_out.request({vRP.EXT.Garage.cfg.force_out_fee}), 15) then
            if user:tryPayment(vRP.EXT.Garage.cfg.force_out_fee) then
                local vstate = user:getVehicleState(model)
                local state = {
                    customization = vstate.customization,
                    condition = vstate.condition,
                    locked = vstate.locked
                }

                vehicles[model] = 0 -- mark as out
                vRP.EXT.Garage.remote._spawnVehicle(user.source, model, state)
                vRP.EXT.Garage.remote._setOutVehicles(user.source, {[model] = {state, vstate.position, vstate.rotation}})
            else
                vRP.EXT.Base.remote._notify(user.source, vRP.lang.money.not_enough())
            end
        end
    end
end)

RegisterNetEvent('vrp_despawnVehicle')
AddEventHandler('vrp_despawnVehicle', function(model)
    local user = vRP.users_by_source[source]
    local vehicles = user:getVehicles()

    if model then
        vRP.EXT.Garage.remote._removeOutVehicles(user.source, {[model] = true})

        if vRP.EXT.Garage.remote.despawnVehicle(user.source, model) then
            if vehicles[model] then 
                vehicles[model] = 1 -- mark as in garage
            end

            vRP.EXT.Base.remote._notify(user.source, vRP.lang.garage.store.stored())
        end
    else
        vRP.EXT.Base.remote._notify(user.source, vRP.lang.garage.store.too_far())
    end
end)

RegisterNetEvent('vrp_buyVehicle')
AddEventHandler('vrp_buyVehicle', function(model, amount)
    local user = vRP.users_by_source[source]
    local uvehicles = user:getVehicles()

    if uvehicles[model] then
        vRP.EXT.Base.remote._notify(user.source, "~r~You already own this vehicle")
        return
    end

    -- buy vehicle
    if user:tryPayment(amount, false) then
      uvehicles[model] = 1
      vRP.EXT.Base.remote._notify(user.source, vRP.lang.money.paid({amount}))
    else
      vRP.EXT.Base.remote._notify(user.source, vRP.lang.money.not_enough())
    end
end)

RegisterNetEvent('vrp_sellVehicle')
AddEventHandler('vrp_sellVehicle', function(model, amount, sellFactor)
    local user = vRP.users_by_source[source]
    local uvehicles = user:getVehicles()

    if not sellFactor then
        sellFactor = vRP.EXT.Garage.cfg.sell_factor
    end
    local price = math.ceil(amount*sellFactor)

    if uvehicles[model] == 1 and not user.cdata.rent_vehicles[model] then -- has vehicle in, not rented
      user:giveWallet(price)
      uvehicles[model] = nil

      vRP.EXT.Base.remote._notify(user.source,vRP.lang.money.received({price}))
      user:actualizeMenu()
    else
      vRP.EXT.Base.remote._notify(user.source,vRP.lang.common.not_found())
    end
end)

RegisterNetEvent('vrp_rentVehicle')
AddEventHandler('vrp_rentVehicle', function(model, amount, rentFactor)
    local user = menu.user
    local uvehicles = user:getVehicles()

    if not rentFactor then
        rentFactor = vRP.EXT.Garage.cfg.cfg.rent_factor
    end
    local price = math.ceil(amount*rentFactor)

    -- rent vehicle
    if user:tryPayment(price, false) then
      uvehicles[model] = 1
      user.cdata.rent_vehicles[model] = true

      vRP.EXT.Base.remote._notify(user.source,lang.money.paid({price}))
      user:actualizeMenu()
    else
      vRP.EXT.Base.remote._notify(user.source,lang.money.not_enough())
    end
end)
