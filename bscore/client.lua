vRPclient = Tunnel.getInterface("vRP", "bscore")
vRPCoreS = Tunnel.getInterface("bscore", "bscore")

vRPCoreC = {}
Tunnel.bindInterface("bscore", vRPCoreC)
Proxy.addInterface("bscore", vRPCoreC)

local Core = class("bscore", vRP.Extension)
Core.User = class("User")
Core.tunnel = {}
Core.event = {}

vRP:registerExtension(Core)

exports('ClientGetUserBySource', function(source)
    return vRPCoreS.getUserBySource(source)
end)

exports('getClosestOwnedVehicle', function(radius)
    return vRP.EXT.Garage:getNearestOwnedVehicle(radius)
end)

function vRPCoreC.getNearestOwnedVehicle(radius)
    return vRP.EXT.Garage:getNearestOwnedVehicle(radius)
end

RegisterNetEvent("vrp:setStatusBar")
AddEventHandler("vrp:setStatusBar", function(name, text, r, g, b, value)
    vRP.EXT.GUI:setProgressBar(name,"minimap", text, r, g, b, value)
end)

RegisterNetEvent("vrp:updateStatusBar")
AddEventHandler("vrp:updateStatusBar", function(name,value)
    vRP.EXT.GUI:setProgressBarValue(name, value)
end)