vRPCars = {}
Tunnel.bindInterface("cars", vRPCars)
Proxy.addInterface("cars", vRPCars)

function vRPCars.transferOwnership(buyerID, veh, cid, model)
    local seller = vRP.users_by_source[source]
    local buyer = vRP.users_by_source[buyerID]

    if not seller.cid == cid then
        return
    end

    local svehicles = seller:getVehicles()
    local bvehicles = buyer:getVehicles()

    if svehicles[model] == 1 and not bvehicles[model] == 1 then
        if not seller.rent_vehicles[model] and not  buyer.rent_vehicles[model] then
            svehicles[model] = nil
            bvehicles[model] = 1
            vRP.EXT.Base.remote._notify(seller.source, "You ~r~sold~w~ a car")
            vRP.EXT.Base.remote._notify(buyer.source, "You ~g~bought~w~ a car")
        end
    end
end
