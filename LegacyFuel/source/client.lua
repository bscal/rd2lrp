local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

async(function()
  vRP.loadScript("LegacyFuel", "config")
  vRP.loadScript("LegacyFuel", "source/fuel_client")
end)