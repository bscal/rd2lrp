local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

async(
  function()
    vRP.loadScript("jobs", "server-jobs")
    vRP.loadScript("jobs", "gang/s-gang")
    vRP.loadScript("jobs", "stores/s-stores")
    vRP.loadScript("jobs", "businesses/s-business")
  end
)
