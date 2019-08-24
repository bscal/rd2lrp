local vRPserver = Tunnel.getInterface("vRP", "cars")
local vRPCarsS = Tunnel.getInterface("cars", "cars")
local vRPCarsC = {}

RegisterCommand(
    "transferownership",
    function(source, args, rawCommand)
        local buyerID = tonumber(args[1])

        local ped = GetPlayerPed(-1)
        local model = vRP.EXT.Garage:getNearestOwnedVehicle(2)

        if model == nil then
            return
        end

        vRPCarsS._transferOwnership(buyerID, model)
    end
)