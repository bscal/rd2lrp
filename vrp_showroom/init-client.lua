local Proxy = module("lib/Proxy")
local vRP = Proxy.getInterface("vRP")

async(
    function()
        vRP.loadScript("vrp_showroom", "cfg/showroom")
        vRP.loadScript("vrp_showroom", "client")
    end
)