local vRPserver = Tunnel.getInterface("vRP", "cars")
local vRPCarsS = Tunnel.getInterface("cars", "cars")
local vRPCarsC = {}

RegisterCommand(
    "transferownership",
    function(source, args, rawCommand)
        local buyerID = tonumber(args[1])

        local ped = GetPlayerPed(-1)
        local veh = GetVehiclePedIsIn(ped, false)
        local cid, model = vRP.EXT.Garage:getVehicleInfo(veh)

        if cid == nil or model == nil then
            return
        end

        vRPCarsS.transferOwnership(buyerID, veh, cid, model)
    end
)