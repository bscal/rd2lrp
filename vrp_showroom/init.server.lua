local Proxy = module("lib/Proxy")
local vRP = Proxy.getInterface("vRP")

async(
    function()
        vRP.loadScript("vrp_showroom", "server")
    end
)