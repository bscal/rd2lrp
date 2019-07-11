local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")
local vRP = Proxy.getInterface("vRP")
async(
    function()
        vRP.loadScript("utils", "client")
        vRP.loadScript("utils", "client-twitter")
        vRP.loadScript("utils", "client-mechanic")
        vRP.loadScript("utils", "client-weed")
        vRP.loadScript("utils", "client-mask")
        --vRP.loadScript("utils", "client-phone")
    end
)
