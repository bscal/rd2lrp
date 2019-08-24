local Proxy = module("lib/Proxy")
local vRP = Proxy.getInterface("vRP")

async(function()
    vRP.loadScript("cars", "client")
    --vRP.loadScript("cars", "c-cardoors")
end)