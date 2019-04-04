local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

async(function()
  vRP.loadScript("robberies", "server-robberies")
end)