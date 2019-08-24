local vRPdispatch = {}
Tunnel.bindInterface("dispatch", vRPdispatch)
Proxy.addInterface("dispatch", vRPdispatch)
local vRPdispatchC = Tunnel.getInterface("dispatch", "dispatch")

function vRPdispatch.ping(x, y, z, time)
    vRPdispatchC.ping(-1, x, y, z, time)
end

function vRPdispatch.dispatchS(playerid, msg, description, location)
    vRPdispatchC._dispatchC(-1, playerid, msg, description, location)
end

-- function vRPdispatch.updatePosition(x, y, z)
--     local user = vRP.users_by_source[source]
--     vRPdispatchC.setBlip(-1, user.source, x, y, z)
-- end

function vRPdispatch.repair()
    local user = vRP.users_by_source[source]
    if (user:tryTakeItem("repairkit", tonumber(1), false, false)) then
        vRPdispatchC.repairSuccess(user.source)
    end
end

function vRPdispatch.callHelp(msg, loc)
    local user = vRP.users_by_source[source]
    local phone = user.identity.phone

    TriggerClientEvent("311client", -1, phone, msg, loc)
end

function vRPdispatch.callEmergency(msg, loc)
    local user = vRP.users_by_source[source]
    local phone = user.identity.phone

    TriggerClientEvent("911client", -1, phone, msg, loc)
end

function vRPdispatch.emergencyRespond(number, msg)
    for k, v in pairs(vRP.users) do
        local identity = v.identity
        if (identity.phone == number) then
            TriggerClientEvent("callResponse", v.source, msg)
        end
    end
end

RegisterNetEvent("gsrServer")
AddEventHandler(
    "gsrServer",
    function(closestID)
        local user = vRP.users_by_source[source]
        TriggerClientEvent("gsrClient", closestID, user.source)
    end
)

RegisterNetEvent("gsrResults")
AddEventHandler(
    "gsrResults",
    function(copID, results)
        local str = "Tests returned negative"
        if (results) then
            str = "Tests returned positive"
        end

        TriggerClientEvent(
            "pNotify:SendNotification",
            copID,
            {
                text = "<b style='color:#2142ff'>GSR</b><br /><p>" .. str .. ".</p>",
                type = "info",
                timeout = 5000,
                layout = "topRight"
            }
        )
    end
)
