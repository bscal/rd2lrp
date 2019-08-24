vRPCarsS = {}
Tunnel.bindInterface("cars", vRPCarsS)
Proxy.addInterface("cars", vRPCarsS)

function vRPCarsS.transferOwnership(buyerID, model)
    local seller = vRP.users_by_source[source]
    local buyer = vRP.users_by_source[buyerID]

    vRP.EXT.Garage:transferOwnership(seller, buyer, model)

    print(seller.source, buyer.source, model)

    vRP.EXT.Base.remote._notify(seller.source, "You ~r~sold~w~ a car")
    vRP.EXT.Base.remote._notify(buyer.source, "You ~g~bought~w~ a car")
end
