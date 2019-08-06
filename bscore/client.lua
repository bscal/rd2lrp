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

exports('vRP:Core:Client:getUserBySource', function(source)
    return vRPCoreS.getUserBySource(source)
end)