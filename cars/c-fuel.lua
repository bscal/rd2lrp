vRP = Proxy.getInterface("vRP")
vRPserver = Tunnel.getInterface("vRP","cars")
vRPCarsS = Tunnel.getInterface("cars","cars")
vRPCarsC = {}
Tunnel.bindInterface("cars",vRPCarsC)
Proxy.addInterface("cars",vRPCarsC)

RegisterCommand('fuelprice', function(source, args)
    vRPCarsS.getCurrentFuelCost({GetPlayerPed(-1)})
end, false)