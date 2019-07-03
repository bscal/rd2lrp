Proxy = module("lib/Proxy")
Tunnel = module("lib/Tunnel")
vRP = Proxy.getInterface("vRP")
async(
    function()
        vRP.loadScript("jobs", "client")
        vRP.loadScript("jobs", "client-jobs")
        vRP.loadScript("jobs", "gang/c-gang")
        vRP.loadScript("jobs", "stores/c-stores")
    end
)
