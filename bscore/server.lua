vRPclient = Tunnel.getInterface("vRP", "bscore")
vRPCoreC = Tunnel.getInterface("bscore", "bscore")

vRPCoreS = {}
Tunnel.bindInterface("bscore", vRPCoreS)
Proxy.addInterface("bscore", vRPCoreS)

local Core = class("bscore", vRP.Extension)
Core.User = class("User")
Core.tunnel = {}
Core.event = {}
Core.spawned_users = {}

function Core.event:playerSpawn(user, first_spawn)
    if first_spawn then Core.spawned_users[user] = true end
    TriggerEvent("vrp:playerSpawn", user, first_spawn)
end

function Core.event:characterLoad(user)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(5000)
            if user:isReady() and Core.spawned_users[user] then
                print(user.name .. " ("..user.source..")" .. " has loaded!")
                TriggerEvent("vrp:playerReady", user)
                TriggerClientEvent("vrp:playerReady", user.source, user)
                return
            end
        end
    end)
end

function Core.event:playerLeave(user)
    Core.spawned_users[user] = nil
end

function Core.event:playerMoneyUpdate(user)
    TriggerClientEvent("vrp:core:moneyUpdated", user, user:getWallet(), user:getBank())
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

RegisterNetEvent('vrp_getPlayers')
AddEventHandler('vrp_getPlayers', function(callback)
    callback(vRP.users)
end)

exports('CoreGetUserBySource', function(source)
    return vRP.users_by_source[source]
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
    while not vRP.users_by_source[source] do
        Citizen.Wait(1000)
    end
    return vRP.users_by_source[source].cid
end)

exports('getUserByIdentifier', function(identifier)
   return getUserByIdentifier(identifier)
end)
