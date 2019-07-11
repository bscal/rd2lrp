Proxy = module("lib/Proxy")
Tunnel = module("lib/Tunnel")
vRP = Proxy.getInterface("vRP")

async(
    function()
        vRP.loadScript("dispatch", "client")
        vRP.loadScript("dispatch", "client-cmds")
    end
)
