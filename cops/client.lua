-- Client Jail Check Loop
Citizen.CreateThread(
    function()
        Citizen.Wait(5000)
        while true do
            Citizen.Wait(60000)
            vRPCopsS.updateJailTime(GetPlayerPed(-1))
        end
    end
)

RegisterCommand(
    "copadmin",
    function(source, args)
        if (args[1] == "add") then
            if (args[2] == "cop") then
                vRPCopsS.setCop(tonumber(args[3]))
                TriggerEvent("coperr", "Added a cop")
            elseif (args[2] == "admin") then
                vRPCopsS.setAdmin(tonumber(args[3]))
                TriggerEvent("coperr", "Added a admin")
            end
        elseif (args[1] == "rm") then
            if (args[2] == "cop") then
                vRPCopsS.delCop(tonumber(args[3]))
                TriggerEvent("coperr", "Removed a cop")
            elseif (args[2] == "admin") then
                vRPCopsS.delCop(tonumber(args[3]))
                TriggerEvent("coperr", "Removed a admin")
            end
        end
    end
)

RegisterCommand(
    "cop",
    function(source, args)
        if (args[1] == "fine") then
            if (#args < 3) then
                TriggerEvent("coperr", "Wrong args: /cop fine id amount")
                return
            end
            vRPCopsS.Fine(GetPlayerPed(-1), tonumber(args[2]), tonumber(args[3]))
        elseif (args[1] == "jail") then
            if (#args < 3) then
                TriggerEvent("coperr", "Wrong args: /cop jail id time")
                return
            end
            vRPCopsS.Jail(GetPlayerPed(-1), tonumber(args[2]), tonumber(args[3]))
        end
    end,
    false
)

RegisterNetEvent("tp")
AddEventHandler(
    "tp",
    function(x, y, z)
        SetEntityCoordsNoOffset(GetPlayerPed(-1), x, y, z, 1, 0, 0, 1)
    end
)

RegisterNetEvent("leash")
AddEventHandler(
    "leash",
    function(x, y, z)
        local dist = (GetEntityCoords(GetPlayerPed(-1), false) - vector3(x, y, z))
        if (dist.x > 150) or (dist.x < -150) or (dist.y > 150) or (dist.y < -150) then
            TriggerEvent("tp", x, y, z)
        end
    end
)

AddEventHandler(
    "coperr",
    function(err)
        TriggerEvent(
            "chat:addMessage",
            {
                args = {"Police", err}
            }
        )
    end
)
