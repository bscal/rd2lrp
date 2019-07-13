local guiEnabled = false

-- Client Jail Check Loop
Citizen.CreateThread(
    function()
        Citizen.Wait(5000)
        while true do
            Citizen.Wait(60000)
            vRPCopsS._updateJailTime(GetPlayerPed(-1))
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

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(0)

            if guiEnabled then
                DisableControlAction(0, 1, guiEnabled) -- LookLeftRight
                DisableControlAction(0, 2, guiEnabled) -- LookUpDown
                DisableControlAction(0, 24, guiEnabled) -- Attack
                DisableControlAction(0, 15, guiEnabled) -- ScrollUp
                DisableControlAction(0, 14, guiEnabled) -- ScrollDown
                DisableControlAction(0, 16, guiEnabled) -- ScrollUp
                DisableControlAction(0, 17, guiEnabled) -- ScrollDown
                DisableControlAction(0, 142, guiEnabled) -- MeleeAttackAlternate
                DisableControlAction(0, 106, guiEnabled) -- VehicleMouseControlOverride
            else
                EnableControlAction(0, 1, true) -- LookLeftRight
                EnableControlAction(0, 2, true) -- LookUpDown
                EnableControlAction(0, 24, true) -- Attack
                EnableControlAction(0, 15, true) -- ScrollUp
                EnableControlAction(0, 14, true) -- ScrollDown
                EnableControlAction(0, 16, true) -- ScrollUp
                EnableControlAction(0, 17, true) -- ScrollDown
                EnableControlAction(0, 142, true) -- MeleeAttackAlternate
                EnableControlAction(0, 106, true) -- VehicleMouseControlOverride
            end

            if IsControlJustPressed(0, 244) then -- M
                enableGui(not guiEnabled)
            end

            if IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
                SendNUIMessage(
                    {
                        type = "click"
                    }
                )
            end
        end
    end
)

function enableGui(enable)
    guiEnabled = enable
    SetNuiFocus(guiEnabled)
    SendNUIMessage(
        {
            type = "display",
            enable = guiEnabled
        }
    )
end

RegisterNUICallback(
    "escape",
    function(data)
        enableGui(false)
    end
)

RegisterNUICallback(
    "clicked",
    function(data)
    end
)
