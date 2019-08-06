local Proxy = module("lib/Proxy")
local vRP = Proxy.getInterface("vRP")

async(
    function()
        vRP.loadScript("bscore", "client")
    end
)