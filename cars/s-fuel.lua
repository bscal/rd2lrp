vRPCars = {}
Tunnel.bindInterface("cars", vRPCars)
Proxy.addInterface("cars", vRPCars)

math.randomseed( os.time() )
cost = math.random() + math.random(1,3);
local yesMsg = "Gas purchases success. Cost: "
local noMsg = "Gas purchases success. You dont have enought money"

RegisterNetEvent("frfuel:fuelAdded")
AddEventHandler("frfuel:fuelAdded", function(amount)
    local user = vRP.users_by_source[source]
    local finalCost = math.floor(amount * cost);
    local b = user:tryFullPayment(finalCost, false)
    if finalCost > 1 then
        TriggerClientEvent("pNotify:SendNotification", source, {
            text = yesMsg .. finalCost,
            timeout = 3000,
            layout = "topRight",
            queue = "queue"
        })
    else
        TriggerClientEvent("pNotify:SendNotification", source, {
            text = noMsg,
            timeout = 3000,
            type = info,
            layout = "topRight",
            queue = "queue"
        })
    end
end)

function vRPCars.getCurrentFuelCost(player)
    TriggerClientEvent("pNotify:SendNotification", source, {
        text = "<h4>Ron Gas</h4><br><p>Gas prices are at "..tostring(round(cost, 2)).." per/gallon</p>",
        timeout = 3000,
        type = info,
        layout = "topRight",
        queue = "queue"
    })
end

function round(val, decimal)
    local exp = decimal and 10^decimal or 1
    return math.ceil(val * exp - 0.5) / exp
end