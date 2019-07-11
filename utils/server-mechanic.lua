local REPAIR_COST = 1500

function vRPUtils.hasMoneyForRepair()
    local user = vRP.users_by_source[source]
    if (user:tryPayment(REPAIR_COST, false)) then
        return true
    end
    vRP.EXT.Base.remote._notify(user.source, "Not enough money. Cost: 1500$")
    return false
end

function vRPUtils.hasRepairKit()
    local user = vRP.users_by_source[source]
    if (user:tryTakeItem("repairkit", 1, false, false)) then
        return true
    end
    vRP.EXT.Base.remote._notify(user.source, "You do not have a repair kit")
    return false
end
