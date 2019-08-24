local Proxy = module("vrp", "lib/Proxy")
local vRP = Proxy.getInterface("vRP")

async(
    function()
        vRP.loadScript("cops", "c-cops-abilities")
        vRP.loadScript("cops", "c-cops-dispatch")
        vRP.loadScript("cops", "client")
    end
)
