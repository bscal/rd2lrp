vRPserver = Tunnel.getInterface("vRP","cars")
vRPCarsS = Tunnel.getInterface("cars","cars")
vRPCarsC = {}

RegisterCommand('fuelprice', function(source, args)
    vRPCarsS.getCurrentFuelCost({GetPlayerPed(-1)})
end, false)